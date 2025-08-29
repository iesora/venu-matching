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
import { Venu } from './venu.entity';

export enum MatchingFrom {
  CREATOR = 'creator',
  VENU = 'venu',
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

  @Column({ name: 'creator_id', nullable: true })
  creatorId: number;

  @ManyToOne(() => Venu, { onDelete: 'CASCADE', nullable: true })
  @JoinColumn({ name: 'venu_id' })
  venu: Venu;

  @Column({ name: 'venu_id', nullable: true })
  venuId: number;

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
