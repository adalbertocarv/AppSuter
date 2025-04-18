import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TipoPatologia } from '../Entity/TipoPatologia';

interface TipoPatologiaDTO {
  idTipoPatologia?: number;
  DescPatologia: string;
  imgBlob?: Buffer;
}

@Injectable()
export class TipoPatologiaService {
  constructor(
    @InjectRepository(TipoPatologia)
    private readonly TipoPatologiaRepository: Repository<TipoPatologia>,
  ) {}

  async findAll(): Promise<{ 
    idTipoPatologia: number; 
    DescPatologia: string; 
    linkImagem: string; 
  }[]> {
    const Patologia = await this.TipoPatologiaRepository.find({
      select: ['idTipoPatologia', 'DescPatologia'],
    });

    return Patologia.map(patologia => ({
      ...patologia,
      linkImagem: `http://localhost:3000/tipo/patologia/${encodeURIComponent(patologia.DescPatologia)}/imagem`,
    }));
  }

  async findByTipoPatologia(DescPatologia: string): Promise<{ 
    idTipoPatologia: number; 
    DescPatologia: string; 
    linkImagem: string;
  } | null> {
    const Patologia = await this.TipoPatologiaRepository.findOne({
      where: { DescPatologia },
      select: ['idTipoPatologia', 'DescPatologia'],
    });

    if (!Patologia) return null;

    return {
      ...Patologia,
      linkImagem: `http://localhost:3000/tipo/patologia/${encodeURIComponent(Patologia.DescPatologia)}/imagem`,
    };
  }

  async getImagemByNome(DescPatologia: string): Promise<Buffer | null> {
    const abrigo = await this.TipoPatologiaRepository.findOne({
      where: { DescPatologia },
      select: ['imgBlob'],
    });

    if (!abrigo || !abrigo.imgBlob) {
      throw new NotFoundException(`Imagem do patologia ${DescPatologia} não encontrada.`);
    }

    return abrigo.imgBlob;
  }

  /**
   * Cria um novo registro de TipoPatologia no banco de dados
   * @param data Dados da patologia a serem inseridos
   * @returns TipoPatologiaDTO com os dados inseridos
   */
  async createTipoPatologia(data: TipoPatologiaDTO): Promise<TipoPatologiaDTO> {
    const novaPatologia = this.TipoPatologiaRepository.create(data);
    await this.TipoPatologiaRepository.save(novaPatologia);
    return novaPatologia;
  }
}