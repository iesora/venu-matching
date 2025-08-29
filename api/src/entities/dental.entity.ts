import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from 'typeorm';
import { Dentist } from './dentist.entity';
import { Course } from './course.entity';
import { BusinessHours } from './businessHours.entity';
import { Staff } from './staff.entity';
import { User } from './user.entity';

// 都道府県のEnum定義
export enum Prefecture {
  HOKKAIDO = '北海道',
  AOMORI = '青森県',
  IWATE = '岩手県',
  MIYAGI = '宮城県',
  AKITA = '秋田県',
  YAMAGATA = '山形県',
  FUKUSHIMA = '福島県',
  IBARAKI = '茨城県',
  TOCHIGI = '栃木県',
  GUNMA = '群馬県',
  SAITAMA = '埼玉県',
  CHIBA = '千葉県',
  TOKYO = '東京都',
  KANAGAWA = '神奈川県',
  NIIGATA = '新潟県',
  TOYAMA = '富山県',
  ISHIKAWA = '石川県',
  FUKUI = '福井県',
  YAMANASHI = '山梨県',
  NAGANO = '長野県',
  GIFU = '岐阜県',
  SHIZUOKA = '静岡県',
  AICHI = '愛知県',
  MIE = '三重県',
  SHIGA = '滋賀県',
  KYOTO = '京都府',
  OSAKA = '大阪府',
  HYOGO = '兵庫県',
  NARA = '奈良県',
  WAKAYAMA = '和歌山県',
  TOTTORI = '鳥取県',
  SHIMANE = '島根県',
  OKAYAMA = '岡山県',
  HIROSHIMA = '広島県',
  YAMAGUCHI = '山口県',
  TOKUSHIMA = '徳島県',
  KAGAWA = '香川県',
  EHIME = '愛媛県',
  KOCHI = '高知県',
  FUKUOKA = '福岡県',
  SAGA = '佐賀県',
  NAGASAKI = '長崎県',
  KUMAMOTO = '熊本県',
  OITA = '大分県',
  MIYAZAKI = '宮崎県',
  KAGOSHIMA = '鹿児島県',
  OKINAWA = '沖縄県',
}
export enum Category {
  GENERAL = '一般歯科',
  PEDIATRIC = '小児歯科',
  ORTHODONTICS = '矯正歯科',
  ORAL = '口腔外科',
  OTHER = 'その他',
}

@Entity('dentals')
export class Dental {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 255 })
  name: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  address: string;

  @Column({ type: 'varchar', length: 20, nullable: true })
  phone: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  email: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  website: string;

  @Column({ type: 'varchar', length: 1000, nullable: true })
  description: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  opening_hours: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  access: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  image_url: string;

  // 追加カラム
  @Column({ type: 'varchar', length: 255, nullable: true })
  director: string; // 院長名

  @Column({ type: 'varchar', length: 255, nullable: true })
  specialties: string; // 診療科目（例：一般歯科, 小児歯科, 矯正歯科など）

  @Column({ type: 'varchar', length: 255, nullable: true })
  parking: string; // 駐車場情報

  @Column({ type: 'varchar', length: 255, nullable: true })
  station: string; // 最寄り駅

  @Column({ type: 'float', nullable: true })
  latitude: number; // 緯度

  @Column({ type: 'float', nullable: true })
  longitude: number; // 経度

  @Column({ type: 'int', nullable: true })
  number_of_staff: number; // スタッフ数

  @Column({ type: 'varchar', length: 1000, nullable: true })
  features: string; // 特徴・アピールポイント

  @Column({ type: 'varchar', length: 1000, nullable: true })
  equipment: string; // 設備

  @Column({ type: 'varchar', length: 1000, nullable: true })
  languages: string; // 対応言語

  @Column({ type: 'enum', enum: Prefecture, nullable: true })
  prefecture: Prefecture; // 都道府県

  @Column({ type: 'enum', enum: Category, nullable: true })
  category: Category;

  @Column({ type: 'boolean', name: 'delete_flag', default: false })
  deleteFlag: boolean;

  // Dentistテーブルとのリレーション
  @OneToMany(() => Dentist, (dentist) => dentist.dental)
  dentists: Dentist[];

  // Staffテーブルとのリレーション
  @OneToMany(() => Staff, (staff) => staff.dental)
  staffs: Staff[];

  // Dentistテーブルとのリレーション
  @OneToMany(() => Course, (course) => course.dental)
  courses: Course[];

  // BusinessHoursテーブルとのリレーション
  @OneToMany(() => BusinessHours, (businessHours) => businessHours.dental)
  businessHours: BusinessHours[];

  // Userテーブルとのリレーション
  @OneToMany(() => User, (user) => user.dental)
  users: User[];
}
