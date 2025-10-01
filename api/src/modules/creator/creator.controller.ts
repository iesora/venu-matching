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
} from "@nestjs/common";
import { CreatorService, CreateCreatorRequest } from "./creator.service";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { RequestWithUser } from "../user/user.controller";
import { UpdateCreatorRequest } from "./creator.service";

@Controller("creator")
export class CreatorController {
  constructor(private readonly creatorService: CreatorService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  async createCreator(
    @Body() body: CreateCreatorRequest,
    @Req() req: RequestWithUser
  ) {
    const creatorData = { ...body, userId: req.user.id };
    return await this.creatorService.createCreator(creatorData);
  }

  @Patch(":id")
  @UseGuards(JwtAuthGuard)
  async updateCreator(
    @Param() params: { id: number },
    @Body() body: UpdateCreatorRequest
  ) {
    return await this.creatorService.updateCreator(params.id, body);
  }

  @Get()
  @UseGuards(JwtAuthGuard)
  async getCreators(@Req() req: RequestWithUser) {
    console.log("req.user.id", req.user.id);

    return await this.creatorService.getCreators(req.user.id);
  }

  @Get("user/:userId")
  async getCreatorsByUserId(@Param() params: { userId: number }) {
    return await this.creatorService.getCreatorsByUserId(params.userId);
  }

  @Get(":id")
  async getCreatorById(@Param() params: { id: number }) {
    return await this.creatorService.getCreatorById(params.id);
  }

  @Delete(":id")
  async deleteCreator(@Param() params: { id: number }) {
    await this.creatorService.deleteCreator(params.id);
    return { message: "Creator deleted successfully" };
  }
}
