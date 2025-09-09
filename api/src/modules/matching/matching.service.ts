import { Injectable, HttpException, HttpStatus } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Matching, MatchingFrom } from "../../entities/matching.entity";
import { User } from "../../entities/user.entity";
import { Creator } from "../../entities/creator.entity";
import { Venu } from "../../entities/venu.entity";
import {
  CreateMatchingFromCreatorRequest,
  CreateMatchingFromVenuRequest,
  CreateMatchingEventRequest,
} from "./matching.controller";
import { Event, MatchingStatus } from "../../entities/event.entity";

@Injectable()
export class MatchingService {
  constructor(
    @InjectRepository(Matching)
    private readonly matchingRepository: Repository<Matching>,
    @InjectRepository(Creator)
    private readonly creatorRepository: Repository<Creator>,
    @InjectRepository(Venu)
    private readonly venuRepository: Repository<Venu>,
    @InjectRepository(Event)
    private readonly eventRepository: Repository<Event>
  ) {}

  async createMatchingFromCreator(
    matching: CreateMatchingFromCreatorRequest,
    reqUser: User
  ): Promise<Matching> {
    const existCreator = await this.creatorRepository.findOne({
      where: { id: matching.creatorId },
      relations: ["user"],
    });

    const existVenu = await this.venuRepository.findOne({
      where: { id: matching.venuId },
      relations: ["user"],
    });

    const existMatching = await this.matchingRepository.findOne({
      where: {
        creator: { id: matching.creatorId },
        venu: { id: matching.venuId },
      },
    });
    if (!existCreator) {
      throw new HttpException("Creator not found", HttpStatus.NOT_FOUND);
    }
    if (!existVenu) {
      throw new HttpException("Venu not found", HttpStatus.NOT_FOUND);
    }
    if (existCreator.user.id !== reqUser.id) {
      throw new HttpException("User not found", HttpStatus.NOT_FOUND);
    }
    if (existMatching) {
      throw new HttpException(
        "Matching already exists",
        HttpStatus.BAD_REQUEST
      );
    }
    const newMatching = new Matching();
    newMatching.from = MatchingFrom.CREATOR;
    newMatching.creator = existCreator;
    newMatching.venu = existVenu;
    newMatching.fromUser = existCreator.user;
    newMatching.toUser = existVenu.user;
    newMatching.requestAt = new Date();
    newMatching.matchingFlag = false;
    newMatching.matchingAt = null;
    return await this.matchingRepository.save(newMatching);
  }

  async createMatchingFromVenu(
    matching: CreateMatchingFromVenuRequest,
    reqUser: User
  ) {
    const existVenu = await this.venuRepository.findOne({
      where: { id: matching.venuId },
      relations: ["user"],
    });
    const existCreator = await this.creatorRepository.findOne({
      where: { id: matching.creatorId },
      relations: ["user"],
    });

    const existMatching = await this.matchingRepository
      .createQueryBuilder("matching")
      .where("matching.venu.id = :venuId", { venuId: matching.venuId })
      .andWhere("matching.creator.id = :creatorId", {
        creatorId: matching.creatorId,
      })
      .getOne();
    console.log(existMatching);
    if (existMatching) {
      throw new HttpException(
        "Matching already exists",
        HttpStatus.BAD_REQUEST
      );
    }
    if (!existVenu) {
      throw new HttpException("Venu not found", HttpStatus.NOT_FOUND);
    }
    if (!existCreator) {
      throw new HttpException("Creator not found", HttpStatus.NOT_FOUND);
    }
    if (existVenu.user.id !== reqUser.id) {
      throw new HttpException("User not found", HttpStatus.NOT_FOUND);
    }
    if (existMatching) {
      throw new HttpException(
        "Matching already exists",
        HttpStatus.BAD_REQUEST
      );
    }
    const newMatching = new Matching();
    newMatching.from = MatchingFrom.VENU;
    newMatching.venu = existVenu;
    newMatching.creator = existCreator;
    newMatching.fromUser = existVenu.user;
    newMatching.toUser = existCreator.user;
    newMatching.requestAt = new Date();
    newMatching.matchingFlag = false;
    newMatching.matchingAt = null;
    return await this.matchingRepository.save(newMatching);
  }

  async getRequestMatchings(reqUser: User) {
    const matchings = await this.matchingRepository.find({
      where: { toUser: { id: reqUser.id }, matchingFlag: false },
      relations: ["creator", "venu"],
      order: { requestAt: "DESC" },
    });
    return matchings;
  }

  async acceptMatchingRequest(matchingId: number, reqUser: User) {
    const matching = await this.matchingRepository.findOne({
      where: {
        id: matchingId,
        toUser: { id: reqUser.id },
        matchingFlag: false,
      },
      relations: ["creator", "venu"],
    });

    if (!matching) {
      throw new HttpException(
        "Matching request not found",
        HttpStatus.NOT_FOUND
      );
    }

    matching.matchingFlag = true;
    matching.matchingAt = new Date();

    return await this.matchingRepository.save(matching);
  }

  async getCompletedMatchings(reqUser: User) {
    const completedMatchings = await this.matchingRepository.find({
      where: { toUser: { id: reqUser.id }, matchingFlag: true },
      relations: ["creator", "venu", "fromUser", "toUser"],
      order: { matchingAt: "DESC" },
    });
    return completedMatchings;
  }

  async getMatchingEvents(matchingId: number) {
    const matchingEvents = await this.eventRepository.find({
      relations: ["fromUser", "toUser"],
      where: {
        matching: { id: matchingId },
      },
      order: { matchingAt: "DESC" },
    });
    console.log(matchingEvents);
    return matchingEvents;
  }

  async createMatchingEvent(
    matchingId: number,
    event: CreateMatchingEventRequest
  ) {
    const matching = await this.matchingRepository.findOne({
      where: { id: matchingId },
    });
    if (!matching) {
      throw new HttpException("Matching not found", HttpStatus.NOT_FOUND);
    }
    const newEvent = new Event();
    newEvent.matching = matching;
    newEvent.title = event.title;
    newEvent.description = event.description;
    newEvent.startDate = new Date(event.startDate);
    newEvent.endDate = new Date(event.endDate);
    newEvent.fromUser = matching.fromUser;
    newEvent.toUser = matching.toUser;
    newEvent.requestAt = new Date();
    newEvent.matchingStatus = MatchingStatus.PENDING;
    newEvent.matchingAt = null;
    return await this.eventRepository.save(newEvent);
  }

  async acceptMatchingEvent(eventId: number, reqUser: User) {
    const event = await this.eventRepository.findOne({
      where: { id: eventId, toUser: { id: reqUser.id } },
    });
    if (!event) {
      throw new HttpException("Event not found", HttpStatus.NOT_FOUND);
    }
    event.matchingStatus = MatchingStatus.MATCHING;
    event.matchingAt = new Date();
    return await this.eventRepository.save(event);
  }

  async rejectMatchingEvent(eventId: number, reqUser: User) {
    const event = await this.eventRepository.findOne({
      where: { id: eventId, toUser: { id: reqUser.id } },
    });
    if (!event) {
      throw new HttpException("Event not found", HttpStatus.NOT_FOUND);
    }
    event.matchingStatus = MatchingStatus.REJECTED;
    return await this.eventRepository.save(event);
  }
}
