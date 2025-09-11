import {
  Controller,
  Post,
  Body,
  Req,
  UseGuards,
  Get,
  Patch,
  Param,
} from '@nestjs/common';
import { MatchingService } from './matching.service';
import { RequestWithUser } from '../user/user.controller';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

export interface CreateMatchingFromCreatorRequest {
  creatorId: number;
  venueId: number;
}

export interface CreateMatchingFromVenueRequest {
  venueId: number;
  creatorId: number;
}

export interface CreateMatchingEventRequest {
  title: string;
  description: string;
  startDate: Date;
  endDate: Date;
}

@Controller('matching')
export class MatchingController {
  constructor(private readonly matchingService: MatchingService) {}

  @Post('request/creator')
  @UseGuards(JwtAuthGuard)
  async createMatchingFromCreator(
    @Body() matching: CreateMatchingFromCreatorRequest,
    @Req() req: RequestWithUser,
  ) {
    return this.matchingService.createMatchingFromCreator(matching, req.user);
  }

  @Post('request/venue')
  @UseGuards(JwtAuthGuard)
  async createMatchingFromVenue(
    @Body() matching: CreateMatchingFromVenueRequest,
    @Req() req: RequestWithUser,
  ) {
    return this.matchingService.createMatchingFromVenue(matching, req.user);
  }

  @Get('request')
  @UseGuards(JwtAuthGuard)
  async getRequestMatchings(@Req() req: RequestWithUser) {
    console.log(req.user);
    return this.matchingService.getRequestMatchings(req.user);
  }

  @Patch('request/:matchingId')
  @UseGuards(JwtAuthGuard)
  async acceptMatchingRequest(
    @Param('matchingId') matchingId: number,
    @Req() req: RequestWithUser,
  ) {
    return this.matchingService.acceptMatchingRequest(matchingId, req.user);
  }

  @Get('completed')
  @UseGuards(JwtAuthGuard)
  async getCompletedMatchings(@Req() req: RequestWithUser) {
    return this.matchingService.getCompletedMatchings(req.user);
  }

  @Get('events/:matchingId')
  @UseGuards(JwtAuthGuard)
  async getMatchingEvents(@Param('matchingId') matchingId: number) {
    return this.matchingService.getMatchingEvents(matchingId);
  }

  @Post('events/:matchingId')
  @UseGuards(JwtAuthGuard)
  async createMatchingEvent(
    @Param('matchingId') matchingId: number,
    @Body() event: CreateMatchingEventRequest,
  ) {
    return this.matchingService.createMatchingEvent(matchingId, event);
  }

  @Patch('events/:eventId/accept')
  @UseGuards(JwtAuthGuard)
  async acceptMatchingEvent(
    @Param('eventId') eventId: number,
    @Req() req: RequestWithUser,
  ) {
    return this.matchingService.acceptMatchingEvent(eventId, req.user);
  }

  @Patch('events/:eventId/reject')
  @UseGuards(JwtAuthGuard)
  async rejectMatchingEvent(
    @Param('eventId') eventId: number,
    @Req() req: RequestWithUser,
  ) {
    return this.matchingService.rejectMatchingEvent(eventId, req.user);
  }
}
