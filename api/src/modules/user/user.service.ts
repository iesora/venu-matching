import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from 'src/entities/user.entity';
import { CreateUserRequest } from './user.controller';

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async createUser(user: CreateUserRequest) {
    const existUser = await this.userRepository.findOne({
      where: { email: user.email },
    });
    if (existUser) {
      throw new HttpException('user already exists', HttpStatus.BAD_REQUEST);
    }
    const newUser = new User();
    newUser.password = User.encryptPassword(user.password);
    newUser.email = user.email;

    return await this.userRepository.save(newUser);
  }
}
