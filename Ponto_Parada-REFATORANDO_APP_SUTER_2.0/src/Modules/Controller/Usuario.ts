import { Controller, Get, Post, Body, Param, Delete, Put, Query, BadRequestException } from '@nestjs/common';
import { UsuarioService } from '../Service/Usuario';
import { Usuario } from '../Entity/Usuario';

@Controller('usuarios')
export class UsuarioController {
  constructor(private readonly usuarioService: UsuarioService) {}

  @Post()
  async create(@Body() usuarioData: Partial<Usuario>): Promise<Usuario> {
    return await this.usuarioService.create(usuarioData);
  }

  @Get()
  async findAll(): Promise<Usuario[]> {
    return await this.usuarioService.findAll();
  }

  @Get(':id')
  async findById(@Param('id') id: number): Promise<Usuario> {
    return await this.usuarioService.findById(id);
  }

  @Put(':id')
  async update(@Param('id') id: number, @Body() usuarioData: Partial<Usuario>): Promise<Usuario> {
    return await this.usuarioService.update(id, usuarioData);
  }

  @Delete(':id')
  async delete(@Param('id') id: number): Promise<void> {
    await this.usuarioService.delete(id);
  }

  @Post('verificar')
  async verificarDisponibilidade(
    @Body() data: { nome: string; rgPessoal?: string; matricula?: string }
  ): Promise<{ message: string; idUsuario?: number }> {
    const { nome, rgPessoal, matricula } = data;

    if (!nome || (!rgPessoal && !matricula)) {
      throw new BadRequestException(
        'Informe o nome e o RG ou a matrícula.'
      );
    }

    return this.usuarioService.verificarDisponibilidade(nome, rgPessoal, matricula);
  }  
}
