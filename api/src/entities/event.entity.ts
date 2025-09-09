import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from "typeorm";
import { Matching } from "./matching.entity";
import { User } from "./user.entity";

export enum MatchingStatus {
  PENDING = "pending",
  MATCHING = "matching",
  REJECTED = "rejected",
}

@Entity({ name: "event" })
export class Event {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: "varchar", length: 255, name: "title" })
  title: string;

  @Column({ type: "text", name: "description", nullable: true })
  description: string;

  @Column({ type: "datetime", name: "start_date" })
  startDate: Date;

  @Column({ type: "datetime", name: "end_date" })
  endDate: Date;

  @ManyToOne(() => Matching, (matching) => matching.events, {
    onDelete: "CASCADE",
  })
  @JoinColumn({ name: "matching_id" })
  matching: Matching;

  @ManyToOne(() => User, (user) => user.fromEvents, {
    onDelete: "CASCADE",
    nullable: true,
  })
  @JoinColumn({ name: "from_user_id" })
  fromUser: User;

  @ManyToOne(() => User, (user) => user.toEvents, {
    onDelete: "CASCADE",
    nullable: true,
  })
  @JoinColumn({ name: "to_user_id" })
  toUser: User;

  @Column({ type: "datetime", name: "request_at", nullable: true })
  requestAt: Date;

  @Column({ type: "datetime", name: "matching_at", nullable: true })
  matchingAt: Date;

  @Column({ type: "datetime", name: "reject_at", nullable: true })
  rejectAt: Date;

  @Column({
    type: "enum",
    enum: MatchingStatus,
    name: "matching_status",
    nullable: true,
  })
  matchingStatus: MatchingStatus;

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
