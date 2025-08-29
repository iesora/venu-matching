import { Body, Controller, Get, Post, UseGuards, Req } from '@nestjs/common';
import { UserService } from './user.service';
import { User } from 'src/entities/user.entity';
import { Request as RequestType } from 'express';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
//import { RegisterUserGuard } from '../auth/register-user.guard';

export type CreateUserRequest = {
  email: string;
  password: string;
  openAt: string;
  closeAt: string;
};

export interface ChangeOpeningHoursDto {
  openAt: string;
  closeAt: string;
}

export interface RequestWithUser extends RequestType {
  user: User;
}

@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Post('')
  //@UseGuards(RegisterUserGuard)
  async createForClerk(@Body() body: CreateUserRequest) {
    console.log(body);
    return await this.userService.createUser(body);
  }

  /*
  @Get('detail')
  async getUserDetail(@Req() req: RequestWithUser) {}
  */

  @Get('dental')
  @UseGuards(JwtAuthGuard)
  async getUserDetail(@Req() req: RequestWithUser) {
    return await this.userService.getUserDental(req.user.id);
  }
}
