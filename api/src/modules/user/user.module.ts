import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserService } from './user.service';
import { UserController } from './user.controller';
import { User } from '../../entities/user.entity';
import { Dental } from '../../entities/dental.entity';
import { Staff } from '../../entities/staff.entity';

@Module({
  imports: [TypeOrmModule.forFeature([User, Dental, Staff])],
  providers: [UserService],
  controllers: [UserController],
})
export class UserModule {}
