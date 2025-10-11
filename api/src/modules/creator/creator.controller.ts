import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  UseGuards,
  Req,
  Patch,
} from '@nestjs/common';
import {
  CreatorService,
  CreateCreatorRequest,
  UpdateCreatorRequest,
  CreateOpusRequest,
  UpdateOpusRequest,
} from './creator.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RequestWithUser } from '../user/user.controller';

@Controller('creator')
export class CreatorController {
  constructor(private readonly creatorService: CreatorService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  async createCreator(
    @Body() body: CreateCreatorRequest,
    @Req() req: RequestWithUser,
  ) {
    const creatorData = { ...body, userId: req.user.id };
    return await this.creatorService.createCreator(creatorData);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  async updateCreator(
    @Param() params: { id: number },
    @Body() body: UpdateCreatorRequest,
  ) {
    return await this.creatorService.updateCreator(params.id, body);
  }

  @Get()
  @UseGuards(JwtAuthGuard)
  async getCreators(@Req() req: RequestWithUser) {
    console.log('req.user.id', req.user.id);

    return await this.creatorService.getCreators(req.user.id);
  }

  @Get('user/:userId')
  async getCreatorsByUserId(
    @Param() params: { userId: number },
    @Req() req: RequestWithUser,
  ) {
    console.log('userId: ', params.userId);
    return await this.creatorService.getCreatorsByUserId(
      params.userId || req.user.id,
    );
  }

  @Get(':id')
  async getCreatorById(@Param() params: { id: number }) {
    return await this.creatorService.getCreatorById(params.id);
  }

  @Delete(':id')
  async deleteCreator(@Param() params: { id: number }) {
    await this.creatorService.deleteCreator(params.id);
    return { message: 'Creator deleted successfully' };
  }

  // Opus endpoints
  @Post(':creatorId/opus')
  @UseGuards(JwtAuthGuard)
  async createOpus(
    @Param() params: { creatorId: number },
    @Body() body: CreateOpusRequest,
  ) {
    return await this.creatorService.createOpus(params.creatorId, body);
  }

  @Patch(':creatorId/opus/:opusId')
  @UseGuards(JwtAuthGuard)
  async updateOpus(
    @Param() params: { creatorId: number; opusId: number },
    @Body() body: UpdateOpusRequest,
  ) {
    return await this.creatorService.updateOpus(
      params.creatorId,
      params.opusId,
      body,
    );
  }

  @Delete(':creatorId/opus/:opusId')
  @UseGuards(JwtAuthGuard)
  async deleteOpus(@Param() params: { creatorId: number; opusId: number }) {
    await this.creatorService.deleteOpus(params.creatorId, params.opusId);
    return { message: 'Opus deleted successfully' };
  }

  @Get(':creatorId/opus')
  async getOpusByCreatorId(@Param() params: { creatorId: number }) {
    return await this.creatorService.getOpusByCreatorId(params.creatorId);
  }
}
