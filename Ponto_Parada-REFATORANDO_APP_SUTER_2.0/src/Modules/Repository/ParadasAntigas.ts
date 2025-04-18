import { Injectable } from '@nestjs/common';
import { DataSource } from 'typeorm';
import { ParadasAntigas } from '../Entity/ParadasAntigas';

@Injectable()
export class ParadasAntigasRepository {
  constructor(private readonly dataSource: DataSource) {}

  async all(): Promise<any[]> {
    const query = `
    select
        tpn.id,
        tpn.sequencial,
        tpn.sentido,
        tpn.cod_dftrans,
        tpn.longitude,
        tpn.latitude
    FROM 
	    ponto_parada.tab_parada_antigas tpn;`;
    return await this.dataSource.query(query);
  }
  

  async findParadasAntigasRA(searchTerm: string): Promise<any[]> {
    const query = `
    SELECT
        tpn.id,
        tpn.sequencial,
        tpn.sentido,
        tpn.cod_dftrans,
        tpn.longitude,
        tpn.latitude,
        tr.dsc_nome
    FROM
        ponto_parada.tab_parada_antigas tpn,
        ponto_parada.tab_ras tr
    WHERE
        ST_Contains(tr.geom , ST_Transform(tpn.geom_point, 31983))
        AND tr.dsc_nome ILIKE $1; 
    `;
  
    return await this.dataSource.query(query, [`%${searchTerm}%`]);
  }
  
  async findParadasAntigasBacias(searchTerm: string): Promise<any[]> {
    const query = `
      SELECT
        tpn.id,
        tpn.sequencial,
        tpn.sentido,
        tpn.cod_dftrans,
        tpn.longitude,
        tpn.latitude,
        tb.dsc_bacia 
    FROM
        ponto_parada.tab_parada_antigas tpn,
        ponto_parada.tab_bacias tb
    WHERE
        ST_Contains(tb.geo_bacia , ST_Transform(tpn.geom_point, 31983))
        AND tb.dsc_bacia ILIKE $1;
    `;
  
    return await this.dataSource.query(query, [`%${searchTerm}%`]);
  }  
}
