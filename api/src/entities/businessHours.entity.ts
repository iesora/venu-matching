import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Dental } from './dental.entity';

export enum DayOfWeek {
  MONDAY = 'monday',
  TUESDAY = 'tuesday',
  WEDNESDAY = 'wednesday',
  THURSDAY = 'thursday',
  FRIDAY = 'friday',
  SATURDAY = 'saturday',
  SUNDAY = 'sunday',
}

@Entity({ name: 'business_hours' })
export class BusinessHours {
  @PrimaryGeneratedColumn()
  id: number;

  // 日付
  @Column({ type: 'date', name: 'date', nullable: true })
  date: Date;

  // 開始時間
  @Column({ type: 'datetime', name: 'start_at', nullable: true })
  startAt: Date;

  // 終了時間
  @Column({ type: 'datetime', name: 'end_at', nullable: true })
  endAt: Date;

  // 曜日
  @Column({
    type: 'enum',
    name: 'day_of_week',
    enum: DayOfWeek,
    default: DayOfWeek.MONDAY,
  })
  dayOfWeek: DayOfWeek;

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

  // Dentalテーブルとのリレーション
  @ManyToOne(() => Dental, (dental) => dental.businessHours)
  @JoinColumn({ name: 'dental_id' })
  dental: Dental;
}
