import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { VenuService } from './venu.service';
import { VenuController } from './venu.controller';
import { Venu } from '../../entities/venu.entity';
import { User } from '../../entities/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Venu, User])],
  providers: [VenuService],
  controllers: [VenuController],
  exports: [VenuService],
})
export class VenuModule {}
