import { Controller, Get, Param } from '@nestjs/common';
import { BaciasService } from '../Service/Bacias';
import { Bacias } from '../Entity/Bacias';

@Controller('bacias')
export class BaciasController {
  constructor(private readonly BaciasService: BaciasService) {}

  @Get()
  async getAllBacias(): Promise<Bacias[]> {
    return this.BaciasService.findAll();
  }

  @Get(':descBacia')
  async getBaciaByDesc(@Param('descBacia') descBacia: string): Promise<Bacias | null> {
    return this.BaciasService.findByDescBacia(descBacia);
  }
}
