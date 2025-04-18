import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Usuario } from '../Entity/Usuario';

@Injectable()
export class UsuarioService {
  constructor(
    @InjectRepository(Usuario)
    private readonly usuarioRepository: Repository<Usuario>,
  ) {}

  async create(usuarioData: Partial<Usuario>): Promise<Usuario> {
    const usuario = this.usuarioRepository.create(usuarioData);
    return await this.usuarioRepository.save(usuario);
  }

  async findAll(): Promise<Usuario[]> {
    return await this.usuarioRepository.find();
  }

  async findById(id_usuario: number): Promise<Usuario> {
    const usuario = await this.usuarioRepository.findOne({ where: { IdUsuario: id_usuario } });
    if (!usuario) {
      throw new NotFoundException(`Usuário com ID ${id_usuario} não encontrado.`);
    }
    return usuario;
  }

  async update(id: number, usuarioData: Partial<Usuario>): Promise<Usuario> {
    const usuario = await this.findById(id);
    Object.assign(usuario, usuarioData);
    return await this.usuarioRepository.save(usuario);
  }

  async delete(id: number): Promise<void> {
    const result = await this.usuarioRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Usuário com ID ${id} não encontrado.`);
    }
  }

  async verificarDisponibilidade(
    nome: string,
    rgPessoal?: string,
    matricula?: string
  ): Promise<{ message: string; idUsuario?: number }> {
    if (!rgPessoal && !matricula) {
      throw new BadRequestException('É necessário informar RG ou matrícula.');
    }
  
    const query = this.usuarioRepository.createQueryBuilder('usuario')
      .where('usuario.NomeUsuario = :nome', { nome });
  
    if (rgPessoal) {
      query.andWhere('usuario.RgPessoal = :rgPessoal', { rgPessoal });
    } else if (matricula) {
      query.andWhere('usuario.MatriculaUsuario = :matricula', { matricula });
    }
  
    const usuario = await query.getOne();
  
    if (usuario) {
      return {
        message: 'Usuário encontrado e está disponível.',
        idUsuario: usuario.IdUsuario,
      };
    }
  
    throw new NotFoundException('Usuário não encontrado.');
  }    
}
