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
import { ChatGroup } from "../../entities/chatGroup.entity"; // グループエンティティをインポート
import { ChatGroupUser } from "../../entities/chatGroupUser.entity";

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
    private readonly userRepository: Repository<User>,
    @InjectRepository(ChatGroup)
    private readonly groupRepository: Repository<ChatGroup>, // グループリポジトリを追加
    @InjectRepository(ChatGroupUser)
    private readonly chatGroupUserRepository: Repository<ChatGroupUser>
  ) {}

  async createMatchingFromCreator(
    matching: CreateMatchingFromCreatorRequest,
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
    newMatching.creator = existCreator;
    newMatching.venue = existVenue;
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
    console.log(matching);
    const existVenue = await this.venueRepository.findOne({
      where: { id: matching.venueId },
      relations: ["user"],
    });
    console.log(existVenue);
    const existCreator = await this.creatorRepository.findOne({
      where: { id: matching.creatorId },
      relations: ["user"],
    });
    console.log(existCreator);

    if (!existVenue) {
      throw new HttpException("Venue not found", HttpStatus.NOT_FOUND);
    }
    if (!existCreator) {
      throw new HttpException("Creator not found", HttpStatus.NOT_FOUND);
    }
    if (existVenue.user.id !== reqUser.id) {
      throw new HttpException("User not found", HttpStatus.NOT_FOUND);
    }

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
    newMatching.creator = existCreator;
    newMatching.venue = existVenue;
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
    console.log(existMatching);
    if (existMatching) {
      throw new HttpException(
        "Matching already exists",
        HttpStatus.BAD_REQUEST
      );
    }

    const newMatching = new Matching();
    if (matching.creatorId) {
      const existCreator = await this.creatorRepository.findOne({
        where: { id: matching.creatorId },
        relations: ["user"],
      });
      newMatching.creator = existCreator;
    }
    if (matching.venueId) {
      const existVenue = await this.venueRepository.findOne({
        where: { id: matching.venueId },
        relations: ["user"],
      });
      newMatching.venue = existVenue;
    }
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

    const savedMatching = await this.matchingRepository.save(matching);

    // マッチングが承諾された際にグループを作成
    const newGroup = new ChatGroup();
    newGroup.name = `Group_${savedMatching.id}`;
    newGroup.matching = savedMatching;
    newGroup.unreadMessageCount = 0;
    newGroup.latestMessage = "";
    newGroup.createdAt = new Date();
    newGroup.updatedAt = new Date();
    const savedGroup = await this.groupRepository.save(newGroup);
    const newChatGroupUsers: ChatGroupUser[] = [];

    const newChatGroupUser1 = new ChatGroupUser();
    newChatGroupUser1.user = savedMatching.fromUser;
    newChatGroupUser1.chatGroup = savedGroup;
    newChatGroupUsers.push(newChatGroupUser1);
    const newChatGroupUser2 = new ChatGroupUser();
    newChatGroupUser2.user = savedMatching.toUser;
    newChatGroupUser2.chatGroup = savedGroup;
    newChatGroupUsers.push(newChatGroupUser2);
    await this.chatGroupUserRepository.save(newChatGroupUsers);
    return savedMatching;
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
    return await this.matchingRepository.save(matching);
  }

  async getCompletedMatchings(reqUser: User) {
    const completedMatchings = await this.matchingRepository
      .createQueryBuilder("matching")
      .leftJoinAndSelect("matching.fromUser", "fromUser")
      .leftJoinAndSelect("matching.toUser", "toUser")
      .leftJoinAndSelect("matching.chatGroups", "chatGroups")
      .where("toUser.id = :userId", { userId: reqUser.id })
      .andWhere("matching.matchingFlag = :flag", { flag: true })
      .orderBy("matching.matchingAt", "DESC")
      .getMany();
    return completedMatchings;
  }
}
