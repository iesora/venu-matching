import {
  Controller,
  Post,
  Body,
  Req,
  UseGuards,
  Get,
  Patch,
  Param,
} from "@nestjs/common";
import { MatchingService } from "./matching.service";
import { Matching } from "../../entities/matching.entity";
import { RequestWithUser } from "../user/user.controller";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";

export interface CreateMatchingFromCreatorRequest {
  creatorId: number;
  venuId: number;
}

export interface CreateMatchingFromVenuRequest {
  venuId: number;
  creatorId: number;
}

@Controller("matching")
export class MatchingController {
  constructor(private readonly matchingService: MatchingService) {}

  @Post("request/creator")
  @UseGuards(JwtAuthGuard)
  async createMatchingFromCreator(
    @Body() matching: CreateMatchingFromCreatorRequest,
    @Req() req: RequestWithUser
  ) {
    return this.matchingService.createMatchingFromCreator(matching, req.user);
  }

  @Post("request/venu")
  @UseGuards(JwtAuthGuard)
  async createMatchingFromVenu(
    @Body() matching: CreateMatchingFromVenuRequest,
    @Req() req: RequestWithUser
  ) {
    return this.matchingService.createMatchingFromVenu(matching, req.user);
  }

  @Get("request")
  @UseGuards(JwtAuthGuard)
  async getRequestMatchings(@Req() req: RequestWithUser) {
    console.log(req.user);
    return this.matchingService.getRequestMatchings(req.user);
  }

  @Patch("request/:matchingId")
  @UseGuards(JwtAuthGuard)
  async acceptMatchingRequest(
    @Param("matchingId") matchingId: number,
    @Req() req: RequestWithUser
  ) {
    return this.matchingService.acceptMatchingRequest(matchingId, req.user);
  }
}
