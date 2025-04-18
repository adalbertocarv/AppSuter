import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ schema: 'ponto_parada', name: 'tab_abrigo' })
export class Abrigo {
  @PrimaryGeneratedColumn({ 
    name: 'id_abrigo' })
    idAbrigo: number;

  @Column({ 
    type: 'int', 
    name: 'id_ponto_parada', 
  })
  idPontoParada: number;

  @Column({ 
    type: 'int', 
    name: 'id_tipo', 
  })
  idTipoAbrigo: number;
}

export interface Patologia {
  idTipoPatologia: number;
  Patologia: boolean;
  ImagensPatologia?: Buffer[];  // 🔹 Agora está no lugar correto
}

export interface Abrigo {
  idTipoAbrigo: number;
  imgBlob?: Buffer[]; // 🔹 Imagens do abrigo
  patologias?: Patologia[];  // 🔹 Patologias dentro de Abrigo
}


