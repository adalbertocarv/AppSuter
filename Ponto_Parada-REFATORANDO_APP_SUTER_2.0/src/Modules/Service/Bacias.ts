import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Bacias } from '../Entity/Bacias';

@Injectable()
export class BaciasService {
  constructor(
    @InjectRepository(Bacias)
    private readonly BaciasRepository: Repository<Bacias>,
  ) {}

  async findAll(): Promise<Bacias[]> {
    return await this.BaciasRepository.find();
  }

  async findByDescBacia(descBacia: string): Promise<Bacias | null> {
    return await this.BaciasRepository.findOne({
      where: { descBacia },
    });
  }
}
