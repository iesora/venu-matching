import { Seeder } from 'typeorm-extension';
import { DataSource } from 'typeorm';
import { Staff } from '../entities/staff.entity';

export default class StaffSeeder implements Seeder {
  async run(dataSource: DataSource): Promise<void> {
    const staffRepository = dataSource.getRepository(Staff);

    // staffデータを挿入
    await staffRepository.insert([
      {
        firstName: 'テスト',
        lastName: '山田',
        firstNameKana: 'テスト',
        lastNameKana: 'ヤマダ',
        email: 'staff1@example.com',
        address: '東京都千代田区永田町1-7-1',
        birthDate: new Date(),
      },
      {
        firstName: 'テスト',
        lastName: '田中',
        firstNameKana: 'テスト',
        lastNameKana: 'タナカ',
        email: 'staff2@example.com',
        address: '東京都千代田区永田町1-7-1',
        birthDate: new Date(),
      },
    ]);
  }
}
