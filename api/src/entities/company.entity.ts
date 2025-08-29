import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity({ name: 'company' })
export class Company {
  @PrimaryGeneratedColumn()
  id: number;

  // 登録番号
  @Column({
    type: 'varchar',
    length: 500,
    name: 'corporate_number',
    default: '',
  })
  corporateNumber: string;

  // 会社名
  @Column({ type: 'varchar', length: 500, name: 'name', default: '' })
  name: string;

  // 代表取締役
  @Column({ type: 'varchar', length: 500, name: 'CEO_name', default: '' })
  CEOName: string;

  // 郵便番号
  @Column({ type: 'varchar', length: 500, name: 'zip_code', default: '' })
  zipCode: string;

  // 住所
  @Column({ type: 'varchar', length: 500, name: 'address', default: '' })
  address: string;

  // メールアドレス
  @Column({ type: 'varchar', length: 500, name: 'email', default: '' })
  email: string;

  // 電話番号
  @Column({ type: 'varchar', length: 500, name: 'tel', default: '' })
  tel: string;

  // FAX
  @Column({ type: 'varchar', length: 500, name: 'fax', default: '' })
  fax: string;

  @CreateDateColumn({
    type: 'datetime',
    name: 'created_at',
  })
  createdAt: Date;

  @UpdateDateColumn({
    type: 'timestamp',
    name: 'updated_at',
  })
  updatedAt: Date;
}
