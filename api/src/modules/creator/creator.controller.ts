import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  UseGuards,
  Req,
} from '@nestjs/common';
import { CreatorService, CreateCreatorRequest } from './creator.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RequestWithUser } from '../user/user.controller';

@Controller('creator')
@UseGuards(JwtAuthGuard)
export class CreatorController {
  constructor(private readonly creatorService: CreatorService) {}

  @Post()
  async createCreator(
    @Body() body: CreateCreatorRequest,
    @Req() req: RequestWithUser,
  ) {
    const creatorData = { ...body, userId: req.user.id };
    return await this.creatorService.createCreator(creatorData);
  }

  @Get()
  async getAllCreators() {
    return await this.creatorService.getAllCreators();
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
}
