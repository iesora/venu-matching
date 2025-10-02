import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  Index,
  OneToOne,
  JoinColumn,
} from "typeorm";
import { ChatMessage } from "./message.entity";
import { ChatGroupUser } from "./chatGroupUser.entity";
import { Matching } from "./matching.entity";

@Entity({ name: "chat_groups" })
@Index(["name"], { fulltext: true, parser: "ngram" })
export class ChatGroup {
  @PrimaryGeneratedColumn({ name: "id" })
  id: number;

  @Column({ type: "varchar", length: 500, name: "name", default: "" })
  name: string;

  @Column({ type: "int", name: "unread_message_count" })
  unreadMessageCount: number;

  @Column({ type: "text", name: "latest_message" })
  latestMessage: string;

  @OneToMany(() => ChatMessage, (chatMessage) => chatMessage.chatGroup)
  chatMessages: ChatMessage[];

  @OneToMany(() => ChatGroupUser, (chatGroupUser) => chatGroupUser.chatGroup)
  chatGroupUsers: ChatGroupUser[];

  @OneToOne(() => Matching, (matching) => matching.chatGroups)
  @JoinColumn({ name: "matching_id" })
  matching: Matching;

  @CreateDateColumn({
    type: "datetime",
    name: "created_at",
  })
  createdAt: Date;

  // this column must be updated by creating group or send message
  @UpdateDateColumn({
    type: "timestamp",
    name: "updated_at",
  })
  updatedAt: Date;
}
