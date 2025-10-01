import {
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from "typeorm";
import { User } from "./user.entity";
import { ChatGroup } from "./chatGroup.entity";

@Entity({ name: "chat_group_user" })
export class ChatGroupUser {
  @PrimaryGeneratedColumn({ name: "id" })
  id: number;

  @ManyToOne(() => User, (user) => user.chatGroupUsers)
  @JoinColumn({ name: "user_id" })
  user: User;

  @ManyToOne(() => ChatGroup, (chatGroup) => chatGroup.chatGroupUsers)
  @JoinColumn({ name: "chat_group_id" })
  chatGroup: ChatGroup;

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
