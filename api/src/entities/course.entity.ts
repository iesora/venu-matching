import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  ManyToOne,
} from 'typeorm';
import { Reservation } from './reservation.entity';
import { AvailableTime } from './availableTime.entity';
//import { Payment } from './payment.entity';
import { Dental } from './dental.entity';

@Entity({ name: 'course' })
export class Course {
  @PrimaryGeneratedColumn()
  id: number;

  // 名前
  @Column({ type: 'varchar', length: 500, name: 'name', default: '' })
  name: string;

  // 料金
  @Column({ type: 'int', name: 'fee', default: 0 })
  fee: number;

  // 説明
  @Column({ type: 'varchar', length: 1000, name: 'description', default: 0 })
  description: string;

  // 説明
  @Column({ type: 'int', name: 'duration', default: 0 })
  duration: number;

  // 所要時間
  @Column({ type: 'int', name: 'duration_minutes', default: 30 })
  durationMinutes: number;

  // 削除フラグ
  @Column({ type: 'boolean', name: 'delete_flag', default: false })
  deleteFlag: boolean;

  @OneToMany(() => Reservation, (reservation) => reservation.course)
  reservations?: Reservation[];

  // availableTimeとOneToManyで紐づける
  @OneToMany(() => AvailableTime, (availableTime) => availableTime.course)
  availableTimes?: AvailableTime[];

  @ManyToOne(() => Dental, (dental) => dental.courses)
  dental?: Dental;

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
