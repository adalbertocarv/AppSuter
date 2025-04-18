import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TipoAbrigo } from '../Entity/TipoAbrigo';

@Injectable()
export class TipoAbrigoService {
  constructor(
    @InjectRepository(TipoAbrigo)
    private readonly TipoAbrigoRepository: Repository<TipoAbrigo>,
  ) {}

  async findAll(): Promise<{ 
    idTipoAbrigo: number; 
    nomeAbrigo: string; 
    inicioVigencia: string; 
    fimVigencia: string; 
    linkImagem: string;
  }[]> {
    const abrigos = await this.TipoAbrigoRepository.find({
      select: ['idTipoAbrigo', 'nomeAbrigo', 'inicioVigencia', 'fimVigencia'], // Exclui imgBlob
    });

    return abrigos.map(abrigo => ({
      ...abrigo,
      linkImagem: `http://localhost:3000/tipo/abrigo/${encodeURIComponent(abrigo.nomeAbrigo)}/imagem`,
    }));
  }

  async findByTipoAbrigo(nomeAbrigo: string): Promise<{ 
    idTipoAbrigo: number; 
    nomeAbrigo: string; 
    inicioVigencia: string; 
    fimVigencia: string; 
    linkImagem: string;
  } | null> {
    const abrigo = await this.TipoAbrigoRepository.findOne({
      where: { nomeAbrigo },
      select: ['idTipoAbrigo', 'nomeAbrigo', 'inicioVigencia', 'fimVigencia'],
    });

    if (!abrigo) return null;

    return {
      ...abrigo,
      linkImagem: `http://localhost:3000/tipo/abrigo/${encodeURIComponent(abrigo.nomeAbrigo)}/imagem`,
    };
  }

  async getImagemByNome(nomeAbrigo: string): Promise<Buffer | null> {
    const abrigo = await this.TipoAbrigoRepository.findOne({
      where: { nomeAbrigo },
      select: ['imgBlob'],
    });

    if (!abrigo || !abrigo.imgBlob) {
      throw new NotFoundException(`Imagem do abrigo ${nomeAbrigo} não encontrada.`);
    }

    return abrigo.imgBlob;
  }
}
