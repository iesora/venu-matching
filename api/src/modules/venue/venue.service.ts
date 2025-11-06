import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Venue } from '../../entities/venue.entity';
import { User } from '../../entities/user.entity';
import { Matching } from '../../entities/matching.entity';
import { Like } from '../../entities/like.entity';
import {
  GetVenueWithMatchingDetailQuery,
  GetVenuesListByCreatorQuery,
} from './venue.controller';

export type CreateVenueRequest = {
  name: string;
  tel?: string;
  address?: string;
  description?: string;
  capacity?: number;
  facilities?: string;
  availableTime?: string;
  userId: number;
  latitude?: number;
  longitude?: number;
};

export type UpdateVenueRequest = {
  name?: string;
  address?: string;
  tel?: string;
  description?: string;
  capacity?: number;
  facilities?: string;
  availableTime?: string;
  imageUrl?: string;
  latitude?: number;
  longitude?: number;
};

@Injectable()
export class VenueService {
  constructor(
    @InjectRepository(Venue)
    private readonly venueRepository: Repository<Venue>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Matching)
    private readonly matchingRepository: Repository<Matching>,
    @InjectRepository(Like)
    private readonly likeRepository: Repository<Like>,
  ) {}

  async createVenue(venueData: CreateVenueRequest): Promise<Venue> {
    const existUser = await this.userRepository.findOne({
      where: { id: venueData.userId },
    });
    if (!existUser) {
      throw new Error('User not found');
    }

    const newVenue = new Venue();
    newVenue.name = venueData.name;
    newVenue.address = venueData.address;
    newVenue.tel = venueData.tel;
    newVenue.latitude = venueData.latitude;
    newVenue.longitude = venueData.longitude;
    newVenue.description = venueData.description;
    newVenue.capacity = venueData.capacity;
    newVenue.facilities = venueData.facilities;
    newVenue.availableTime = venueData.availableTime;
    newVenue.user = existUser;
    return await this.venueRepository.save(newVenue);
  }

  async updateVenue(id: number, venueData: UpdateVenueRequest): Promise<Venue> {
    const existVenue = await this.venueRepository.findOne({
      where: { id },
    });
    if (!existVenue) {
      throw new HttpException('Venue not found', HttpStatus.NOT_FOUND);
    }
    existVenue.name = venueData.name;
    existVenue.address = venueData.address;
    existVenue.tel = venueData.tel;
    existVenue.description = venueData.description;
    existVenue.capacity = venueData.capacity;
    existVenue.facilities = venueData.facilities;
    existVenue.availableTime = venueData.availableTime;
    existVenue.imageUrl = venueData.imageUrl;
    existVenue.latitude = venueData.latitude;
    existVenue.longitude = venueData.longitude;
    return await this.venueRepository.save(existVenue);
  }

  async setVenueIsLiked(venues: Venue[], requestorId: number): Promise<void> {
    const venueLikes = await this.likeRepository
      .createQueryBuilder('like')
      .leftJoinAndSelect('like.venue', 'venue')
      .where('like.requestor_id = :requestorId', { requestorId })
      .andWhere('like.venue IS NOT NULL')
      .getMany();

    venues.forEach((venue) => {
      venue.isLiked = venueLikes.some((like) => like.venue.id === venue.id);
    });
  }

  async getVenues(userId?: number): Promise<Venue[]> {
    const existVenues = await this.venueRepository.find({
      relations: ['user'],
      where: userId ? { user: { id: userId } } : {},
    });
    return existVenues;
  }

  async getVenuesList(requestorId: number): Promise<Venue[]> {
    const existVenues = await this.venueRepository.find();

    //取得したvenueにリクエスト送信者からのいいねがあればisLikedをtrueにする
    await this.setVenueIsLiked(existVenues, requestorId);
    return existVenues;
  }

  async getVenuesListByCreator(
    query: GetVenuesListByCreatorQuery,
  ): Promise<Venue[]> {
    const { creatorId, requestorId } = query;
    const existVenues = await this.venueRepository.find();
    const existMatchings = await this.matchingRepository
      .createQueryBuilder('matching')
      .leftJoinAndSelect('matching.venue', 'venue')
      .leftJoin('matching.creator', 'creator')
      .where('creator.id = :creatorId', { creatorId })
      .getMany();

    existVenues.forEach((venue) => {
      const matching = existMatchings.find(
        (matching) => matching.venue.id === venue.id,
      );
      if (matching) {
        venue.matchings = [matching];
      }
    });
    await this.setVenueIsLiked(existVenues, requestorId);
    return existVenues;
  }

  async getVenueWithMatchingDetail(
    query: GetVenueWithMatchingDetailQuery,
  ): Promise<Venue> {
    const { venueId, creatorId, requestorId } = query;
    //requestorIdとvenueIdが一致するlikeを取得してisLikedを設定
    console.log('requestorId: ', requestorId);
    const venue = await this.venueRepository
      .createQueryBuilder('venue')
      .leftJoinAndSelect('venue.user', 'user')
      .leftJoinAndSelect(
        'venue.matchings',
        'matching',
        'matching.creator.id = :creatorId',
        { creatorId },
      )
      .where('venue.id = :venueId', { venueId })
      .getOne();

    if (!venue) {
      throw new HttpException('Venue not found', HttpStatus.NOT_FOUND);
    }

    return venue;
  }

  async getVenueById(id: number): Promise<Venue> {
    const venue = await this.venueRepository.findOne({
      where: { id },
      relations: ['user'],
    });

    if (!venue) {
      throw new HttpException('Venue not found', HttpStatus.NOT_FOUND);
    }

    return venue;
  }

  async deleteVenue(id: number): Promise<void> {
    const venue = await this.getVenueById(id);
    await this.venueRepository.remove(venue);
  }
}
