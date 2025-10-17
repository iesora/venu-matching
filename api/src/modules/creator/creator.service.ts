import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Creator } from '../../entities/creator.entity';
import { User } from '../../entities/user.entity';
import { Opus } from '../../entities/opus.entity';

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
    console.log('userId', userId);
    const existCreators = await this.creatorRepository
      .createQueryBuilder('creator')
      .leftJoinAndSelect('creator.user', 'user')
      .leftJoinAndSelect('creator.opuses', 'opuses')
      .where('user.id != :userId', { userId })
      .getMany();
    console.log('creators', existCreators);
    return existCreators;
  }

  async getCreatorsByUserId(userId?: number): Promise<Creator[]> {
    const creators = await this.creatorRepository.find({
      relations: ['user', 'opuses'],
      where: userId ? { user: { id: userId } } : {},
    });
    return creators;
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
    console.log('creatorId', creatorId);
    console.log('opus: ', opus.creator.id);

    if (opus.creator.id !== Number(creatorId)) {
      console.log('hello 403');
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
      console.log('opus not found');
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
