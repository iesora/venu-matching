import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from 'src/entities/user.entity';
import { CreateUserRequest } from './user.controller';
import { Staff } from 'src/entities/staff.entity';

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Staff)
    private readonly staffRepository: Repository<Staff>,
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

  async getUserDental(userId: number) {
    const user = await this.userRepository.findOne({
      where: { id: userId },
      relations: ['dental'],
    });

    if (!user) {
      throw new HttpException('User not found', HttpStatus.NOT_FOUND);
    }

    let staffs = [];

    // userRoleがdentalの場合は、そのdentalとstaffを取得
    if (user.role === 'dental' && user.dental) {
      staffs = await this.staffRepository.find({
        where: {
          dental: { id: user.dental.id },
          deleteFlag: false,
        },
        relations: ['dental'],
      });
    }

    return {
      dental: user.dental,
      staffs: staffs,
    };
  }
}
