import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { Exclude } from 'class-transformer';
import { compareSync, hashSync } from 'bcryptjs';
import { Creator } from './creator.entity';
import { Venue } from './venue.entity';
import { Matching } from './matching.entity';
import { Event } from './event.entity';

export enum UserRole {
  ADMIN = 'admin',
  MEMBER = 'member',
}

export enum UserMode {
  NORMAL = 'normal',
  BUSINESS = 'business',
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

  @Column({
    type: 'enum',
    enum: UserMode,
    name: 'mode',
    default: UserMode.NORMAL,
  })
  mode: UserMode;

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

  @OneToMany(() => Creator, (creator) => creator.user)
  creators?: Creator[];

  @OneToMany(() => Venue, (venue) => venue.user)
  venues?: Venue[];

  @OneToMany(() => Matching, (matching) => matching.fromUser)
  fromMatchings?: Matching[];

  @OneToMany(() => Matching, (matching) => matching.toUser)
  toMatchings?: Matching[];

  @OneToMany(() => Event, (event) => event.fromUser)
  fromEvents?: Event[];

  @OneToMany(() => Event, (event) => event.toUser)
  toEvents?: Event[];
}
