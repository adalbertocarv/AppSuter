// repository/VisitaRepository.ts
import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { InjectConnection } from '@nestjs/typeorm';
import { Connection } from 'typeorm';
import { convertBase64ToBuffer } from '../Utils/Buffer';
import { pontoParadaData } from '../Utils/PontoParada';
import { visitaData } from '../Utils/Cadastro';

@Injectable()
export class VisitaRepository {
    constructor(@InjectConnection() private readonly connection: Connection) {}

    async createVisita(idPontoParada: number, data: any): Promise<any> {
        console.log("⏳ Criando visita para o ponto de parada ID:", idPontoParada);
        const formattedData = visitaData(data);

        const resultVisita = await this.connection.query(
            `INSERT INTO ponto_parada.tab_visita (id_ponto_parada, data_visita) 
             VALUES ($1, $2) RETURNING id_visita;`,
            [idPontoParada, formattedData.data_visita]
        );        

        const idVisita = resultVisita[0].id_visita;
        console.log(`✅ Visita criada com ID: ${idVisita}`);

        await this.connection.query(
            `INSERT INTO ponto_parada.tab_visita_acessibilidade (id_visita, rampa_acessivel, piso_tatil) 
             VALUES ($1, $2, $3);`,
            [idVisita, formattedData.rampa_acessivel, formattedData.piso_tatil]
        );
        console.log("✅ Acessibilidade da visita registrada.");

        for (const abrigo of formattedData.abrigos) {
            for (const patologia of abrigo.patologias || []) {
              const resultPatologia = await this.connection.query(
                `INSERT INTO ponto_parada.tab_visita_patologia (id_visita, id_tipo_patologia) 
                 VALUES ($1, $2) RETURNING id_visita_patologia;`,
                [idVisita, patologia.id_tipo_patologia]
              );
          
              const idVisitaPatologia = resultPatologia[0].id_visita_patologia;
              console.log(`✅ Patologia registrada com ID: ${idVisitaPatologia}, Abrigo ID: ${abrigo.id_abrigo}`);
          
              for (const imagem of patologia.imagens || []) {
                if (!imagem.patologias_img) {
                  throw new HttpException("Imagem não pode ser nula.", HttpStatus.BAD_REQUEST);
                }
          
                const imagemBuffer = await convertBase64ToBuffer(imagem.patologias_img, 50, 60);
          
                if (imagemBuffer) {
                  await this.connection.query(
                    `INSERT INTO ponto_parada.tab_imagens_patologias (id_visita_patologia, id_abrigo, patologias_img)  
                     VALUES ($1, $2, $3);`,
                    [idVisitaPatologia, abrigo.id_abrigo, imagemBuffer]
                  );
          
                  console.log(`✅ Imagem de patologia associada ao ID: ${idVisitaPatologia}, Abrigo ID: ${abrigo.id_abrigo}`);
                } else {
                  console.warn(`⚠️ Erro ao converter imagem para o ID: ${idVisitaPatologia}`);
                }
              }
            }
          }
                    
        return { message: "Visita cadastrada com sucesso." };
    }
}
