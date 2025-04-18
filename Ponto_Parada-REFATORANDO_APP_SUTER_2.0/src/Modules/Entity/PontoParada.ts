import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity({ schema: 'ponto_parada', name: 'tab_ponto_parada' })
export class PontoParada {
  @PrimaryGeneratedColumn({ 
    name: 'id_ponto_parada' })
    idPontoParada: number;

  @Column({ 
    type: 'int', 
    name: 'id_usuario' 
  })
  idUsuario: number;  

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

  @Column({ 
    type: 'varchar', 
    name: 'endereco', 
    length: 100
  })
  endereco: string;

  @Column({ 
    type: 'boolean', 
    name: 'linha_escolar'
  })
  LinhaEscolares: Boolean;

  @Column({ 
    type: 'boolean', 
    name: 'linha_stpc'
  })
  LinhaStpc: Boolean;


  @CreateDateColumn({ name: 'dt_criacao', type: 'timestamp' })
  dtCriacao: Date;

  @UpdateDateColumn({ name: 'dt_atualizacao', type: 'timestamp', nullable: true })
  dtAtualizacao: Date;
}
