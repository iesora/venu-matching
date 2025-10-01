import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from "typeorm";
import { ChatGroup } from "./chatGroup.entity";
import { User } from "./user.entity";

export enum MessageType {
  FILE = "file",
  TEXT = "text",
  IMAGE = "image",
}

@Entity({ name: "chat_messages" })
export class ChatMessage {
  @PrimaryGeneratedColumn({ name: "id" })
  id: number;

  @Column({ name: "text", type: "varchar", length: 5000, default: "" })
  text: string;

  @Column({ name: "url", type: "varchar", length: 5000, default: "" })
  url: string;

  @Column({
    name: "type",
    type: "enum",
    enum: MessageType,
    default: MessageType.TEXT,
  })
  type: MessageType;

  @ManyToOne(() => ChatGroup, (chatGroup) => chatGroup.chatMessages)
  @JoinColumn({ name: "chat_group_id" })
  chatGroup: ChatGroup;

  @ManyToOne(() => User, (user) => user.messages, {
    onUpdate: "CASCADE",
    onDelete: "CASCADE",
  })
  @JoinColumn({ name: "author_id" })
  author?: User;

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
