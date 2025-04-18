import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ schema: 'ponto_parada', name: 'tab_ponto_interpolado' })
export class PontoInterpolado {
  @PrimaryGeneratedColumn({ 
    name: 'id_ponto_interpolado' })
    idPontoInterpolado: number;

    @Column({ 
      type: 'int', 
      name: 'id_ponto_parada',
    })
    IdPontoParada: number;

    @Column({ 
      type: 'float8', 
      name: 'latitude' 
    })
    latitudeInterpolado: string;

    @Column({ 
      type: 'float8', 
      name: 'longitude' 
    })
    longitudeInterpolado: string;
}