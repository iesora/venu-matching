import { Injectable, HttpException, HttpStatus } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Matching, MatchingStatus } from "../../entities/matching.entity";
import { User } from "../../entities/user.entity";
import { Creator } from "../../entities/creator.entity";
import { Venue } from "../../entities/venue.entity";
import {
  CreateMatchingFromCreatorRequest,
  CreateMatchingFromVenueRequest,
  CreateMatchingRequest,
} from "./matching.controller";
import { Event } from "../../entities/event.entity";

@Injectable()
export class MatchingService {
  constructor(
    @InjectRepository(Matching)
    private readonly matchingRepository: Repository<Matching>,
    @InjectRepository(Creator)
    private readonly creatorRepository: Repository<Creator>,
    @InjectRepository(Venue)
    private readonly venueRepository: Repository<Venue>,
    @InjectRepository(Event)
    private readonly eventRepository: Repository<Event>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>
  ) {}

  async createMatchingFromCreator(
    matching: CreateMatchingFromCreatorRequest,
    reqUser: User
  ): Promise<Matching> {
    const existVenue = await this.venueRepository.findOne({
      where: { id: matching.venueId },
      relations: ["user"],
    });

    if (!existVenue) {
      throw new HttpException("Venue not found", HttpStatus.NOT_FOUND);
    }

    // 重複チェック（双方向）
    const existMatching = await this.matchingRepository
      .createQueryBuilder("matching")
      .leftJoin("matching.fromUser", "fromUser")
      .leftJoin("matching.toUser", "toUser")
      .where(
        "(fromUser.id = :fromId AND toUser.id = :toId) OR (fromUser.id = :toId AND toUser.id = :fromId)",
        { fromId: reqUser.id, toId: existVenue.user.id }
      )
      .getOne();
    if (existMatching) {
      throw new HttpException(
        "Matching already exists",
        HttpStatus.BAD_REQUEST
      );
    }

    const newMatching = new Matching();
    newMatching.fromUser = reqUser;
    newMatching.toUser = existVenue.user;
    newMatching.requestAt = new Date();
    newMatching.matchingFlag = false;
    newMatching.status = MatchingStatus.PENDING;
    newMatching.matchingAt = null;
    return await this.matchingRepository.save(newMatching);
  }

  async createMatchingFromVenue(
    matching: CreateMatchingFromVenueRequest,
    reqUser: User
  ): Promise<Matching> {
    const existVenue = await this.venueRepository.findOne({
      where: { id: matching.venueId },
      relations: ["user"],
    });
    const existCreator = await this.creatorRepository.findOne({
      where: { id: matching.creatorId },
      relations: ["user"],
    });

    if (!existVenue) {
      throw new HttpException("Venue not found", HttpStatus.NOT_FOUND);
    }
    if (!existCreator) {
      throw new HttpException("Creator not found", HttpStatus.NOT_FOUND);
    }
    if (existVenue.user.id !== reqUser.id) {
      throw new HttpException("User not found", HttpStatus.NOT_FOUND);
    }

    // 重複チェック（双方向）
    const existMatching = await this.matchingRepository
      .createQueryBuilder("matching")
      .leftJoin("matching.fromUser", "fromUser")
      .leftJoin("matching.toUser", "toUser")
      .where(
        "(fromUser.id = :fromId AND toUser.id = :toId) OR (fromUser.id = :toId AND toUser.id = :fromId)",
        { fromId: existVenue.user.id, toId: existCreator.user.id }
      )
      .getOne();
    if (existMatching) {
      throw new HttpException(
        "Matching already exists",
        HttpStatus.BAD_REQUEST
      );
    }

    const newMatching = new Matching();
    newMatching.fromUser = existVenue.user;
    newMatching.toUser = existCreator.user;
    newMatching.requestAt = new Date();
    newMatching.matchingFlag = false;
    newMatching.status = MatchingStatus.PENDING;
    newMatching.matchingAt = null;
    return await this.matchingRepository.save(newMatching);
  }

