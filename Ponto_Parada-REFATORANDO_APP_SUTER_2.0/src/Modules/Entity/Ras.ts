import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ schema: 'ponto_parada', name: 'tab_ras' })
export class Ras {
  @PrimaryGeneratedColumn({ 
    name: 'seq_ras' })
    idBacia: number;

  @Column({ 
    type: 'varchar', 
    name: 'dsc_nome', 
    length: 100 
  })
  descNome: string;

  @Column({ 
    type: 'geometry', 
    spatialFeatureType: 'Polygon', 
    srid: 31983, 
    name: 'geom' 
  })
  geoRas: string;

  @Column({ 
    type: 'varchar', 
    name: 'dsc_prefixo_ra', 
    length: 50
  })
  descPrefixoRa: string;
}
