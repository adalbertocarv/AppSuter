import { JwtService } from '@nestjs/jwt';

export class AuthService {
  constructor(private jwtService: JwtService) {}

  async login(usuario: any) {
    const payload = { username: usuario.email, sub: usuario.id };
    return {
      access_token: this.jwtService.sign(payload, { expiresIn: '1h' }),
    };
  }
}
