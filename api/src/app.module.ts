import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { UserModule } from './modules/user/user.module';
import { User } from './entities/user.entity';
import { Creator } from './entities/creator.entity';
import { Venue } from './entities/venue.entity';
import { Matching } from './entities/matching.entity';
import { AuthModule } from './modules/auth/auth.module';
import { VenueModule } from './modules/venue/venue.module';
import { CreatorModule } from './modules/creator/creator.module';
import { Opus } from './entities/opus.entity';
import { MatchingModule } from './modules/matching/matching.module';
import { Event } from './entities/event.entity';
import { EventModule } from './modules/event/event.module';
import { CreatorEvent } from './entities/createrEvent.entity';

@Module({
  imports: [
    ConfigModule.forRoot({ envFilePath: '.development.env' }),
    TypeOrmModule.forRoot({
      type: 'mysql',
      host: process.env.DB_HOST,
      port: 3306,
      username: process.env.DB_USERNAME,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_DATABASE,
      synchronize: false,
      migrationsRun: false,
      entities: [User, Creator, Venue, Matching, Opus, Event, CreatorEvent],
    }),
    UserModule,
    AuthModule,
    VenueModule,
    CreatorModule,
    MatchingModule,
    EventModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
