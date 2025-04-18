import { Body, Controller, Get, Param, Post, Res, NotFoundException, Query } from '@nestjs/common';
import { Response } from 'express';
import { ParadasAntigasService } from '../Service/ParadasAntigas';
import { ParadasAntigas } from '../Entity/ParadasAntigas';

@Controller('paradas/antigas')
export class ParadasAntigasController {
  constructor(private readonly ParadasAntigasService: ParadasAntigasService) {}

  @Get()
  async getAll(): Promise<ParadasAntigas[]> {
    return this.ParadasAntigasService.findAll();
  }

  @Get('/ras/:search')
  async getPontosParadaRa(@Param('search') searchTerm: string) {
    return await this.ParadasAntigasService.findAllPontosParadaRA(searchTerm);
  }
  
  @Get('/bacias/:search')
  async getPontosParadaBacias(@Param('search') searchTerm: string) {
    return await this.ParadasAntigasService.findAllPontosParadaBacias(searchTerm);
  }
}
