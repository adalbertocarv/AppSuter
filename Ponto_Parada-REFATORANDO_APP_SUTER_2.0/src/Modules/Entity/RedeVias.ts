import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ schema: 'ponto_parada', name: 'tab_rede_vias' })
export class RedeVias {
  @PrimaryGeneratedColumn({ 
    name: 'seq_rede_via' })
    id_rede_vias: number;

  @Column({ 
    type: 'geometry', 
    spatialFeatureType: 'Polygon', 
    srid: 31983, 
    name: 'geo_rede_via' 
  })
  geoRedeVias: string;
}
