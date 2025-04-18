import { Controller, Post, Body, HttpException, HttpStatus, Get, Param, NotFoundException, Res } from '@nestjs/common';
import { PontoParadaService } from '../Service/PontoParada';
import { PontoParada } from '../Entity/PontoParada';
import { FileFieldsInterceptor, FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import { Response } from 'express';

@Controller('pontos')
export class PontoParadaController {
    constructor(private readonly pontoParadaService: PontoParadaService) {}

    @Get()
    async getAllRas(): Promise<PontoParada[]> {
      return this.pontoParadaService.findAll();
    }

    @Post('criar')
    async createPontoParada(@Body() data: any): Promise<any> {
        try {
            return await this.pontoParadaService.createPontoParada(data);
        } catch (error) {
            console.error("❌ Erro na requisição de criação de ponto de parada:", error);
            throw new HttpException(
                "Erro ao processar a requisição.",
                HttpStatus.INTERNAL_SERVER_ERROR
            );
        }
    }
    @Get('/novos/pontos/ras/:search')
  async getPontosParadaRa(@Param('search') searchTerm: string) {
    return await this.pontoParadaService.findAllPontosParadaRA(searchTerm);
  }
  
  @Get('/novos/pontos/bacias/:search')
  async getPontosParadaBacias(@Param('search') searchTerm: string) {
    return await this.pontoParadaService.findAllPontosParadaBacias(searchTerm);
  }
  

  @Get('/novos/pontos')
  async getPontosParada() {
    return await this.pontoParadaService.findAllPontosParada();
  }

  @Get(':abrigo_nome/imagem')
  async getAbrigoImagem(@Param('abrigo_nome') abrigoNome: string, @Res() res: Response) {
    try {
      const imagemBuffer = await this.pontoParadaService.getImagemByAbrigo(abrigoNome);
      res.setHeader('Content-Type', 'image/png');
      return res.send(imagemBuffer);
    } catch (error) {
      throw new NotFoundException(`Imagem do abrigo ${abrigoNome} não encontrada.`);
    }
  }
}
