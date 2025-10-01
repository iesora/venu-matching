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
import { User } from "./user.entity";
import { ChatGroup } from "./chatGroup.entity";

export enum MatchingStatus {
  PENDING = "pending",
  MATCHING = "matching",
  REJECTED = "rejected",
}

@Entity({ name: "matching" })
export class Matching {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: "boolean", name: "matching_flag", default: false })
  matchingFlag: boolean;

  @ManyToOne(() => User, { onDelete: "CASCADE", nullable: true })
  @JoinColumn({ name: "from_user_id" })
  fromUser: User;

  @ManyToOne(() => User, { onDelete: "CASCADE", nullable: true })
  @JoinColumn({ name: "to_user_id" })
  toUser: User;

  @OneToMany(() => ChatGroup, (chatGroup) => chatGroup.matching)
  chatGroups: ChatGroup[];

  @Column({ type: "enum", name: "status", enum: MatchingStatus })
  status: MatchingStatus;

  @Column({ type: "datetime", name: "request_at", nullable: true })
  requestAt: Date;

  @Column({ type: "datetime", name: "matching_at", nullable: true })
  matchingAt: Date;

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
