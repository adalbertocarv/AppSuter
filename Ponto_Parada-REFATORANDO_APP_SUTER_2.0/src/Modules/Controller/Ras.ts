import { Controller, Get, Param } from '@nestjs/common';
import { RasService } from '../Service/Ras';
import { Ras } from '../Entity/Ras';

@Controller('ras')
export class RasController {
  constructor(private readonly RasService: RasService) {}

  @Get()
  async getAllRas(): Promise<Ras[]> {
    return this.RasService.findAll();
  }

  @Get(':descNome')
  async getBaciaByDesc(@Param('descNome') descNome: string): Promise<Ras | null> {
    return this.RasService.findByDescNome(descNome);
  }
}
