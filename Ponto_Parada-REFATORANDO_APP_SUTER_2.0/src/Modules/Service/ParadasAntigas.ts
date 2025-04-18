import { Injectable, NotFoundException } from '@nestjs/common';
import { ParadasAntigasRepository } from '../Repository/ParadasAntigas';

@Injectable()
export class ParadasAntigasService {
  constructor(
    private readonly ParadasAntigasRepository: ParadasAntigasRepository,
  ) {}

  async findAll(): Promise<any[]> {
    const pontosParada = await this.ParadasAntigasRepository.all();
    return pontosParada;
  }  

  async findAllPontosParadaRA(searchTerm: string): Promise<any[]> {
    const pontosParada = await this.ParadasAntigasRepository.findParadasAntigasRA(searchTerm);
    return pontosParada;
  }
  
  async findAllPontosParadaBacias(searchTerm: string): Promise<any[]> {
    const pontosParada = await this.ParadasAntigasRepository.findParadasAntigasBacias(searchTerm);
    return pontosParada;
  }
  
}
