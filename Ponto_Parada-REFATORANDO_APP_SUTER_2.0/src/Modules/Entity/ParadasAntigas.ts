import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity({ schema: 'ponto_parada', name: 'tab_parada_antigas' })
export class ParadasAntigas {
  @PrimaryGeneratedColumn({ 
    name: 'id' })
    idParadaAntiga: number;

  @Column({ 
    type: 'int', 
    name: 'sequencial' 
  })
  Sequencial: number;  

  @Column({ 
    type: 'varchar', 
    name: 'sentido',
    length: '30'
  })
  sentido: string;

  @Column({ 
    type: 'int', 
    name: 'cod_dftrans' 
  })
  CodDftrans: number;  

  @Column({ 
    type: 'float8', 
    name: 'latitude' 
  })
  latitude: string;

  @Column({ 
    type: 'float8', 
    name: 'longitude' 
  })
  longitude: string;
}