import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ schema: 'ponto_parada', name: 'tab_tipo_patologia' })
export class TipoPatologia {
  @PrimaryGeneratedColumn({ 
    name: 'id_tipo_patologia' })
    idTipoPatologia: number;

  @Column({ 
    type: 'varchar', 
    name: 'desc_patologias', 
    length: 100
  })
  DescPatologia: string;

  @Column({ 
    type: 'bytea', 
    name: 'patologia_img', 
    nullable: true })
  imgBlob: Buffer;
}