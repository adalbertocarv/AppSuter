import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ImagensAbrigo } from '../Entity/ImagensAbrigo';

@Injectable()
export class ImagensAbrigoService {
  constructor(
    @InjectRepository(ImagensAbrigo)
    private readonly ImagensAbrigoRepository: Repository<ImagensAbrigo>,
  ) {}

  async findAll(): Promise<ImagensAbrigo[]> {
    return await this.ImagensAbrigoRepository.find();
  }
}
