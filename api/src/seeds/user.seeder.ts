import { Seeder } from 'typeorm-extension';
import { DataSource } from 'typeorm';
import { User } from '../entities/user.entity';

export default class UserSeeder implements Seeder {
  async run(dataSource: DataSource): Promise<void> {
    const userRepository = dataSource.getRepository(User);

    // userデータを挿入
    await userRepository.insert([
      {
        email: 'admin@example.com',
        password: User.encryptPassword('password'),
      },
    ]);
  }
}