  async createMatching(
    matching: CreateMatchingRequest,
    reqUser: User
  ): Promise<Matching> {
    const toUser = await this.userRepository.findOne({
      where: { id: matching.toUserId },
    });
    if (!toUser) {
      throw new HttpException("To user not found", HttpStatus.NOT_FOUND);
    }
    if (toUser.id === reqUser.id) {
      throw new HttpException("Cannot request to self", HttpStatus.BAD_REQUEST);
    }

    const existMatching = await this.matchingRepository
      .createQueryBuilder("matching")
      .leftJoin("matching.fromUser", "fromUser")
      .leftJoin("matching.toUser", "toUser")
      .where(
        "(fromUser.id = :fromId AND toUser.id = :toId) OR (fromUser.id = :toId AND toUser.id = :fromId)",
        { fromId: reqUser.id, toId: toUser.id }
      )
      .getOne();
    if (existMatching) {
      throw new HttpException(
        "Matching already exists",
        HttpStatus.BAD_REQUEST
      );
    }

    const newMatching = new Matching();
    newMatching.fromUser = reqUser;
    newMatching.toUser = toUser;
    newMatching.requestAt = new Date();
    newMatching.matchingFlag = false;
    newMatching.status = MatchingStatus.PENDING;
    newMatching.matchingAt = null;
    return await this.matchingRepository.save(newMatching);
  }

  async getRequestMatchings(reqUser: User) {
    const matchings = await this.matchingRepository.find({
      where: {
        toUser: { id: reqUser.id },
        matchingFlag: false,
        status: MatchingStatus.PENDING,
      },
      relations: ["fromUser", "toUser"],
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
      relations: ["fromUser", "toUser"],
    });

    if (!matching) {
      throw new HttpException(
        "Matching request not found",
        HttpStatus.NOT_FOUND
      );
    }

    matching.matchingFlag = true;
    matching.status = MatchingStatus.MATCHING;
    matching.matchingAt = new Date();

    return await this.matchingRepository.save(matching);
  }

  async rejectMatchingRequest(
    matchingId: number,
    reqUser: User
  ): Promise<Matching> {
    const matching = await this.matchingRepository.findOne({
      where: {
        id: matchingId,
        toUser: { id: reqUser.id },
        matchingFlag: false,
      },
      relations: ["fromUser", "toUser"],
    });

    if (!matching) {
      throw new HttpException(
        "Matching request not found",
        HttpStatus.NOT_FOUND
      );
    }

    matching.status = MatchingStatus.REJECTED;
    // 保持するか削除するかは要件次第。今回は保持して一覧からは除外（PENDINGのみ取得）
    return await this.matchingRepository.save(matching);
  }

  async getCompletedMatchings(reqUser: User) {
    const completedMatchings = await this.matchingRepository.find({
      where: { toUser: { id: reqUser.id }, matchingFlag: true },
      relations: ["fromUser", "toUser"],
      order: { matchingAt: "DESC" },
    });
    return completedMatchings;
  }

  //fromUser,toUser,matchingは仕様変更につき削除
  //   async getMatchingEvents(matchingId: number) {
  //     const matchingEvents = await this.eventRepository.find({
  //       relations: ['fromUser', 'toUser'],
  //       where: {
  //         matching: { id: matchingId },
  //       },
  //       order: { matchingAt: 'DESC' },
  //     });
  //     console.log(matchingEvents);
  //     return matchingEvents;
  //   }

  //   async createMatchingEvent(
  //     matchingId: number,
  //     event: CreateMatchingEventRequest,
  //   ) {
  //     const matching = await this.matchingRepository.findOne({
  //       where: { id: matchingId },
  //     });
  //     if (!matching) {
  //       throw new HttpException('Matching not found', HttpStatus.NOT_FOUND);
  //     }
  //     const newEvent = new Event();
  //     newEvent.matching = matching;
  //     newEvent.title = event.title;
  //     newEvent.description = event.description;
  //     newEvent.startDate = new Date(event.startDate);
  //     newEvent.endDate = new Date(event.endDate);
  //     newEvent.fromUser = matching.fromUser;
  //     newEvent.toUser = matching.toUser;
  //     newEvent.requestAt = new Date();
  //     newEvent.matchingStatus = MatchingStatus.PENDING;
  //     newEvent.matchingAt = null;
  //     return await this.eventRepository.save(newEvent);
  //   }

  //   async acceptMatchingEvent(eventId: number, reqUser: User) {
  //     const event = await this.eventRepository.findOne({
  //       where: { id: eventId, toUser: { id: reqUser.id } },
  //     });
  //     if (!event) {
  //       throw new HttpException('Event not found', HttpStatus.NOT_FOUND);
  //     }
  //     event.matchingStatus = MatchingStatus.MATCHING;
  //     event.matchingAt = new Date();
  //     return await this.eventRepository.save(event);
  //   }

  //   async rejectMatchingEvent(eventId: number, reqUser: User) {
  //     const event = await this.eventRepository.findOne({
  //       where: { id: eventId, toUser: { id: reqUser.id } },
  //     });
  //     if (!event) {
  //       throw new HttpException('Event not found', HttpStatus.NOT_FOUND);
  //     }
  //     event.matchingStatus = MatchingStatus.REJECTED;
  //     return await this.eventRepository.save(event);
  //   }
}
