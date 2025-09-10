import { Controller, Get, Param } from "@nestjs/common";
import { EventService } from "./event.service";

@Controller("event")
export class EventController {
  constructor(private readonly eventService: EventService) {}

  @Get("matching/list")
  async getEventsWithMatchingFlagTrue() {
    return this.eventService.getEventsWithMatchingFlagTrue();
  }

  @Get("detail/:id")
  async getEventDetail(@Param("id") id: number) {
    return this.eventService.getEventDetail(id);
  }
}
