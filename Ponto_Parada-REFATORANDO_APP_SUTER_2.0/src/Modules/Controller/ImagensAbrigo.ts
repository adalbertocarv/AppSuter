import { Controller, Get, Param } from '@nestjs/common';
import { ImagensAbrigoService } from '../Service/ImagensAbrigo';
import { ImagensAbrigo } from '../Entity/ImagensAbrigo';

@Controller('imagens/abrigo')
export class ImagensAbrigoController {
  constructor(private readonly ImagensAbrigoService: ImagensAbrigoService) {}

  @Get()
  async getAllBacias(): Promise<ImagensAbrigo[]> {
    return this.ImagensAbrigoService.findAll();
  }
}
