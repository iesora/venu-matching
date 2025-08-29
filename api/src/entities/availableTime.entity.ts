import {
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Course } from './course.entity';

@Entity({ name: 'available_time' })
export class AvailableTime {
  @PrimaryGeneratedColumn()
  id: number;

  // コース nullable
  @ManyToOne(() => Course, (course) => course.availableTimes, {
    onUpdate: 'CASCADE',
    onDelete: 'CASCADE',
    nullable: true,
  })
  @JoinColumn({ name: 'course_id' })
  course?: Course;

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
