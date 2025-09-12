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
  id: number;
  creatorId: number;
}

@Controller('event')
export class EventController {
  constructor(private readonly eventService: EventService) {}

  @Get('matching/list')
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

  @Patch('creator-event/:eventId')
  async updateCreatorEvents(
    @Param('eventId') eventId: number,
    @Body() creatorEvent: UpdateCreatorEventDto[],
  ) {
    return this.eventService.updateCreatorEvents(eventId, creatorEvent);
  }

  @Delete('creator-event/:id')
  async deleteCreatorEvent(@Param('id') id: number) {
    return this.eventService.deleteCreatorEvent(id);
  }
}
