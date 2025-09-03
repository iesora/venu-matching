import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Venu } from '../../entities/venu.entity';
import { User } from '../../entities/user.entity';

export type CreateVenuRequest = {
  name: string;
  tel?: string;
  address?: string;
  userId: number;
};

@Injectable()
export class VenuService {
  constructor(
    @InjectRepository(Venu)
    private readonly venuRepository: Repository<Venu>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async createVenu(venuData: CreateVenuRequest): Promise<Venu> {
    const existUser = await this.userRepository.findOne({
      where: { id: venuData.userId },
    });
    if (!existUser) {
      throw new Error('User not found');
    }

    const newVenu = new Venu();
    newVenu.name = venuData.name;
    newVenu.address = venuData.address;
    newVenu.tel = venuData.tel;
    newVenu.user = existUser;
    return await this.venuRepository.save(newVenu);
  }

  async getAllVenus(): Promise<Venu[]> {
    return await this.venuRepository.find({
      relations: ['user'],
    });
  }

  async getVenuById(id: number): Promise<Venu> {
    const venu = await this.venuRepository.findOne({
      where: { id },
      relations: ['user'],
    });

    if (!venu) {
      throw new HttpException('Venu not found', HttpStatus.NOT_FOUND);
    }

    return venu;
  }

  async deleteVenu(id: number): Promise<void> {
    const venu = await this.getVenuById(id);
    await this.venuRepository.remove(venu);
  }
}
