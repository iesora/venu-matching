import {
  Body,
  Controller,
  Delete,
  Get,
  Post,
  UseGuards,
  Req,
  Param,
  Query,
} from '@nestjs/common';
import { LikeService } from './like.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RequestWithUser } from '../user/user.controller';

export type CreateLikeRequest = {
  targetType: 'venue' | 'creator';
  targetId: number;
  requestorId: number;
};

export type GetMyLikesRequest = {
  userId: number;
  targetType: 'venue' | 'creator' | 'supporter';
};

@Controller('like')
@UseGuards(JwtAuthGuard)
export class LikeController {
  constructor(private readonly likeService: LikeService) {}

  @Get('me')
  async getMyLikes(
    @Req() req: RequestWithUser,
    @Query('targetType') targetType: 'venue' | 'creator' | 'supporter',
  ) {
    return await this.likeService.getMyLikes({
      userId: req.user.id,
      targetType,
    });
  }

  @Post()
  async create(@Req() req: RequestWithUser, @Body() body: CreateLikeRequest) {
    return await this.likeService.createLike({
      ...body,
      requestorId: req.user.id,
    });
  }

  @Delete(':id')
  async remove(@Param('id') id: number) {
    return await this.likeService.deleteLike(id);
  }
}
