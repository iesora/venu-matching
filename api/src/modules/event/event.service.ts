import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { Event } from 'src/entities/event.entity';
import { CreateEventDto, UpdateCreatorEventDto } from './event.controller';
import { CreatorEvent } from 'src/entities/createrEvent.entity';
import { Venue } from 'src/entities/venue.entity';
import { Creator } from 'src/entities/creator.entity';

@Injectable()
export class EventService {
  constructor(
    @InjectRepository(Event)
    private eventRepository: Repository<Event>,
    @InjectRepository(CreatorEvent)
    private creatorEventRepository: Repository<CreatorEvent>,
    @InjectRepository(Venue)
    private venueRepository: Repository<Venue>,
    @InjectRepository(Creator)
    private creatorRepository: Repository<Creator>,
  ) {}

  async getEventsWithMatchingFlagTrue(): Promise<Event[]> {
    return this.eventRepository.find({
      relations: ['matching', 'venue'],
      //   where: { matchingStatus: MatchingStatus.MATCHING },
    });
  }

  async getEventDetail(id: number): Promise<Event> {
    return this.eventRepository.findOne({
      where: { id },
      //   relations: ['matching', 'matching.creator', 'matching.venue'],
    });
  }

  //venueを紐づけてevent作成、さらにそのeventをcreatorごとに紐づけてcreatorEvent作成
  async createEvent(event: CreateEventDto): Promise<CreatorEvent[]> {
    //venueを取得
    const existVenue = await this.venueRepository.findOne({
      where: { id: event.venueId },
    });
    if (!existVenue) {
      throw new HttpException('Venue not found', HttpStatus.NOT_FOUND);
    }

    //event作成
    const newEvent = new Event();
    newEvent.title = event.title;
    newEvent.description = event.description;
    newEvent.startDate = new Date(event.startDate);
    newEvent.endDate = new Date(event.endDate);
    newEvent.venue = existVenue;
    const savedEvent = await this.eventRepository.save(newEvent);

    //creatorを複数取得
    const existCreators = await this.creatorRepository.find({
      where: { id: In(event.creatorIds) },
    });
    if (existCreators.length !== event.creatorIds.length) {
      throw new HttpException('Creator not found', HttpStatus.NOT_FOUND);
    }

    //保存したeventとcreatorを紐づけてcreator一人ずつにcreatorEventを作成
    const newCreatorEvents = existCreators.map((creator) => {
      const newCreatorEvent = new CreatorEvent();
      newCreatorEvent.event = savedEvent;
      newCreatorEvent.creator = creator;
      return newCreatorEvent;
    });
    return await this.creatorEventRepository.save(newCreatorEvents);
  }

  //idがないceveは新規追加、あるceveは削除して新規追加,bodyにないがdbにあるcreatorEventは削除
  async updateCreatorEvents(
    eventId: number,
    creatorEvents: UpdateCreatorEventDto[],
  ): Promise<CreatorEvent[]> {
    //対象のeventを取得
    const existEvent = await this.eventRepository.findOne({
      where: { id: eventId },
    });
    if (!existEvent) {
      throw new HttpException('Event not found', HttpStatus.NOT_FOUND);
    }

    //対象のeventに紐づくcreatorEventはすべて削除
    const existCreatorEvents = await this.creatorEventRepository.find({
      where: { event: { id: eventId } },
    });
    await this.creatorEventRepository.remove(existCreatorEvents);

    //creatorを複数取得
    const creatorIds = creatorEvents.map(
      (creatorEvent) => creatorEvent.creatorId,
    );
    const existCreators = await this.creatorRepository.find({
      where: {
        id: In(creatorIds),
      },
    });
    if (existCreators.length !== creatorEvents.length) {
      throw new HttpException('Creator not found', HttpStatus.NOT_FOUND);
    }

    //保存したeventとcreatorを紐づけてcreator一人ずつにcreatorEventを作成
    const newCreatorEvents = existCreators.map((creator) => {
      const newCreatorEvent = new CreatorEvent();
      newCreatorEvent.event = existEvent;
      newCreatorEvent.creator = creator;
      return newCreatorEvent;
    });
    return await this.creatorEventRepository.save(newCreatorEvents);
  }

  async deleteCreatorEvent(id: number): Promise<void> {
    const existCreatorEvent = await this.creatorEventRepository.findOne({
      where: { id },
    });
    await this.creatorEventRepository.remove(existCreatorEvent);
  }
}
