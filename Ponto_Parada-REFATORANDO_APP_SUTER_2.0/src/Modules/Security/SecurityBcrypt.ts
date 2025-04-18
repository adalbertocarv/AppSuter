import * as bcrypt from 'bcrypt';

export class UsuarioService {
  async hashSenha(senha: string): Promise<string> {
    const salt = await bcrypt.genSalt(10);
    return bcrypt.hash(senha, salt);
  }

  async validarSenha(senha: string, hash: string): Promise<boolean> {
    return bcrypt.compare(senha, hash);
  }
}
