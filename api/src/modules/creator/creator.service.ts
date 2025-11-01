import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Creator } from '../../entities/creator.entity';
import { User } from '../../entities/user.entity';
import { Opus } from '../../entities/opus.entity';
import { Matching } from '../../entities/matching.entity';
import { Like } from '../../entities/like.entity';
import {
  GetCreatorWithMatchingDetailQuery,
  GetCreatorsListByVenueQuery,
} from './creator.controller';

export type CreateCreatorRequest = {
  name: string;
  description?: string;
  imageUrl?: string;
  email?: string;
  website?: string;
  phoneNumber?: string;
  socialMediaHandle?: string;
  userId: number;
};

export type UpdateCreatorRequest = {
  name?: string;
  description?: string;
  imageUrl?: string;
  email?: string;
  website?: string;
  phoneNumber?: string;
  socialMediaHandle?: string;
};

export type CreateOpusRequest = {
  name: string;
  description?: string;
  imageUrl?: string;
};

export type UpdateOpusRequest = {
  name?: string;
  description?: string;
  imageUrl?: string;
};

@Injectable()
export class CreatorService {
  constructor(
    @InjectRepository(Creator)
    private readonly creatorRepository: Repository<Creator>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Opus)
    private readonly opusRepository: Repository<Opus>,
    @InjectRepository(Matching)
    private readonly matchingRepository: Repository<Matching>,
    @InjectRepository(Like)
    private readonly likeRepository: Repository<Like>,
  ) {}

  async createCreator(creatorData: CreateCreatorRequest): Promise<Creator> {
    const existUser = await this.userRepository.findOne({
      where: { id: creatorData.userId },
    });
    if (!existUser) {
      throw new Error('User not found');
    }
    const newCreator = new Creator();
    newCreator.name = creatorData.name;
    newCreator.description = creatorData.description;
    newCreator.email = creatorData.email;
    newCreator.website = creatorData.website;
    newCreator.phoneNumber = creatorData.phoneNumber;
    newCreator.socialMediaHandle = creatorData.socialMediaHandle;
    newCreator.imageUrl = creatorData.imageUrl;
    newCreator.user = existUser;
    return await this.creatorRepository.save(newCreator);
  }

  async updateCreator(
    id: number,
    creatorData: UpdateCreatorRequest,
  ): Promise<Creator> {
    const existCreator = await this.creatorRepository.findOne({
      where: { id },
    });
    if (!existCreator) {
      throw new HttpException('Creator not found', HttpStatus.NOT_FOUND);
    }
    existCreator.name = creatorData.name;
    existCreator.description = creatorData.description;
    existCreator.email = creatorData.email;
    existCreator.website = creatorData.website;
    existCreator.phoneNumber = creatorData.phoneNumber;
    existCreator.socialMediaHandle = creatorData.socialMediaHandle;
    existCreator.imageUrl = creatorData.imageUrl;
    return await this.creatorRepository.save(existCreator);
  }

  async getCreators(userId?: number): Promise<Creator[]> {
    const existCreators = await this.creatorRepository
      .createQueryBuilder('creator')
      .leftJoinAndSelect('creator.user', 'user')
      .leftJoinAndSelect('creator.opuses', 'opuses')
      .where('user.id != :userId', { userId })
      .getMany();
    return existCreators;
  }

  async getCreatorsByUserId(userId?: number): Promise<Creator[]> {
    const creators = await this.creatorRepository.find({
      relations: ['user', 'opuses'],
      where: userId ? { user: { id: userId } } : {},
    });
    return creators;
  }

  //自分がいいねしたクリエイターにisLikedをtrueを設定
  async setCreatorIsLiked(
    creators: Creator[],
    requestorId?: number,
  ): Promise<void> {
    if (!requestorId) {
      creators.forEach((creator) => {
        creator.isLiked = false;
      });
      return;
    }

    const creatorLikes = await this.likeRepository
      .createQueryBuilder('like')
      .leftJoinAndSelect('like.creator', 'creator')
      .where('like.requestor_id = :requestorId', { requestorId })
      .andWhere('like.creator IS NOT NULL')
      .getMany();

    creators.forEach((creator) => {
      creator.isLiked = creatorLikes.some(
        (like) => like.creator.id === creator.id,
      );
    });
  }

  async getCreatorsList(requestorId: number): Promise<Creator[]> {
    const existCreators = await this.creatorRepository.find();
    await this.setCreatorIsLiked(existCreators, requestorId);
    return existCreators;
  }

  async getCreatorsListByVenue(
    query: GetCreatorsListByVenueQuery,
  ): Promise<Creator[]> {
    const { venueId, requestorId } = query;
    const existCreators = await this.creatorRepository.find({
      relations: ['user', 'opuses'],
      where: { user: { id: requestorId } },
    });

    //自分とのマッチングデータを全て取得
    const existMatchings = await this.matchingRepository
      .createQueryBuilder('matching')
      .leftJoinAndSelect('matching.creator', 'creator')
      .leftJoin('matching.venue', 'venue')
      .where('venue.id = :venueId', { venueId })
      .getMany();

    //取得した自分とのマッチングデータにヒットするvenueに該当のmatchingを付与
    existCreators.forEach((creator) => {
      const matching = existMatchings.find(
        (matching) => matching.creator.id === creator.id,
      );
      if (matching) {
        creator.matchings = [matching];
      }
    });

    //自分がいいねした会場にisLikedをtrueを設定
    await this.setCreatorIsLiked(existCreators, requestorId);
    return existCreators;
  }

  async getCreatorWithMatchingDetail(
    query: GetCreatorWithMatchingDetailQuery,
  ): Promise<Creator> {
    const { creatorId, venueId, requestorId } = query;
    const creator = await this.creatorRepository
      .createQueryBuilder('creator')
      .leftJoinAndSelect('creator.user', 'user')
      .leftJoinAndSelect('creator.opuses', 'opuses')
      .leftJoinAndSelect(
        'creator.matchings',
        'matching',
        'matching.venue.id = :venueId',
        { venueId },
      )
      .where('creator.id = :creatorId', { creatorId })
      .getOne();

    if (!creator) {
      throw new HttpException('Creator not found', HttpStatus.NOT_FOUND);
    }
    if (requestorId) {
      const creatorLike = await this.likeRepository
        .createQueryBuilder('like')
        .leftJoin('like.creator', 'creator')
        .where('like.requestor_id = :requestorId', { requestorId })
        .andWhere('creator.id = :creatorId', { creatorId })
        .getOne();

      creator.isLiked = Boolean(creatorLike);
    } else {
      creator.isLiked = false;
    }
    return creator;
  }

  async getCreatorById(id: number): Promise<Creator> {
    const creator = await this.creatorRepository.findOne({
      where: { id },
      relations: ['user'],
    });

    if (!creator) {
      throw new HttpException('Creator not found', HttpStatus.NOT_FOUND);
    }

    return creator;
  }

  async deleteCreator(id: number): Promise<void> {
    const creator = await this.getCreatorById(id);
    await this.creatorRepository.remove(creator);
  }

  // Opus methods
  async createOpus(
    creatorId: number,
    opusData: CreateOpusRequest,
  ): Promise<Opus> {
    const creator = await this.getCreatorById(creatorId);
    if (!creator) {
      throw new HttpException('Creator not found', HttpStatus.NOT_FOUND);
    }

    const newOpus = new Opus();
    newOpus.name = opusData.name;
    newOpus.description = opusData.description;
    newOpus.imageUrl = opusData.imageUrl;
    newOpus.creator = creator;

    return await this.opusRepository.save(newOpus);
  }

  async updateOpus(
    creatorId: number,
    opusId: number,
    opusData: UpdateOpusRequest,
  ): Promise<Opus> {
    const opus = await this.opusRepository.findOne({
      where: { id: opusId },
      relations: ['creator'],
    });

    if (!opus) {
      throw new HttpException('Opus not found', HttpStatus.NOT_FOUND);
    }

    if (opus.creator.id !== Number(creatorId)) {
      throw new HttpException(
        'This opus does not belong to this creator',
        HttpStatus.FORBIDDEN,
      );
    }

    if (opusData.name !== undefined) opus.name = opusData.name;
    if (opusData.description !== undefined)
      opus.description = opusData.description;
    if (opusData.imageUrl !== undefined) opus.imageUrl = opusData.imageUrl;

    return await this.opusRepository.save(opus);
  }

  async deleteOpus(creatorId: number, opusId: number): Promise<void> {
    const opus = await this.opusRepository.findOne({
      where: { id: opusId },
      relations: ['creator'],
    });

    if (!opus) {
      throw new HttpException('Opus not found', HttpStatus.NOT_FOUND);
    }

    if (opus.creator.id !== Number(creatorId)) {
      console.log('opus does not belong to this creator');
      throw new HttpException(
        'This opus does not belong to this creator',
        HttpStatus.FORBIDDEN,
      );
    }

    await this.opusRepository.remove(opus);
  }

  async getOpusByCreatorId(creatorId: number): Promise<Opus[]> {
    return await this.opusRepository.find({
      where: { creator: { id: creatorId } },
    });
  }
}
