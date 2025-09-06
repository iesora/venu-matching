import { Module } from "@nestjs/common";
import { AppController } from "./app.controller";
import { AppService } from "./app.service";
import { TypeOrmModule } from "@nestjs/typeorm";
import { ConfigModule } from "@nestjs/config";
import { UserModule } from "./modules/user/user.module";
import { User } from "./entities/user.entity";
import { Creator } from "./entities/creator.entity";
import { Venu } from "./entities/venu.entity";
import { Matching } from "./entities/matching.entity";
import { AuthModule } from "./modules/auth/auth.module";
import { VenuModule } from "./modules/venu/venu.module";
import { CreatorModule } from "./modules/creator/creator.module";
import { Opus } from "./entities/opus.entity";
import { MatchingModule } from "./modules/matching/matching.module";

@Module({
  imports: [
    ConfigModule.forRoot({ envFilePath: ".development.env" }),
    TypeOrmModule.forRoot({
      type: "mysql",
      host: process.env.DB_HOST,
      port: 3306,
      username: process.env.DB_USERNAME,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_DATABASE,
      synchronize: false,
      migrationsRun: false,
      entities: [User, Creator, Venu, Matching, Opus],
    }),
    UserModule,
    AuthModule,
    VenuModule,
    CreatorModule,
    MatchingModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
