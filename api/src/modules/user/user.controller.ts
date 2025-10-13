import {
  Body,
  Controller,
  Post,
  Patch,
  Req,
  UseGuards,
  Param,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { UserService } from './user.service';
import { User, UserMode } from 'src/entities/user.entity';
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

  @UseGuards(JwtAuthGuard)
  @Patch('mode-switch/:mode')
  async modeSwitch(
    @Req() request: RequestWithUser,
    @Param('mode') mode: UserMode,
  ) {
    if (!request.user) {
      throw new HttpException('user not found', HttpStatus.NOT_FOUND);
    }
    console.log('mode-switch-is-running: ', mode);
    return await this.userService.modeSwitch(request.user.id, mode);
  }
}
