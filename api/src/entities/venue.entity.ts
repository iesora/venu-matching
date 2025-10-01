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
import { Event } from "./event.entity";

@Entity({ name: "venue" })
export class Venue {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: "varchar", length: 255, name: "name" })
  name: string;

  @Column({ type: "varchar", length: 500, name: "address", nullable: true })
  address: string;

  // 緯度経度カラムを追加
  @Column({
    type: "decimal",
    precision: 10,
    scale: 8,
    name: "latitude",
    nullable: true,
  })
  latitude: number;

  @Column({
    type: "decimal",
    precision: 11,
    scale: 8,
    name: "longitude",
    nullable: true,
  })
  longitude: number;

  @Column({ type: "varchar", length: 20, name: "tel", nullable: true })
  tel: string;

  // 会場の内容（説明文など）を追加
  @Column({ type: "text", name: "description", nullable: true })
  description: string;

  // 会場の収容人数
  @Column({ type: "int", name: "capacity", nullable: true })
  capacity: number;

  // 会場の設備情報
  @Column({ type: "varchar", length: 1000, name: "facilities", nullable: true })
  facilities: string;

  // 会場の利用可能時間
  @Column({
    type: "varchar",
    length: 255,
    name: "available_time",
    nullable: true,
  })
  availableTime: string;

  // 会場の画像URL
  @Column({ type: "varchar", length: 1000, name: "image_url", nullable: true })
  imageUrl: string;

  @ManyToOne(() => User, { onDelete: "CASCADE", nullable: true })
  @JoinColumn({ name: "user_id" })
  user: User;

  @OneToMany(() => Event, (event) => event.venue)
  events?: Event[];

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
