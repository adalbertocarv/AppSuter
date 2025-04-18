import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ schema: 'ponto_parada', name: 'tab_bacias' })
export class Bacias {
  @PrimaryGeneratedColumn({ 
    name: 'seq_bacia' })
    idBacia: number;

  @Column({ 
    type: 'varchar', 
    name: 'dsc_bacia', 
    length: 100 
  })
  descBacia: string;

  @Column({ 
    type: 'geometry', 
    spatialFeatureType: 'Polygon', 
    srid: 31983, 
    name: 'geo_bacia' 
  })
  geoBacia: string;

  @Column({ 
    type: 'varchar', 
    name: 'cod_bacia', 
    length: 50
  })
  codBacia: string;
}
