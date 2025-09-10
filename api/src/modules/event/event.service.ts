import { Injectable } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Event } from "src/entities/event.entity";
import { MatchingStatus } from "src/entities/event.entity";

@Injectable()
export class EventService {
  constructor(
    @InjectRepository(Event)
    private eventRepository: Repository<Event>
  ) {}

  async getEventsWithMatchingFlagTrue(): Promise<Event[]> {
    return this.eventRepository.find({
      relations: ["matching", "venu"],
      where: { matchingStatus: MatchingStatus.MATCHING },
    });
  }

  async getEventDetail(id: number): Promise<Event> {
    return this.eventRepository.findOne({
      where: { id },
      relations: ["matching", "matching.creator", "matching.venu"],
    });
  }
}
