import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from "typeorm";
import { Creator } from "./creator.entity";
import { Event } from "./event.entity";

@Entity({ name: "creator_event" })
export class CreatorEvent {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => Creator, { onDelete: "CASCADE", nullable: true })
  @JoinColumn({ name: "creator_id" })
  creator: Creator;

  @ManyToOne(() => Event, { onDelete: "CASCADE", nullable: true })
  @JoinColumn({ name: "event_id" })
  event: Event;

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
