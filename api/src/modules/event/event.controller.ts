import {
  Controller,
  Get,
  Param,
  Post,
  Body,
  Patch,
  Delete,
} from '@nestjs/common';
import { EventService } from './event.service';
import { AcceptStatus } from 'src/entities/createrEvent.entity';
import { EventStatus, RequestorType } from 'src/entities/event.entity';

export interface CreateEventDto {
  title: string;
  description: string;
  startDate: Date;
  endDate: Date;
  venueId: number;
  creatorIds: number[];
}

export interface UpdateCreatorEventDto {
  eventId: number;
  creatorIds: number[];
}

export interface UpdateEventOverviewDto {
  eventId: number;
  venueId: number;
  title: string;
  description: string;
  startDate: Date;
  endDate: Date;
}

export interface ResponseCreatorEventDto {
  creatorEventId: number;
  acceptStatus: AcceptStatus;
}

export interface UpdateAcceptStatusDto {
  eventId: number;
  acceptStatus: EventStatus;
}

export interface CreateMatchingEventDto {
  matchingId: number;
  title: string;
  description: string;
  startDate: Date;
  endDate: Date;
  requestorType: RequestorType;
}

export interface UpdateMatchingEventDto {
  eventId: number;
  title: string;
  description: string;
  startDate: Date;
  endDate: Date;
}

@Controller('event')
export class EventController {
  constructor(private readonly eventService: EventService) {}

  @Get('list')
  async getEventlist() {
    return this.eventService.getEventlist();
  }

  @Get('matching/:matchingId')
  async getEventlistByMatchingId(@Param('matchingId') matchingId: number) {
    return this.eventService.getEventlistByMatchingId(matchingId);
  }

  @Get('detail/:id')
  async getEventDetail(@Param('id') id: number) {
    return this.eventService.getEventDetail(id);
  }

  @Post('')
  async createEvent(@Body() event: CreateEventDto) {
    return this.eventService.createEvent(event);
  }

  @Patch('overview')
  async updateEventOverview(@Body() event: UpdateEventOverviewDto) {
    return this.eventService.updateEventOverview(event);
  }

  @Patch('creator-event')
  async updateCreatorEvents(@Body() creatorEvent: UpdateCreatorEventDto) {
    return this.eventService.updateCreatorEvents(creatorEvent);
  }

  @Get('creator-event/:userId')
  async getCreatorEventsByUserId(@Param('userId') userId: number) {
    return this.eventService.getCreatorEventsByUserId(userId);
  }

  @Delete('creator-event/:id')
  async deleteCreatorEvent(@Param('id') id: number) {
    return this.eventService.deleteCreatorEvent(id);
  }

  //   @Patch('creator-event/:id/accept')
  @Patch('creator-event/response')
  async responseCreatorEvent(@Body() body: ResponseCreatorEventDto) {
    return this.eventService.responseCreatorEvent(body);
  }

  @Delete(':id')
  async deleteEvent(@Param('id') id: number) {
    return this.eventService.deleteEvent(id);
  }

  @Post('matching')
  async createMatchingEvent(@Body() body: CreateMatchingEventDto) {
    console.log('createMatchingEvent: ', body);
    return this.eventService.createMatchingEvent(body);
  }

  @Patch('matching')
  async updateMatchingEvent(@Body() body: UpdateMatchingEventDto) {
    return this.eventService.updateMatchingEvent(body);
  }

  @Patch('status')
  async updateAcceptStatus(@Body() body: UpdateAcceptStatusDto) {
    return this.eventService.updateAcceptStatus(body);
  }
}
