import { Injectable, HttpException, HttpStatus, NotFoundException } from '@nestjs/common';
import { PontoParadaRepository } from '../Repository/PontoParada';
import { generateImageLink } from '../Utils/PontoParada';

@Injectable()
export class PontoParadaService {
    constructor(private readonly pontoParadaRepository: PontoParadaRepository) {}

    async findAll(): Promise<any[]> {
        const pontosParada = await this.pontoParadaRepository.findPontosParada();
        return pontosParada.map(ponto => ({
          ...ponto,
          abrigo_img: generateImageLink(ponto.abrigo_nome),
        }));
      }

    async createPontoParada(data: any): Promise<any> {
        try {
            return await this.pontoParadaRepository.createPontoParada(data);
        } catch (error) {
            console.error("❌ Erro ao criar ponto de parada:", error);
            throw new HttpException(
                "Erro ao cadastrar ponto de parada e abrigos.",
                HttpStatus.INTERNAL_SERVER_ERROR
            );
        }
    }
    async findAllPontosParadaRA(searchTerm: string): Promise<any[]> {
        const pontosParada = await this.pontoParadaRepository.findPontosParadaRA(searchTerm);
        return pontosParada.map(ponto => ({
          ...ponto,
          abrigo_img: generateImageLink(ponto.abrigo_nome),
        }));
      }
      
      async findAllPontosParadaBacias(searchTerm: string): Promise<any[]> {
        const pontosParada = await this.pontoParadaRepository.findPontosParadaBacias(searchTerm);
        return pontosParada.map(ponto => ({
          ...ponto,
          abrigo_img: generateImageLink(ponto.abrigo_nome),
        }));
      }
    
      async findAllPontosParada(): Promise<any[]> {
        const pontosParada = await this.pontoParadaRepository.findPontosParada();
        return pontosParada.map(ponto => ({
          ...ponto,
          abrigo_img: generateImageLink(ponto.abrigo_nome),
        }));
      }
    
      async getImagemByAbrigo(abrigo_nome: string): Promise<Buffer> {
        const pontoParada = await this.pontoParadaRepository.findPontosParada();
        const abrigo = pontoParada.find(p => p.abrigo_nome === abrigo_nome);
        
        if (!abrigo || !abrigo.abrigo_img) {
          throw new NotFoundException(`Imagem do abrigo ${abrigo_nome} não encontrada.`);
        }
        return abrigo.abrigo_img;
      }
    }