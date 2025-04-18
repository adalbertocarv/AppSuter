import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { InjectConnection } from '@nestjs/typeorm';
import { Connection, DataSource } from 'typeorm';
import { convertBase64ToBuffer } from '../Utils/Buffer';
import { VisitaRepository } from '../Repository/Cadastro';

@Injectable()
export class PontoParadaRepository {
    connection: any;
  constructor(
    private readonly visitaRepository: VisitaRepository,
    private readonly dataSource: DataSource, // ✅ correto agora
  ) {}

  async findPontosParadaRA(searchTerm: string): Promise<any[]> {
    const query = `
      SELECT
          tu.nome as criado_por,
          tpp.dt_criacao as criado_em,
          ttm.abrigo_nome,
          ttm.abrigo_img,
          tpp.endereco,
          tpp.latitude,
          tpp.longitude,
          tr.dsc_nome,
          tpp.linha_escolar,
	        tpp.linha_stpc
      FROM
          ponto_parada.tab_usuario tu,
          ponto_parada.tab_ponto_parada tpp,
          ponto_parada.tab_abrigo ta,
          ponto_parada.tab_tipo_abrigo ttm,
          ponto_parada.tab_ras tr
      WHERE
          tu.id_usuario = tpp.id_usuario
          AND tpp.id_ponto_parada = ta.id_ponto_parada
          AND ta.id_tipo_abrigo = ttm.id_tipo_abrigo
          AND ST_Contains(tr.geom, ST_Transform(tpp.geom_point, 31983))
          AND tr.dsc_nome ILIKE $1;
    `;
  
    return await this.dataSource.query(query, [`%${searchTerm}%`]);
  }
  
  async findPontosParadaBacias(searchTerm: string): Promise<any[]> {
    const query = `
      SELECT
          tu.nome as criado_por,
          tpp.dt_criacao as criado_em,
          ttm.abrigo_nome,
          ttm.abrigo_img,
          tpp.endereco,
          tpp.latitude,
          tpp.longitude,
          tb.dsc_bacia,
          tpp.linha_escolar,
	        tpp.linha_stpc
      FROM
          ponto_parada.tab_usuario tu,
          ponto_parada.tab_ponto_parada tpp,
          ponto_parada.tab_abrigo ta,
          ponto_parada.tab_tipo_abrigo ttm,
          ponto_parada.tab_bacias tb
      WHERE
          tu.id_usuario = tpp.id_usuario
          AND tpp.id_ponto_parada = ta.id_ponto_parada
          AND ta.id_tipo_abrigo = ttm.id_tipo_abrigo
          AND ST_Contains(tb.geo_bacia, ST_Transform(tpp.geom_point, 31983))
          AND tb.dsc_bacia ILIKE $1;
    `;
  
    return await this.dataSource.query(query, [`%${searchTerm}%`]);
  }  

  async findPontosParada(): Promise<any[]> {
    const query = `
    SELECT
        tu.nome as criado_por,
        tpp.dt_criacao as criado_em,
        tv.data_visita as visitado_em,
        tpp.endereco,
        ttm.abrigo_nome,
        tia.abrigo_img,
        tpp.endereco,
        tpp.latitude,
        tpp.longitude,
        tpp.linha_escolar,
        tpp.linha_stpc
    FROM
        ponto_parada.tab_usuario tu,
        ponto_parada.tab_ponto_parada tpp,
        ponto_parada.tab_abrigo ta,
        ponto_parada.tab_imagens_abrigo tia,
        ponto_parada.tab_tipo_abrigo ttm,
        ponto_parada.tab_visita tv
    where
        tu.id_usuario = tpp.id_usuario
        and tpp.id_ponto_parada = ta.id_ponto_parada
        and ta.id_tipo_abrigo = ttm.id_tipo_abrigo
        and tpp.id_ponto_parada = tv.id_ponto_parada
        and ta.id_abrigo = tia.id_abrigo;
        `;

    return await this.dataSource.query(query);
  }

