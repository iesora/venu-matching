import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from "typeorm";
import { User } from "./user.entity";
import { Matching } from "./matching.entity";
import { Opus } from "./opus.entity";
import { CreatorEvent } from "./createrEvent.entity";

@Entity({ name: "creator" })
export class Creator {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: "varchar", length: 255, name: "name" })
  name: string;

  @Column({ type: "text", name: "description", nullable: true })
  description: string;

  @Column({ type: "varchar", length: 255, name: "email", nullable: true })
  email: string;

  @Column({ type: "varchar", length: 255, name: "website", nullable: true })
  website: string;

  @Column({ type: "varchar", length: 255, name: "image_url", nullable: true })
  imageUrl: string;

  @Column({
    type: "varchar",
    length: 255,
    name: "phone_number",
    nullable: true,
  })
  phoneNumber: string;

  @Column({
    type: "varchar",
    length: 255,
    name: "social_media_handle",
    nullable: true,
  })
  socialMediaHandle: string;

  @ManyToOne(() => User, { onDelete: "CASCADE", nullable: true })
  @JoinColumn({ name: "user_id" })
  user: User;

  @OneToMany(() => Matching, (matching) => matching.creator)
  matchings?: Matching[];

  @OneToMany(() => Opus, (opus) => opus.creator)
  opuses?: Opus[];

  @OneToMany(() => CreatorEvent, (creatorEvent) => creatorEvent.creator)
  creatorEvents?: CreatorEvent[];

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
