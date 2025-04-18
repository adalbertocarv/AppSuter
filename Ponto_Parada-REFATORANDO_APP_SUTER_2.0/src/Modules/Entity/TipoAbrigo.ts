import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ schema: 'ponto_parada', name: 'tab_tipo_abrigo' })
export class TipoAbrigo {
  @PrimaryGeneratedColumn({ 
    name: 'id_tipo_abrigo' })
    idTipoAbrigo: number;

  @Column({ 
    type: 'varchar', 
    name: 'abrigo_nome', 
    length: 50 
  })
  nomeAbrigo: string;

  @Column({ 
    type: 'date', 
    name: 'dt_vigencia', 
  })
  inicioVigencia: string;

  @Column({ 
    type: 'date', 
    name: 'dt_fim_vigencia', 
  })
  fimVigencia: string;

  @Column({ 
    type: 'bytea', 
    name: 'abrigo_img', 
    nullable: true })
  imgBlob: Buffer;
}