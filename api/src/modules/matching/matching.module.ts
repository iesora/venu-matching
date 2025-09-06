import { Module } from "@nestjs/common";
import { MatchingController } from "./matching.controller";
import { MatchingService } from "./matching.service";
import { TypeOrmModule } from "@nestjs/typeorm";
import { Matching } from "src/entities/matching.entity";
import { Creator } from "src/entities/creator.entity";
import { Venu } from "src/entities/venu.entity";

@Module({
  imports: [TypeOrmModule.forFeature([Matching, Creator, Venu])],
  controllers: [MatchingController],
  providers: [MatchingService],
})
export class MatchingModule {}
