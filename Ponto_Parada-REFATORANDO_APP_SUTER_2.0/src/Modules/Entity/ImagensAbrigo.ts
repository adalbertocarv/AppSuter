import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ schema: 'ponto_parada', name: 'tab_imagens_abrigo' })
export class ImagensAbrigo {
  @PrimaryGeneratedColumn({ 
    name: 'id_imagens_abrigo' })
    idImagensAbrigo: number;

  @Column({ 
    type: 'int', 
    name: 'id_abrigo', 
  })
  idAbrigo: number;

  @Column({ 
    type: 'bytea', 
    name: 'abrigo_img', 
    nullable: true })
  imgBlob: Buffer;
}