import { Injectable } from '@nestjs/common';
import { DataSource } from 'typeorm';
import { RedeViasUtils } from '../Utils/RedeVias';


@Injectable()
export class RedeViasRepository {
  constructor(private readonly dataSource: DataSource) {}

  async findViasProximas(longitude: number, latitude: number): Promise<any[]> {
    const query = `
      SELECT 
          ST_AsGeoJSON(ST_Transform(trv.geo_rede_via, 31983)) AS vias_proximas
      FROM 
          ponto_parada.tab_rede_vias trv
      WHERE 
          ST_DWithin(
              ST_Transform(trv.geo_rede_via, 4326)::geography, 
              ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography, 
              100
          );
    `;

    const result = await this.dataSource.query(query, [longitude, latitude]);
    return RedeViasUtils.formatGeoJson(result);
  }
}
