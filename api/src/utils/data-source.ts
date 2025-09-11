import { DataSource } from 'typeorm';
import { User } from '../entities/user.entity';
import { Creator } from '../entities/creator.entity';
import { Venue } from '../entities/venue.entity';
import { Matching } from '../entities/matching.entity';
import { Opus } from '../entities/opus.entity';
import { Event } from '../entities/event.entity';
import { CreatorEvent } from '../entities/createrEvent.entity';

export const AppDataSource = new DataSource({
  type: 'mysql',
  host:
    process.env.NODE_ENV !== 'production' ? 'localhost' : process.env.DB_HOST,
  port: 3306,
  username:
    process.env.NODE_ENV !== 'production' ? 'develop' : process.env.DB_USERNAME,
  password:
    process.env.NODE_ENV !== 'production'
      ? 'password'
      : process.env.DB_PASSWORD,
  database:
    process.env.NODE_ENV !== 'production' ? 'develop' : process.env.DB_DATABASE,
  migrations:
    process.env.NODE_ENV === 'develop'
      ? ['src/migrations/*.ts']
      : ['dist/migrations/*.js'],
  synchronize: false,
  logging: true,
  entities: [User, Creator, Venue, Matching, Opus, Event, CreatorEvent],
});
