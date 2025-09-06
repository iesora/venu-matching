import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  UseGuards,
  Req,
  Query,
} from "@nestjs/common";
import { VenuService, CreateVenuRequest } from "./venu.service";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { RequestWithUser } from "../user/user.controller";

@Controller("venu")
export class VenuController {
  constructor(private readonly venuService: VenuService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  async createVenu(
    @Body() body: CreateVenuRequest,
    @Req() req: RequestWithUser
  ) {
    const venuData = { ...body, userId: req.user.id };
    return await this.venuService.createVenu(venuData);
  }

  @Get()
  async getVenusByUserId(@Query() query: { userId?: number }) {
    console.log(query);
    return await this.venuService.getVenus(query.userId);
  }

  @Get(":id")
  async getVenuById(@Param() params: { id: number }) {
    return await this.venuService.getVenuById(params.id);
  }

  @Delete(":id")
  @UseGuards(JwtAuthGuard)
  async deleteVenu(@Param() params: { id: number }) {
    await this.venuService.deleteVenu(params.id);
    return { message: "Venu deleted successfully" };
  }
}
