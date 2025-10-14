import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Matching, MatchingStatus } from '../../entities/matching.entity';
import { User } from '../../entities/user.entity';
import { Creator } from '../../entities/creator.entity';
import { Venue } from '../../entities/venue.entity';
import {
  CreateMatchingRequest,
  GetRequestMatchingsQuery,
} from './matching.controller';
import { Event } from '../../entities/event.entity';
import { ChatGroup } from '../../entities/chatGroup.entity';
import { ChatGroupUser } from '../../entities/chatGroupUser.entity';

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
    private readonly groupRepository: Repository<ChatGroup>,
    @InjectRepository(ChatGroupUser)
    private readonly chatGroupUserRepository: Repository<ChatGroupUser>,
  ) {}

  //   async createMatchingFromCreator(
  //     matching: CreateMatchingFromCreatorRequest,
  //   ): Promise<Matching> {
  //     const existVenue = await this.venueRepository.findOne({
  //       where: { id: matching.venueId },
  //       relations: ['user'],
  //     });

  //     const existCreator = await this.creatorRepository.findOne({
  //       where: { id: matching.creatorId },
  //       relations: ['user'],
  //     });

  //     if (!existVenue) {
  //       throw new HttpException('Venue not found', HttpStatus.NOT_FOUND);
  //     }

  //     const existMatching = await this.matchingRepository
  //       .createQueryBuilder('matching')
  //       .leftJoin('matching.creator', 'creator')
  //       .leftJoin('matching.venue', 'venue')
  //       .where('(creator.id = :creatorId AND venue.id = :venueId) ', {
  //         creatorId: existCreator.id,
  //         venueId: existVenue.id,
  //       })
  //       .getOne();
  //     if (existMatching) {
  //       throw new HttpException(
  //         'Matching already exists',
  //         HttpStatus.BAD_REQUEST,
  //       );
  //     }

  //     const newMatching = new Matching();
  //     //コントローラ修正次第
  //     newMatching.requestorType = RequestorType.CREATOR;
  //     newMatching.creator = existCreator;
  //     newMatching.venue = existVenue;
  //     newMatching.requestAt = new Date();
  //     newMatching.status = MatchingStatus.PENDING;
  //     newMatching.matchingAt = null;
  //     return await this.matchingRepository.save(newMatching);
  //   }

  //   async createMatchingFromVenue(
  //     matching: CreateMatchingFromVenueRequest,
  //     reqUser: User,
  //   ): Promise<Matching> {
  //     console.log(matching);
  //     const existVenue = await this.venueRepository.findOne({
  //       where: { id: matching.venueId },
  //       relations: ['user'],
  //     });
  //     console.log(existVenue);
  //     const existCreator = await this.creatorRepository.findOne({
  //       where: { id: matching.creatorId },
  //       relations: ['user'],
  //     });
  //     console.log(existCreator);

  //     if (!existVenue) {
  //       throw new HttpException('Venue not found', HttpStatus.NOT_FOUND);
  //     }
  //     if (!existCreator) {
  //       throw new HttpException('Creator not found', HttpStatus.NOT_FOUND);
  //     }
  //     if (existVenue.user.id !== reqUser.id) {
  //       throw new HttpException('User not found', HttpStatus.NOT_FOUND);
  //     }

  //     const existMatching = await this.matchingRepository
  //       .createQueryBuilder('matching')
  //       .leftJoin('matching.fromUser', 'fromUser')
  //       .leftJoin('matching.toUser', 'toUser')
  //       .where(
  //         '(fromUser.id = :fromId AND toUser.id = :toId) OR (fromUser.id = :toId AND toUser.id = :fromId)',
  //         { fromId: existVenue.user.id, toId: existCreator.user.id },
  //       )
  //       .getOne();
  //     if (existMatching) {
  //       throw new HttpException(
  //         'Matching already exists',
  //         HttpStatus.BAD_REQUEST,
  //       );
  //     }

  //     const newMatching = new Matching();
  //     newMatching.fromUser = existVenue.user;
  //     newMatching.toUser = existCreator.user;
  //     newMatching.creator = existCreator;
  //     newMatching.venue = existVenue;
  //     newMatching.requestAt = new Date();
  //     newMatching.matchingFlag = false;
  //     newMatching.status = MatchingStatus.PENDING;
  //     newMatching.matchingAt = null;
  //     return await this.matchingRepository.save(newMatching);
  //   }

  async createMatching(matching: CreateMatchingRequest): Promise<Matching> {
    if (!matching.creatorId || !matching.creatorId) {
      throw new HttpException('Not enough argument', HttpStatus.BAD_REQUEST);
    }
    const existMatching = await this.matchingRepository
      .createQueryBuilder('matching')
      .leftJoin('matching.creator', 'creator')
      .leftJoin('matching.venue', 'venue')
      .where('(creator.id = :creatorId AND venue.id = :venueId) ', {
        creatorId: matching.creatorId,
        venueId: matching.venueId,
      })
      .getOne();
    if (existMatching) {
      //フロントでエラーメッセージハンドルするためstatuscode510
      throw new HttpException('Matching already exists', 510);
    }

    const newMatching = new Matching();
    if (matching.creatorId) {
      const existCreator = await this.creatorRepository.findOne({
        where: { id: matching.creatorId },
        relations: ['user'],
      });
      newMatching.creator = existCreator;
    }
    if (matching.venueId) {
      const existVenue = await this.venueRepository.findOne({
        where: { id: matching.venueId },
        relations: ['user'],
      });
      newMatching.venue = existVenue;
    }
    newMatching.requestorType = matching.requestorType;
    newMatching.requestAt = new Date();
    newMatching.status = MatchingStatus.PENDING;
    newMatching.matchingAt = null;
    return await this.matchingRepository.save(newMatching);
  }

  async getRequestMatchings(query: GetRequestMatchingsQuery) {
    console.log('query: ', query);
    const qb = await this.matchingRepository
      .createQueryBuilder('matching')
      .leftJoinAndSelect('matching.creator', 'creator')
      .leftJoinAndSelect('matching.venue', 'venue');
    if (query.relationType === 'creator') {
      qb.where('creator.id = :relationId', { relationId: query.relationId });
    } else {
      qb.where('venue.id = :relationId', { relationId: query.relationId });
    }
    const matchings = await qb
      .andWhere('matching.status != :rejected', {
        rejected: MatchingStatus.REJECTED,
      })
      .getMany();
    return matchings;
  }

  async acceptMatchingRequest(matchingId: number) {
    const matching = await this.matchingRepository.findOne({
      where: {
        id: matchingId,
      },
    });

    if (!matching) {
      throw new HttpException(
        'Matching request not found',
        HttpStatus.NOT_FOUND,
      );
    }

    matching.status = MatchingStatus.MATCHING;
    matching.matchingAt = new Date();

    const savedMatching = await this.matchingRepository.save(matching);

    // 以下仕様決定次第追加／修正
    // マッチングが承諾された際にグループを作成
    // const newGroup = new ChatGroup();
    // newGroup.name = `Group_${savedMatching.id}`;
    // newGroup.matching = savedMatching;
    // newGroup.unreadMessageCount = 0;
    // newGroup.latestMessage = '';
    // newGroup.createdAt = new Date();
    // newGroup.updatedAt = new Date();
    // const savedGroup = await this.groupRepository.save(newGroup);
    // const newChatGroupUsers: ChatGroupUser[] = [];

    // const newChatGroupUser1 = new ChatGroupUser();
    // newChatGroupUser1.user = savedMatching.fromUser;
    // newChatGroupUser1.chatGroup = savedGroup;
    // newChatGroupUsers.push(newChatGroupUser1);
    // const newChatGroupUser2 = new ChatGroupUser();
    // newChatGroupUser2.user = savedMatching.toUser;
    // newChatGroupUser2.chatGroup = savedGroup;
    // newChatGroupUsers.push(newChatGroupUser2);
    // await this.chatGroupUserRepository.save(newChatGroupUsers);
    return savedMatching;
  }

  async rejectMatchingRequest(matchingId: number): Promise<Matching> {
    const matching = await this.matchingRepository.findOne({
      where: {
        id: matchingId,
      },
    });

    if (!matching) {
      throw new HttpException(
        'Matching request not found',
        HttpStatus.NOT_FOUND,
      );
    }

    matching.status = MatchingStatus.REJECTED;
    return await this.matchingRepository.save(matching);
  }

  async getCompletedMatchings(reqUser: User) {
    const completedMatchings = await this.matchingRepository
      .createQueryBuilder('matching')
      .leftJoinAndSelect('matching.fromUser', 'fromUser')
      .leftJoinAndSelect('matching.toUser', 'toUser')
      .leftJoinAndSelect('matching.chatGroups', 'chatGroups')
      .where('toUser.id = :userId', { userId: reqUser.id })
      .andWhere('matching.matchingFlag = :flag', { flag: true })
      .orderBy('matching.matchingAt', 'DESC')
      .getMany();
    return completedMatchings;
  }
}
