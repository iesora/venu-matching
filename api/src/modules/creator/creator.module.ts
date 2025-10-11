import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CreatorService } from './creator.service';
import { CreatorController } from './creator.controller';
import { User } from '../../entities/user.entity';
import { Creator } from '../../entities/creator.entity';
import { Opus } from '../../entities/opus.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Creator, User, Opus])],
  providers: [CreatorService],
  controllers: [CreatorController],
  exports: [CreatorService],
})
export class CreatorModule {}
