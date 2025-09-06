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

@Entity({ name: "opus" })
export class Opus {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: "varchar", length: 255, name: "name" })
  name: string;

  @Column({ type: "text", name: "description", nullable: true })
  description: string;

  @Column({ type: "varchar", length: 255, name: "image_url", nullable: true })
  imageUrl: string;

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

  @ManyToOne(() => Creator, { onDelete: "CASCADE", nullable: true })
  @JoinColumn({ name: "creator_id" })
  creator: Creator;
}
