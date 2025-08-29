import { Seeder } from 'typeorm-extension';
import { DataSource } from 'typeorm';
import { Course } from '../entities/course.entity';

export default class CourseSeeder implements Seeder {
  async run(dataSource: DataSource): Promise<void> {
    const courseRepository = dataSource.getRepository(Course);

    // trainerデータを挿入
    await courseRepository.insert([
      {
        name: 'コース1',
        fee: 10000,
      },
      {
        name: 'コース2',
        fee: 20000,
      },
    ]);
  }
}
