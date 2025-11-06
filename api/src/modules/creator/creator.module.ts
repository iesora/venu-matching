import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CreatorService } from './creator.service';
import { CreatorController } from './creator.controller';
import { User } from '../../entities/user.entity';
import { Creator } from '../../entities/creator.entity';
import { Opus } from '../../entities/opus.entity';
import { Matching } from '../../entities/matching.entity';
import { Like } from '../../entities/like.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Creator, User, Opus, Matching, Like])],
  providers: [CreatorService],
  controllers: [CreatorController],
  exports: [CreatorService],
})
export class CreatorModule {}
