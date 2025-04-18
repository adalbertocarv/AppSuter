import { Entity, Column, PrimaryGeneratedColumn, Timestamp } from 'typeorm';

@Entity({ schema: 'ponto_parada', name: 'tab_visita_patologia' })
export class VisitaPatologia {
  @PrimaryGeneratedColumn({ 
    name: 'id_visita_patologia' })
    idVisitaPatologia: number;

    @Column({ 
      type: 'int', 
      name: 'id_visita',
    })
    IdVisita: number;

    @Column({ 
      type: 'int', 
      name: 'id_tipo_patologia',
    })
    IdTipoPatologia: number;

    @Column({ type: 'boolean', name: 'patologia' }) // Correção aqui (de number para boolean)
  Patologia: boolean;
}