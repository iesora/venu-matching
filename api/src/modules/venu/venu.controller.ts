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
import { VenuService, CreateVenuRequest } from './venu.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RequestWithUser } from '../user/user.controller';

@Controller('venu')
@UseGuards(JwtAuthGuard)
export class VenuController {
  constructor(private readonly venuService: VenuService) {}

  @Post()
  async createVenu(
    @Body() body: CreateVenuRequest,
    @Req() req: RequestWithUser,
  ) {
    const venuData = { ...body, userId: req.user.id };
    return await this.venuService.createVenu(venuData);
  }

  @Get()
  async getAllVenus() {
    return await this.venuService.getAllVenus();
  }

  @Get(':id')
  async getVenuById(@Param() params: { id: number }) {
    return await this.venuService.getVenuById(params.id);
  }

  @Delete(':id')
  async deleteVenu(@Param() params: { id: number }) {
    await this.venuService.deleteVenu(params.id);
    return { message: 'Venu deleted successfully' };
  }
}