  async createPontoParada(data: any): Promise<any> {
    console.log("⏳ Criando ponto de parada...");

    const usuarioExiste = await this.dataSource.query(
      `SELECT 1 FROM ponto_parada.tab_usuario WHERE id_usuario = $1 LIMIT 1;`,
      [data.id_usuario]
    );

    if (usuarioExiste.length === 0) {
      throw new HttpException("Usuário não encontrado.", HttpStatus.NOT_FOUND);
    }

    const resultPontoParada = await this.dataSource.query(
      `INSERT INTO ponto_parada.tab_ponto_parada 
        (id_usuario, latitude, longitude, endereco, dt_criacao, dt_atualizacao, geom_point, linha_escolar, linha_stpc, baia) 
       VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP, $5, ST_SetSRID(ST_MakePoint($6, $7), 4326), $8, $9, $10) 
       RETURNING id_ponto_parada;`,
      [
        data.id_usuario,
        data.latitude,
        data.longitude,
        data.endereco,
        data.dt_atualizacao,
        data.longitude,
        data.latitude,
        data.linha_escolar,
        data.linha_stpc,
        data.baia
      ]
    );

    const idPontoParada = resultPontoParada[0].id_ponto_parada;
    console.log(`✅ Ponto de parada criado com ID: ${idPontoParada}`);

    // Ponto Interpolado
    if (data.latitudeInterpolado !== undefined && data.longitudeInterpolado !== undefined) {
      await this.dataSource.query(
        `INSERT INTO ponto_parada.tab_ponto_interpolado (id_ponto_parada, latitude, longitude) 
         VALUES ($1, $2, $3);`,
        [idPontoParada, data.latitudeInterpolado, data.longitudeInterpolado]
      );
      console.log(`✅ Ponto interpolado inserido para o ID: ${idPontoParada}`);
    } else {
      console.log("⚠️ Nenhum ponto interpolado informado.");
    }

    // Abrigos + coleta para visita
    const abrigosParaVisita: { id_abrigo: number; patologias: any[] }[] = [];

    for (const abrigo of data.abrigos) {
      const resultAbrigo = await this.dataSource.query(
        `INSERT INTO ponto_parada.tab_abrigo (id_ponto_parada, id_tipo_abrigo) VALUES ($1, $2) RETURNING id_abrigo;`,
        [idPontoParada, abrigo.id_tipo_abrigo]
      );

      const idAbrigo = resultAbrigo[0].id_abrigo;
      console.log(`✅ Abrigo criado com ID: ${idAbrigo}`);

      // Imagens do abrigo
      for (const imagem of abrigo.imagens) {
        if (!imagem.abrigo_img) {
          throw new HttpException("Imagem não pode ser nula.", HttpStatus.BAD_REQUEST);
        }

        const imagemBuffer = await convertBase64ToBuffer(imagem.abrigo_img, 50, 60);

        if (imagemBuffer) {
          await this.dataSource.query(
            `INSERT INTO ponto_parada.tab_imagens_abrigo (id_abrigo, abrigo_img) VALUES ($1, $2);`,
            [idAbrigo, imagemBuffer]
          );
          console.log(`✅ Imagem do abrigo associada ao ID: ${idAbrigo}`);
        } else {
          console.warn(`⚠️ Erro ao converter imagem para o ID: ${idAbrigo}`);
        }
      }

      // Coletar patologias para esse abrigo
      abrigosParaVisita.push({
        id_abrigo: idAbrigo,
        patologias: abrigo.patologias ?? []
      });
    }

    // Chamada da visita com os ids corretos
    await this.visitaRepository.createVisita(idPontoParada, {
      data_visita: data.data_visita,
      rampa_acessivel: data.rampa_acessivel,
      piso_tatil: data.piso_tatil,
      patologia: data.patologia,
      abrigos: abrigosParaVisita
    });

    return { message: "Ponto de parada, ponto interpolado e abrigos cadastrados com sucesso." };

  }
}