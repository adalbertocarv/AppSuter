import {Controller, Get, Post, Body, Param, Res, UploadedFile, UseInterceptors, NotFoundException} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { Response } from 'express';
import { TipoPatologiaService } from '../Service/TipoPatologia';
  
    interface TipoPatologiaDTO {
      idTipoPatologia?: number;
      DescPatologia: string;
      imgBlob?: Buffer;
    }
  
    @Controller('tipo/patologia')
    export class TipoPatologiaController {
    constructor(private readonly tipoPatologiaService: TipoPatologiaService) {}
  
    /**
     * Lista todas as patologias disponíveis
     */
    @Get()
    async getAllPatologias(): Promise<TipoPatologiaDTO[]> {
      return this.tipoPatologiaService.findAll();
    }
  
    /**
     * Obtém uma patologia específica pelo nome
     * @param DescPatologia Nome da patologia
     */
    @Get(':DescPatologia')
    async getPatologiaByNome(@Param('DescPatologia') DescPatologia: string): Promise<TipoPatologiaDTO | null> {
      return this.tipoPatologiaService.findByTipoPatologia(DescPatologia);
    }
  
    /**
     * Retorna a imagem associada a uma patologia específica
     * @param descPatologia Nome da patologia
     */
    @Get(':descPatologia/imagem')
    async getImagem(@Param('descPatologia') descPatologia: string, @Res() res: Response) {
      try {
        const imagemBuffer = await this.tipoPatologiaService.getImagemByNome(descPatologia);
  
        if (!imagemBuffer) {
          throw new NotFoundException(`Imagem da patologia ${descPatologia} não encontrada.`);
        }
  
        res.setHeader('Content-Type', 'image/png');
        return res.send(imagemBuffer);
      } catch (error) {
        throw new NotFoundException(`Erro ao buscar imagem: ${error.message}`);
      }
    }
  
    /**
     * Cria um novo registro de TipoPatologia no banco de dados
     * Aceita um nome e uma imagem (upload)
     * @param data Dados da patologia
     */
    @Post()
    @UseInterceptors(FileInterceptor('imgBlob'))  // Permite upload de arquivos
    async createPatologia(
      @Body() body: { DescPatologia: string }, 
      @UploadedFile() file: Express.Multer.File
    ): Promise<TipoPatologiaDTO> {
      if (!body.DescPatologia) {
        throw new NotFoundException('O campo DescPatologia é obrigatório.');
      }
  
      const patologiaData: TipoPatologiaDTO = {
        DescPatologia: body.DescPatologia,
        imgBlob: file?.buffer || null,
      };
  
      return this.tipoPatologiaService.createTipoPatologia(patologiaData);
    }
  }
  