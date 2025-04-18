import { Entity, Column, PrimaryGeneratedColumn, Timestamp } from 'typeorm';

@Entity({ schema: 'ponto_parada', name: 'tab_visita_acessibilidade' })
export class VisitaAcessibilidade {
  @PrimaryGeneratedColumn({ 
    name: 'id_visita_acessibilidade' })
    idVisitaAcessibilidade: number;

    @Column({ 
      type: 'int', 
      name: 'id_visita',
    })
    IdVisita: number;

    @Column({ 
        type: 'boolean', 
        name: 'rampa_acessivel',
      })
      Rampa: boolean;
  
    @Column({ 
        type: 'boolean', 
        name: 'piso_tatil',
    })
    PisoTatil: boolean;
}