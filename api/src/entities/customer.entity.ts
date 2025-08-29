import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { Payment } from './payment.entity';

export enum Gender {
  MALE = 'male',
  FEMALE = 'female',
  OTHER = 'other',
}

export enum BloodType {
  A = 'A',
  B = 'B',
  O = 'O',
  AB = 'AB',
  UNKNOWN = 'unknown',
}

@Entity({ name: 'customer' })
export class Customer {
  @PrimaryGeneratedColumn()
  id: number;

  // LIFFのユーザーID
  @Column({ type: 'varchar', length: 500, name: 'liff_uuid', default: '' })
  liffUUID: string;

  // 名前
  @Column({ type: 'varchar', length: 500, name: 'name', default: '' })
  name: string;

  // 性別
  @Column({ type: 'enum', enum: Gender, name: 'gender', default: Gender.MALE })
  gender: Gender;

  // 血液型
  @Column({
    type: 'enum',
    enum: BloodType,
    name: 'blood_type',
    default: BloodType.UNKNOWN,
  })
  bloodType: BloodType;

  // 生年月日
  @Column({ type: 'date', name: 'birth_date', default: null })
  birthDate: Date;

  // 電話番号
  @Column({ type: 'varchar', length: 500, name: 'tel', default: '' })
  tel: string;

  // 住所
  @Column({ type: 'varchar', length: 500, name: 'address', default: '' })
  address: string;

  // 注意事項（眉毛）
  @Column({ type: 'varchar', length: 500, name: 'attention', default: '' })
  attention: string;

  // 顧客メモ
  @Column({ type: 'varchar', length: 500, name: 'memo', default: '' })
  memo: string;

  // 初回来店日
  @Column({ type: 'date', name: 'first_visit_date', default: null })
  firstVisitDate: Date;
  /**
  // 予約
  @OneToMany(() => Reservation, (reservation) => reservation.customer)
  reservations?: Reservation[];
 */
  // 決済
  @OneToMany(() => Payment, (payment) => payment.customer)
  payments?: Payment[];

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
