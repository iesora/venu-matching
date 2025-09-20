import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { Event } from 'src/entities/event.entity';
import {
  CreateEventDto,
  UpdateCreatorEventDto,
  UpdateEventOverviewDto,
  ResponseCreatorEventDto,
} from './event.controller';
import { AcceptStatus, CreatorEvent } from 'src/entities/createrEvent.entity';
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

  async getEventlist(): Promise<Event[]> {
    const existEvents = await this.eventRepository
      .createQueryBuilder('event')
      .leftJoinAndSelect('event.venue', 'venue')
      .leftJoinAndSelect(
        'event.creatorEvents',
        'creatorEvents',
        'creatorEvents.acceptStatus = :acceptStatus',
        {
          acceptStatus: AcceptStatus.ACCEPTED,
        },
      )
      .leftJoinAndSelect('creatorEvents.creator', 'creator')
      .getMany();
    return existEvents;
  }

  async getEventDetail(id: number): Promise<Event> {
    const existEvent = await this.eventRepository
      .createQueryBuilder('event')
      .leftJoinAndSelect('event.venue', 'venue')
      .leftJoinAndSelect('venue.user', 'user')
      .where('event.id = :id', { id })
      .getOne();
    if (!existEvent) {
      throw new HttpException('Event not found', HttpStatus.NOT_FOUND);
    }
    // return existEvent;

    const existEventsCreatorEvents = await this.creatorEventRepository
      .createQueryBuilder('creatorEvent')
      .leftJoinAndSelect('creatorEvent.creator', 'creator')
      .leftJoinAndSelect('creatorEvent.event', 'event')
      .where('event.id = :id', { id })
      .andWhere('creatorEvent.deleteFlag = false')
      .getMany();
    return {
      ...existEvent,
      creatorEvents: existEventsCreatorEvents,
    };
    // return this.eventRepository.findOne({
    //   where: { id },
    //   relations: [
    //     'venue',
    //     'venue.user',
    //     'creatorEvents',
    //     'creatorEvents.creator',
    //   ],
    // });
  }

  async getCreatorEventsByUserId(userId: number): Promise<CreatorEvent[]> {
    const existCreators = await this.creatorRepository.find({
      where: { user: { id: userId } },
    });
    if (existCreators.length === 0) {
      throw new HttpException('Creator not found', HttpStatus.NOT_FOUND);
    }
    const creatorIds = existCreators.map((creator) => creator.id);
    const creatorEvents = await this.creatorEventRepository
      .createQueryBuilder('creatorEvent')
      .leftJoinAndSelect('creatorEvent.creator', 'creator')
      .leftJoinAndSelect('creatorEvent.event', 'event')
      .where('creator.id IN (:...creatorIds)', { creatorIds })
      .getMany();
    return creatorEvents;
  }

  //venueを紐づけてevent作成、さらにそのeventをcreatorごとに紐づけてcreatorEvent作成
  async createEvent(event: CreateEventDto): Promise<CreatorEvent[]> {
    console.log('event: ', event);
    console.log('event.creatorIds: ', event.creatorIds);
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
    newEvent.imageUrl = '';
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

  async updateEventOverview(event: UpdateEventOverviewDto): Promise<Event> {
    const existEvent = await this.eventRepository.findOne({
      where: { id: event.eventId },
    });
    if (!existEvent) {
      throw new HttpException('Event not found', HttpStatus.NOT_FOUND);
    }
    if (event.venueId) {
      const existVenue = await this.venueRepository.findOne({
        where: { id: event.venueId },
      });
      if (!existVenue) {
        throw new HttpException('Venue not found', HttpStatus.NOT_FOUND);
      }
      existEvent.venue = existVenue;
    }
    existEvent.title = event.title;
    existEvent.description = event.description;
    existEvent.startDate = new Date(event.startDate);
    existEvent.endDate = new Date(event.endDate);
    return await this.eventRepository.save(existEvent);
  }

  //idがないceveは新規追加、あるceveは削除して新規追加,bodyにないがdbにあるcreatorEventは削除
  async updateCreatorEvents(
    body: UpdateCreatorEventDto,
  ): Promise<CreatorEvent[]> {
    //対象のeventを取得
    const existEvent = await this.eventRepository.findOne({
      where: { id: body.eventId },
    });
    if (!existEvent) {
      throw new HttpException('Event not found', HttpStatus.NOT_FOUND);
    }

    //対象のeventに紐づくcreatorEventはすべて削除
    // const existCreatorEvents = await this.creatorEventRepository.find({
    //   where: { event: { id: body.eventId } },
    // });
    const existCreatorEvents = await this.creatorEventRepository
      .createQueryBuilder('creatorEvent')
      .leftJoinAndSelect('creatorEvent.creator', 'creator')
      .leftJoinAndSelect('creatorEvent.event', 'event')
      .where('event.id = :eventId', { eventId: body.eventId })
      .andWhere('creatorEvent.deleteFlag = :deleteFlag', { deleteFlag: false })
      .andWhere('creatorEvent.acceptStatus != :acceptStatus', {
        acceptStatus: AcceptStatus.ACCEPTED,
      })
      .getMany();
    existCreatorEvents.map((creatorEvent) => {
      console.log('creatorEvent', creatorEvent);
      creatorEvent.deleteFlag = true;
    });
    await this.creatorEventRepository.save(existCreatorEvents);

    //creatorを複数取得
    const existCreators = await this.creatorRepository.find({
      where: {
        id: In(body.creatorIds),
      },
    });
    if (existCreators.length !== body.creatorIds.length) {
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

  async getEventsByVenueId(venueId: number): Promise<Event[]> {
    return this.eventRepository.find({
      where: { venue: { id: venueId } },
    });
  }

  async deleteEvent(id: number): Promise<void> {
    const existEvent = await this.eventRepository.findOne({
      where: { id },
    });
    await this.eventRepository.remove(existEvent);
  }

  //acceptステータスの変更
  async responseCreatorEvent(
    body: ResponseCreatorEventDto,
  ): Promise<{ message: string }> {
    const creatorEvent = await this.creatorEventRepository.findOne({
      where: { id: body.creatorEventId },
    });

    if (!creatorEvent) {
      throw new HttpException('CreatorEvent not found', HttpStatus.NOT_FOUND);
    }

    creatorEvent.acceptStatus = body.acceptStatus;
    await this.creatorEventRepository.save(creatorEvent);

    if (body.acceptStatus === AcceptStatus.ACCEPTED) {
      return { message: '参加依頼を承認しました' };
    } else if (body.acceptStatus === AcceptStatus.REJECTED) {
      return { message: '参加依頼を拒否しました' };
    }
  }
}
