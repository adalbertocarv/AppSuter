import { Controller, Get, Param, Res, NotFoundException } from '@nestjs/common';
import { Response } from 'express';
import { TipoAbrigoService } from '../Service/TipoAbrigo';

interface TipoAbrigoDTO {
  idTipoAbrigo: number;
  nomeAbrigo: string;
  inicioVigencia: string;
  fimVigencia: string;
  linkImagem: string;
}

@Controller('tipo/abrigo')
export class TipoAbrigoController {
  constructor(private readonly TipoAbrigoService: TipoAbrigoService) {}

  @Get()
  async getAllAbregos(): Promise<TipoAbrigoDTO[]> {
    return this.TipoAbrigoService.findAll();
  }

  @Get(':nomeAbrigo')
  async getAbrigoByNome(@Param('nomeAbrigo') nomeAbrigo: string): Promise<TipoAbrigoDTO | null> {
    return this.TipoAbrigoService.findByTipoAbrigo(nomeAbrigo);
  }

  @Get(':nomeAbrigo/imagem')
  async getImagem(@Param('nomeAbrigo') nomeAbrigo: string, @Res() res: Response) {
    try {
      const imagemBuffer = await this.TipoAbrigoService.getImagemByNome(nomeAbrigo);
      
      if (!imagemBuffer) {
        throw new NotFoundException(`Imagem do abrigo ${nomeAbrigo} não encontrada.`);
      }

      res.setHeader('Content-Type', 'image/png');
      return res.send(imagemBuffer);
    } catch (error) {
      throw new NotFoundException(`Erro ao buscar imagem: ${error.message}`);
    }
  }
}
