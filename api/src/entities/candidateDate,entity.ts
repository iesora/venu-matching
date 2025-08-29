import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
} from 'typeorm';
import { Reservation } from './reservation.entity';

@Entity({ name: 'candidate_date' })
export class CandidateDate {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'date', name: 'date' })
  date: Date;

  @CreateDateColumn({
    type: 'datetime',
    name: 'start_at',
  })
  startAt: Date;

  @CreateDateColumn({
    type: 'datetime',
    name: 'end_at',
  })
  endAt: Date;

  @ManyToOne(() => Reservation, (reservation) => reservation.candidateDates)
  reservation?: Reservation;

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
