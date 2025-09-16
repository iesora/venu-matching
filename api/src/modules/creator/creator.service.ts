import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Creator } from '../../entities/creator.entity';
import { User } from '../../entities/user.entity';

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

@Injectable()
export class CreatorService {
  constructor(
    @InjectRepository(Creator)
    private readonly creatorRepository: Repository<Creator>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
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
    return await this.creatorRepository.find({
      relations: ['user', 'opuses'],
      where: userId ? { user: { id: userId } } : {},
    });
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
}
