import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  //  OneToOne,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
//import { Reservation } from './reservation.entity';
//import { Course } from './course.entity';
import { Customer } from './customer.entity';

@Entity({ name: 'payment' })
export class Payment {
  @PrimaryGeneratedColumn()
  id: number;

  // 名前
  @Column({ type: 'varchar', length: 500, name: 'name', default: '' })
  name: string;
  /**
  // 予約
  @OneToOne(() => Reservation, (reservation) => reservation.payment)
  @JoinColumn({ name: 'reservation_id' })
  reservation?: Reservation;
 */
  // 追加料金
  @Column({ type: 'int', name: 'additional_fee', default: 0 })
  additionalFee: number;

  // 決済日時
  @Column({ type: 'datetime', name: 'payment_date' })
  paymentDate: Date;

  /**
  // コース
  @ManyToOne(() => Course, (course) => course.payments, {
    onUpdate: 'CASCADE',
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'course_id' })
  course?: Course;
 */
  // 顧客
  @ManyToOne(() => Customer, (customer) => customer.payments, {
    onUpdate: 'CASCADE',
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'customer_id' })
  customer?: Customer;

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
