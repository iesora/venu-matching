import { Module } from "@nestjs/common";
import { MatchingController } from "./matching.controller";
import { MatchingService } from "./matching.service";
import { TypeOrmModule } from "@nestjs/typeorm";
import { Matching } from "src/entities/matching.entity";
import { Creator } from "src/entities/creator.entity";
import { Venue } from "src/entities/venue.entity";
import { Event } from "src/entities/event.entity";
import { User } from "src/entities/user.entity";
import { ChatGroup } from "src/entities/chatGroup.entity";
import { ChatGroupUser } from "src/entities/chatGroupUser.entity";

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Matching,
      Creator,
      Venue,
      Event,
      User,
      ChatGroup,
      ChatGroupUser,
    ]),
  ],
  controllers: [MatchingController],
  providers: [MatchingService],
})
export class MatchingModule {}
