import {
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  //   Unique,
} from 'typeorm';
import { User } from './user.entity';
import { Venue } from './venue.entity';
import { Creator } from './creator.entity';

@Entity()
//固有制約はつけたほうがいいのか？
// @Unique('UQ_like_user_venue', ['user', 'venue'])
// @Unique('UQ_like_user_creator', ['user', 'creator'])
export class Like {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => User, (user) => user.sendLikes, {
    nullable: false,
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'requestor_id' })
  requestor: User;

  @ManyToOne(() => User, (user) => user.receivedLikes, {
    nullable: true,
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'supporter_id' })
  supporter: User;

  @ManyToOne(() => Venue, (venue) => venue.likes, {
    nullable: true,
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'venue_id' })
  venue: Venue;

  @ManyToOne(() => Creator, (creator) => creator.likes, {
    nullable: true,
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'creator_id' })
  creator: Creator;

  @CreateDateColumn()
  createdAt: Date;
}
