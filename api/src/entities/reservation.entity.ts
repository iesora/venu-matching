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
import { Course } from './course.entity';
import { User } from './user.entity';
import { CandidateDate } from './candidateDate,entity';
//import { Customer } from './customer.entity';
//import { Payment } from './payment.entity';

export enum ReservationStatus {
  PENDING = 'pending', // 未確定
  CONFIRMED = 'confirmed', // 確定
  CANCELLED = 'cancelled', // キャンセル
}

export enum PaymentStatus {
  UNPAID = 'unpaid', // 未決済
  PAID = 'paid', // 決済済
  CANCELLED = 'cancelled', // キャンセル
}

@Entity({ name: 'reservation' })
export class Reservation {
  @PrimaryGeneratedColumn()
  id: number;

  // 名前
  @Column({ type: 'varchar', length: 500, name: 'name', default: '' })
  name: string;

  // 予約日時
  @Column({ type: 'datetime', name: 'reservation_date' })
  reservationDate: Date;

  // TEL
  @Column({ type: 'varchar', length: 500, name: 'tel', default: '' })
  tel: string;

  // 削除フラグ
  @Column({ type: 'boolean', name: 'delete_flag', default: false })
  deleteFlag: boolean;

  // コース
  @ManyToOne(() => Course, (course) => course.reservations, {
    onUpdate: 'CASCADE',
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'course_id' })
  course?: Course;

  // ユーザー
  @ManyToOne(() => User, (user) => user.reservations, {
    onUpdate: 'CASCADE',
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'user_id' })
  user?: User;

  @OneToMany(() => CandidateDate, (candidateDate) => candidateDate.reservation)
  candidateDates?: CandidateDate[];

  /** 
  // 顧客
  @ManyToOne(() => Customer, (customer) => customer.reservations, {
    onUpdate: 'CASCADE',
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'customer_id' })
  customer?: Customer;

  // 決済
  @OneToOne(() => Payment, (payment) => payment.reservation)
  payment?: Payment;
 

  // 予約ステータス
  @Column({
    type: 'enum',
    enum: ReservationStatus,
    name: 'status',
    default: ReservationStatus.PENDING,
  })
  status: ReservationStatus;

  // 決済ステータス
  @Column({
    type: 'enum',
    enum: PaymentStatus,
    name: 'payment_status',
    default: PaymentStatus.UNPAID,
  })
  paymentStatus: PaymentStatus;

   */

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
