import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  OneToMany,
} from "typeorm";
import { Creator } from "./creator.entity";
import { Venu } from "./venu.entity";
import { User } from "./user.entity";
import { Event } from "./event.entity";

export enum MatchingFrom {
  CREATOR = "creator",
  VENU = "venu",
}

@Entity({ name: "matching" })
export class Matching {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({
    type: "enum",
    enum: MatchingFrom,
    name: "from",
  })
  from: MatchingFrom;

  @Column({ type: "boolean", name: "matching_flag", default: false })
  matchingFlag: boolean;

  @ManyToOne(() => Creator, { onDelete: "CASCADE", nullable: true })
  @JoinColumn({ name: "creator_id" })
  creator: Creator;

  @ManyToOne(() => Venu, { onDelete: "CASCADE", nullable: true })
  @JoinColumn({ name: "venu_id" })
  venu: Venu;

  @ManyToOne(() => User, { onDelete: "CASCADE", nullable: true })
  @JoinColumn({ name: "from_user_id" })
  fromUser: User;

  @ManyToOne(() => User, { onDelete: "CASCADE", nullable: true })
  @JoinColumn({ name: "to_user_id" })
  toUser: User;

  @Column({ type: "datetime", name: "request_at", nullable: true })
  requestAt: Date;

  @Column({ type: "datetime", name: "matching_at", nullable: true })
  matchingAt: Date;

  @OneToMany(() => Event, (event) => event.matching)
  events: Event[];

  @CreateDateColumn({
    type: "datetime",
    name: "created_at",
  })
  createdAt: Date;

  @UpdateDateColumn({
    type: "timestamp",
    name: "updated_at",
  })
  updatedAt: Date;
}
