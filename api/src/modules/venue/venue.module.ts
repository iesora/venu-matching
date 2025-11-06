import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { VenueService } from './venue.service';
import { VenueController } from './venue.controller';
import { Venue } from '../../entities/venue.entity';
import { User } from '../../entities/user.entity';
import { Matching } from '../../entities/matching.entity';
import { Like } from '../../entities/like.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Venue, User, Matching, Like])],
  providers: [VenueService],
  controllers: [VenueController],
  exports: [VenueService],
})
export class VenueModule {}
