import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  OneToMany,
} from 'typeorm';
import { CreatorEvent } from './createrEvent.entity';
import { Venue } from './venue.entity';

@Entity({ name: 'event' })
export class Event {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'varchar', length: 255, name: 'title' })
  title: string;

  @Column({ type: 'varchar', length: 255, name: 'image_url' })
  imageUrl: string;

  @Column({ type: 'text', name: 'description', nullable: true })
  description: string;

  @Column({ type: 'datetime', name: 'start_date' })
  startDate: Date;

  @Column({ type: 'datetime', name: 'end_date' })
  endDate: Date;

  @OneToMany(() => CreatorEvent, (creatorEvent) => creatorEvent.event)
  creatorEvents?: CreatorEvent[];

  @ManyToOne(() => Venue, (venue) => venue.events, {
    onDelete: 'CASCADE',
    nullable: true,
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
