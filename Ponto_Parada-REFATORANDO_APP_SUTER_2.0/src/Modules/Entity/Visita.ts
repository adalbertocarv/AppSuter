import { Entity, Column, PrimaryGeneratedColumn, Timestamp } from 'typeorm';

@Entity({ schema: 'ponto_parada', name: 'tab_visita' })
export class Visita {
  @PrimaryGeneratedColumn({ 
    name: 'id_visita' })
    idVisita: number;

    @Column({ 
      type: 'int', 
      name: 'id_ponto_parada',
    })
    IdPontoParada: number;

    @Column({ 
      type: 'timestamp', 
      name: 'data_visita' 
    })
    DataVisita: Timestamp;
}