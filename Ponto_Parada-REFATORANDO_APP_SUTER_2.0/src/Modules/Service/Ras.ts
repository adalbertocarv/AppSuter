import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Ras } from '../Entity/Ras';

@Injectable()
export class RasService {
  constructor(
    @InjectRepository(Ras)
    private readonly RasRepository: Repository<Ras>,
  ) {}

  async findAll(): Promise<Ras[]> {
    return await this.RasRepository.find();
  }

  async findByDescNome(descNome: string): Promise<Ras | null> {
    return await this.RasRepository.findOne({
      where: { descNome },
    });
  }
}
