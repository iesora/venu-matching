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

@Controller('event')
export class EventController {
  constructor(private readonly eventService: EventService) {}

  @Get('list')
  async getEventsWithMatchingFlagTrue() {
    return this.eventService.getEventsWithMatchingFlagTrue();
  }

  @Get('detail/:id')
  async getEventDetail(@Param('id') id: number) {
    return this.eventService.getEventDetail(id);
  }

  @Post('')
  async createEvent(@Body() event: CreateEventDto) {
    return this.eventService.createEvent(event);
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

  @Patch('creator-event/:id/accept')
  async acceptCreatorEvent(@Param('id') id: number) {
    return this.eventService.acceptCreatorEvent(id);
  }
}
