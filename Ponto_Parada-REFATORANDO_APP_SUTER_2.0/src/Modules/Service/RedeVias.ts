import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RedeVias } from '../Entity/RedeVias';
import { RedeViasRepository } from '../Repository/RedeVias';

@Injectable()
export class RedeViasService {
  constructor(
    @InjectRepository(RedeVias)
    private readonly redeViasRepository: Repository<RedeVias>,
    private readonly customRedeViasRepository: RedeViasRepository, // Injetando o repositório customizado
  ) {}

  async findAll(): Promise<RedeVias[]> {
    return await this.redeViasRepository.find();
  }

  async findViasProximas(longitude: number, latitude: number): Promise<any[]> {
    return await this.customRedeViasRepository.findViasProximas(longitude, latitude);
  }
}
