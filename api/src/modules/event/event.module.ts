import { Module } from '@nestjs/common';
import { EventController } from './event.controller';
import { EventService } from './event.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Event } from 'src/entities/event.entity';
import { CreatorEvent } from 'src/entities/createrEvent.entity';
import { Venue } from 'src/entities/venue.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Event, CreatorEvent, Venue])],
  controllers: [EventController],
  providers: [EventService],
})
export class EventModule {}
