import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Exclude } from 'class-transformer';
import { compareSync, hashSync } from 'bcryptjs';
import { Reservation } from './reservation.entity';
import { Dental } from './dental.entity';

export enum UserRole {
  ADMIN = 'admin',
  MEMBER = 'member',
  DENTAL = 'dental',
}

export type RequestWithUser = {
  user: User;
};

@Entity({ name: 'user' })
export class User {
  static async comparePassword(pass0, pass1) {
    return compareSync(pass0, pass1);
  }

  static encryptPassword(password) {
    return hashSync(password, 10);
  }

  @PrimaryGeneratedColumn()
  id: number;

  @Column({
    type: 'enum',
    enum: UserRole,
    name: 'role',
    nullable: true,
  })
  role: UserRole;

  @Column({ type: 'varchar', length: 500, name: 'email', default: '' })
  email: string;

  @Exclude({ toPlainOnly: true })
  @Column({ length: 500, select: false })
  password: string;

  @OneToMany(() => Reservation, (reservation) => reservation.user)
  reservations?: Reservation[];

  // dental（親テーブル）とのリレーション
  @ManyToOne(() => Dental, (dental) => dental.users, {
    onDelete: 'CASCADE',
    onUpdate: 'CASCADE',
    nullable: true,
  })
  @JoinColumn({ name: 'dental_id' })
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
