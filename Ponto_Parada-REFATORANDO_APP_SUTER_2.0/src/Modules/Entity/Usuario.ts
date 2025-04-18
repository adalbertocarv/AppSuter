import { Entity, Column, PrimaryGeneratedColumn, BeforeInsert, BeforeUpdate } from 'typeorm';
import { Exclude } from 'class-transformer';
import * as bcrypt from 'bcrypt';
import { IsEmail, Length, IsBoolean } from 'class-validator';

@Entity({ schema: 'ponto_parada', name: 'tab_usuario' })
export class Usuario {

  @PrimaryGeneratedColumn({ 
    name: 'id_usuario' })
    IdUsuario: number;

  @Column({ 
      type: 'varchar', 
      name: 'nome', 
      length: 50 })
  @Length(3, 50, { message: 'O nome do usuário deve ter entre 3 e 50 caracteres.' })
  NomeUsuario: string;

  @Column({ 
      type: 'varchar', 
      name: 'matricula', 
      length: 10 })
  @Length(1, 10, { message: 'A matrícula deve ter no máximo 10 caracteres.' })
  MatriculaUsuario: string;

  @Column({ 
      type: 'varchar', 
      name: 'email', 
      length: 50, 
      unique: true })
  @IsEmail({}, { message: 'O email informado não é válido.' })
  EmailUsuario: string;

  @Exclude()
  @Column({ 
      type: 'varchar', 
      name: 'senha', 
      length: 255 })
  @Length(6, 50, { message: 'A senha deve ter entre 6 e 50 caracteres.' })
  SenhaUsuario: string;

  @Exclude()
  @Column({ 
      type: 'varchar', 
      name: 'rg_pessoal', 
      length: 255 })
  RgPessoal: string;

  @Column({ 
      type: 'timestamp', 
      name: 'criado_em', 
      default: () => 'CURRENT_TIMESTAMP' })
  CreatedAt: Date;

  @Column({ 
      type: 'timestamp', 
      name: 'atualizado_em', 
      default: () => 'CURRENT_TIMESTAMP' })
  UpdatedAt: Date;

  /*@Column({ 
      type: 'timestamp', 
      name: 'last_login', 
      nullable: true })
  LastLogin: Date;*/

  /**
   * Hook executado antes de inserir ou atualizar o usuário.
   * Aplica o hash na senha automaticamente usando bcrypt.
   */
  @BeforeInsert()
  @BeforeUpdate()
  async hashPassword() {
    if (this.SenhaUsuario) {
      const salt = await bcrypt.genSalt(10);
      this.SenhaUsuario = await bcrypt.hash(this.SenhaUsuario, salt);
    }
  }
}