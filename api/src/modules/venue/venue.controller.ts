import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  Patch,
  UseGuards,
  Req,
  Query,
} from '@nestjs/common';
import {
  VenueService,
  CreateVenueRequest,
  UpdateVenueRequest,
} from './venue.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RequestWithUser } from '../user/user.controller';

export type GetVenueWithMatchingDetailQuery = {
  venueId: number;
  creatorId: number;
  requestorId: number;
};

export type GetVenuesListByCreatorQuery = {
  creatorId: number;
  requestorId: number;
};

@Controller('venue')
export class VenueController {
  constructor(private readonly venueService: VenueService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  async createVenue(
    @Body() body: CreateVenueRequest,
    @Req() req: RequestWithUser,
  ) {
    const venueData = { ...body, userId: req.user.id };
    return await this.venueService.createVenue(venueData);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  async updateVenue(
    @Param() params: { id: number },
    @Body() body: UpdateVenueRequest,
  ) {
    return await this.venueService.updateVenue(params.id, body);
  }

  @Get()
  @UseGuards(JwtAuthGuard)
  async getVenuesByUserId(@Query() query: { userId?: number }) {
    return await this.venueService.getVenues(query.userId);
  }

  //いいねのみ紐づけて返す。サポーターもしくは会場からのリクエスト用
  @Get('list')
  @UseGuards(JwtAuthGuard)
  async getVenuesList(@Req() req: RequestWithUser) {
    return await this.venueService.getVenuesList(req.user.id);
  }

  //いいねに加えて、マッチングも紐づけて返す。クリエイターからのリクエスト用
  @Get('list/by-creator/:creatorId')
  @UseGuards(JwtAuthGuard)
  async getVenuesListByCreator(
    @Param() params: { creatorId: number },
    @Req() req: RequestWithUser,
  ) {
    return await this.venueService.getVenuesListByCreator({
      creatorId: params.creatorId,
      requestorId: req.user.id,
    });
  }

  @Get('detail/with-matching/:venueId/:creatorId')
  @UseGuards(JwtAuthGuard)
  async getVenueWithMatchingDetail(
    @Param() params: { venueId: number; creatorId: number },
    @Req() req: RequestWithUser,
  ) {
    return await this.venueService.getVenueWithMatchingDetail({
      venueId: params.venueId,
      creatorId: params.creatorId,
      requestorId: req.user.id,
    });
  }

  @Get(':id')
  async getVenueById(@Param() params: { id: number }) {
    return await this.venueService.getVenueById(params.id);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  async deleteVenue(@Param() params: { id: number }) {
    await this.venueService.deleteVenue(params.id);
    return { message: 'Venue deleted successfully' };
  }
}
