import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Venue } from '../../entities/venue.entity';
import { User } from '../../entities/user.entity';

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

  async getVenues(userId?: number): Promise<Venue[]> {
    const existVenues = await this.venueRepository.find({
      relations: ['user'],
      where: userId ? { user: { id: userId } } : {},
    });
    return existVenues;
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
