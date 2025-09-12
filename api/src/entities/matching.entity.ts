import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Creator } from './creator.entity';
import { Venue } from './venue.entity';
import { User } from './user.entity';

export enum MatchingFrom {
  CREATOR = 'creator',
  VENUE = 'venue',
}

@Entity({ name: 'matching' })
export class Matching {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({
    type: 'enum',
    enum: MatchingFrom,
    name: 'from',
  })
  from: MatchingFrom;

  @Column({ type: 'boolean', name: 'matching_flag', default: false })
  matchingFlag: boolean;

  @ManyToOne(() => Creator, { onDelete: 'CASCADE', nullable: true })
  @JoinColumn({ name: 'creator_id' })
  creator: Creator;

  @ManyToOne(() => Venue, { onDelete: 'CASCADE', nullable: true })
  @JoinColumn({ name: 'venue_id' })
  venue: Venue;

  @ManyToOne(() => User, { onDelete: 'CASCADE', nullable: true })
  @JoinColumn({ name: 'from_user_id' })
  fromUser: User;

  @ManyToOne(() => User, { onDelete: 'CASCADE', nullable: true })
  @JoinColumn({ name: 'to_user_id' })
  toUser: User;

  @Column({ type: 'datetime', name: 'request_at', nullable: true })
  requestAt: Date;

  @Column({ type: 'datetime', name: 'matching_at', nullable: true })
  matchingAt: Date;

  @CreateDateColumn({
    type: 'datetime',
    name: 'created_at',
  })
  createdAt: Date;

  @UpdateDateColumn({
    type: 'timestamp',
    name: 'updated_at',
  })
  updatedAt: Date;
}
