import { Controller, Get, Param } from '@nestjs/common';
import { RedeViasService } from '../Service/RedeVias';
import { RedeVias } from '../Entity/RedeVias';

@Controller('vias')
export class RedeViasController {
  constructor(private readonly redeViasService: RedeViasService) {}

  @Get()
  async getAllVias(): Promise<RedeVias[]> {
    return this.redeViasService.findAll();
  }

  @Get('proximas/:longitude/:latitude')
  async getViasProximas(
    @Param('longitude') longitude: string,
    @Param('latitude') latitude: string
  ): Promise<any[]> {
    return this.redeViasService.findViasProximas(parseFloat(longitude), parseFloat(latitude));
  }
}
