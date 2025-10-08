import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  OneToOne,
} from 'typeorm';
import { ChatGroup } from './chatGroup.entity';
import { Creator } from './creator.entity';
import { Venue } from './venue.entity';

export enum MatchingStatus {
  PENDING = 'pending',
  MATCHING = 'matching',
  REJECTED = 'rejected',
}

export enum RequestorType {
  CREATOR = 'creator',
  VENUE = 'venue',
}

@Entity({ name: 'matching' })
export class Matching {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'enum', name: 'requestor_type', enum: RequestorType })
  requestorType: RequestorType;

  @OneToOne(() => ChatGroup, (chatGroup) => chatGroup.matching)
  chatGroups: ChatGroup[];

  @Column({ type: 'enum', name: 'status', enum: MatchingStatus })
  status: MatchingStatus;

  @Column({ type: 'datetime', name: 'request_at', nullable: true })
  requestAt: Date;

  @Column({ type: 'datetime', name: 'matching_at', nullable: true })
  matchingAt: Date;

  @ManyToOne(() => Creator, (creator) => creator.matchings, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'creator_id' })
  creator: Creator;

  @ManyToOne(() => Venue, (venue) => venue.matchings, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'venue_id' })
  venue: Venue;

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
