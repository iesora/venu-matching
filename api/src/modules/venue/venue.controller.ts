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
  async getVenuesByUserId(@Query() query: { userId?: number }) {
    return await this.venueService.getVenues(query.userId);
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
