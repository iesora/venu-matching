import { Controller, Get, UseGuards, Post, Body, Req } from '@nestjs/common';
import { JwtAuthGuard } from './jwt-auth.guard';
import { User } from '../../entities/user.entity';
import { AuthService } from './auth.service';

export type LoginUserRequest = {
  email: string;
  password: string;
};

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @UseGuards(JwtAuthGuard)
  @Get('authenticate')
  authenticate(@Req() request) {
    const user: User = request.user;
    user.password = undefined;
    return user;
  }

  @Post('login')
  async login(@Body() body: LoginUserRequest) {
    return await this.authService.login(body);
  }

  @Post('admin/login')
  async loginForAdmin(@Body() body: LoginUserRequest) {
    return await this.authService.loginForAdmin(body);
  }
}
