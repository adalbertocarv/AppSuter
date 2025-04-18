import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ schema: 'ponto_parada', name: 'tab_imagens_patologias' })
export class ImagensPatologia {
  @PrimaryGeneratedColumn({ name: 'id_imagens_patologias' })
  idImagensPatologias: number;

  @Column({ 
    type: 'int', 
    name: 'id_visita_patologia', 
  })
  idVisitaPatologia: number;

  @Column({ 
    type: 'bytea', 
    name: 'patologias_img',
    nullable: true
  })
  ImagensPatologia: Buffer;
}
