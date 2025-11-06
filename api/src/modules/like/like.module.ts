import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Like } from '../../entities/like.entity';
import { User } from '../../entities/user.entity';
import { Venue } from '../../entities/venue.entity';
import { Creator } from '../../entities/creator.entity';
import { LikeService } from './like.service';
import { LikeController } from './like.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Like, User, Venue, Creator])],
  controllers: [LikeController],
  providers: [LikeService],
  exports: [LikeService],
})
export class LikeModule {}
