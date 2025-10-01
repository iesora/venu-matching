import { Module } from "@nestjs/common";
import { MatchingController } from "./matching.controller";
import { MatchingService } from "./matching.service";
import { TypeOrmModule } from "@nestjs/typeorm";
import { Matching } from "src/entities/matching.entity";
import { Creator } from "src/entities/creator.entity";
import { Venue } from "src/entities/venue.entity";
import { Event } from "src/entities/event.entity";
import { User } from "src/entities/user.entity";

@Module({
  imports: [TypeOrmModule.forFeature([Matching, Creator, Venue, Event, User])],
  controllers: [MatchingController],
  providers: [MatchingService],
})
export class MatchingModule {}
