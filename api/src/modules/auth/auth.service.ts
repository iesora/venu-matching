import { JwtService } from "@nestjs/jwt";
import { User } from "../../entities/user.entity"; // UserRole
import { Repository } from "typeorm";
import { InjectRepository } from "@nestjs/typeorm";
import { HttpException, HttpStatus, Injectable } from "@nestjs/common";
import { LoginUserRequest } from "./auth.controller";
import { compareSync } from "bcryptjs";
import { UserRole } from "src/entities/user.entity";

@Injectable()
export class AuthService {
  constructor(
    private readonly jwtService: JwtService,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>
  ) {}

  public createToken(user: Partial<User>): string {
    const accessToken = this.jwtService.sign({
      id: user.id,
      email: user.email,
    });
    return accessToken;
  }

  async login(body: LoginUserRequest) {
    const { email, password } = body;
    const existUser = await this.userRepository.findOne({
      select: ["password", "email", "id"],
      where: { email },
    });
    console.log(existUser);
    const isMatchPassword = compareSync(password, existUser.password);

    if (!existUser || !isMatchPassword) {
      throw new HttpException(
        "some infomation invalid",
        // tslint:disable-next-line: trailing-comma
        HttpStatus.BAD_REQUEST
      );
    }
    const token = this.createToken(existUser);
    const res = { ...existUser, token };
    console.log("res", res);
    return res;
  }

  async validateUser(payload: User): Promise<any> {
    return this.userRepository.findOne({
      where: { id: payload.id },
    });
  }

  async loginForAdmin(body: LoginUserRequest): Promise<any> {
    const { email, password } = body;
    const existUser = await this.userRepository.findOne({
      select: ["password", "email", "id", "role"],
      where: { email },
    });
    console.log("existUser", existUser);
    if (existUser.role !== UserRole.ADMIN) {
      throw new HttpException(
        "some infomation invalid",
        // tslint:disable-next-line: trailing-comma
        HttpStatus.BAD_REQUEST
      );
    }

    const isMatchPassword = compareSync(password, existUser.password);
    console.log("isMatchPassword", isMatchPassword);
    if (!existUser || !isMatchPassword) {
      throw new HttpException(
        "some infomation invalid",
        // tslint:disable-next-line: trailing-comma
        HttpStatus.BAD_REQUEST
      );
    }
    const token = this.createToken(existUser);
    const res = { ...existUser, token };
    return res;
  }
}
