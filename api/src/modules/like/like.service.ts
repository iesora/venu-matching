import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Like } from '../../entities/like.entity';
import { User } from '../../entities/user.entity';
import { Venue } from '../../entities/venue.entity';
import { Creator } from '../../entities/creator.entity';
import { CreateLikeRequest, GetMyLikesRequest } from './like.controller';

@Injectable()
export class LikeService {
  constructor(
    @InjectRepository(Like) private readonly likeRepository: Repository<Like>,
    @InjectRepository(User) private readonly userRepository: Repository<User>,
    @InjectRepository(Venue)
    private readonly venueRepository: Repository<Venue>,
    @InjectRepository(Creator)
    private readonly creatorRepository: Repository<Creator>,
  ) {}

  async createLike(body: CreateLikeRequest): Promise<Like> {
    const like = new Like();
    console.log('body-createLike: ', body);

    //いいねした側のプロフィールを取得
    const requestor = await this.userRepository.findOne({
      where: { id: body.requestorId },
    });
    if (!requestor) {
      throw new HttpException('Requestor not found', HttpStatus.NOT_FOUND);
    }
    like.requestor = requestor;

    //いいねされた側のプロフィールを取得
    if (body.targetType === 'venue') {
      like.venue = await this.venueRepository.findOne({
        where: { id: body.targetId },
      });
      if (!like.venue)
        throw new HttpException('Venue not found', HttpStatus.NOT_FOUND);
    } else if (body.targetType === 'creator') {
      like.creator = await this.creatorRepository.findOne({
        where: { id: body.targetId },
      });
      if (!like.creator)
        throw new HttpException('Creator not found', HttpStatus.NOT_FOUND);
    } else if (body.targetType === 'supporter') {
      like.supporter = await this.userRepository.findOne({
        where: { id: body.targetId },
      });
      if (!like.supporter)
        throw new HttpException('Supporter not found', HttpStatus.NOT_FOUND);
    }

    //レコード保存
    try {
      const savedLike = await this.likeRepository.save(like);
      console.log(savedLike);
      return savedLike;
    } catch (e) {
      // likely unique constraint violation (already liked)
      throw new HttpException('Already liked', HttpStatus.CONFLICT);
    }
  }

  async deleteLike(id: number): Promise<{ deleted: boolean }> {
    const like = await this.likeRepository.findOne({ where: { id } });
    if (!like) {
      throw new HttpException('Like not found', HttpStatus.NOT_FOUND);
    }
    await this.likeRepository.remove(like);
    return { deleted: true };
  }

  //いいね一覧のためのapi
  async getMyLikes(query: GetMyLikesRequest): Promise<Like[]> {
    const { userId, targetType } = query;
    console.log('target: ', targetType);
    const likes = await this.likeRepository
      .createQueryBuilder('like')
      .where('like.requestor_id = :userId', { userId })
      .getMany();
    console.log('likes: ', likes);

    if (likes.length === 0) {
      return [];
    }
    // if (targetType === 'venue') {
    //   const venueLikeIds = likes
    //     .filter((like) => like.venue !== null)
    //     .map((like) => like.venue.id);
    // } else if (targetType === 'creator') {
    //   likes.filter((like) => like.creator !== null);
    // } else if (targetType === 'supporter') {
    //   likes.filter((like) => like.supporter !== null);
    // }
    return likes;
  }
}
