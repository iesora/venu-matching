import { Seeder } from 'typeorm-extension';
import { DataSource } from 'typeorm';
import { BusinessHours, DayOfWeek } from '../entities/businessHours.entity';
import { Dental } from '../entities/dental.entity';

export default class BusinessHoursSeeder implements Seeder {
  async run(dataSource: DataSource): Promise<void> {
    const businessHoursRepository = dataSource.getRepository(BusinessHours);
    const dentalRepository = dataSource.getRepository(Dental);
    const existDentalRepository = await dentalRepository.find();
    // existDentalRepositoryをfor文で回して、各Dentalに対してサンプルデータを挿入
    for (const dental of existDentalRepository) {
      await businessHoursRepository.insert([
        {
          dayOfWeek: DayOfWeek.MONDAY,
          startAt: new Date('1970-01-01T09:00:00'),
          endAt: new Date('1970-01-01T18:00:00'),
          dental: dental,
        },
        {
          dayOfWeek: DayOfWeek.TUESDAY,
          startAt: new Date('1970-01-01T09:00:00'),
          endAt: new Date('1970-01-01T18:00:00'),
          dental: dental,
        },
        {
          dayOfWeek: DayOfWeek.WEDNESDAY,
          startAt: new Date('1970-01-01T09:00:00'),
          endAt: new Date('1970-01-01T18:00:00'),
          dental: dental,
        },
        {
          dayOfWeek: DayOfWeek.THURSDAY,
          startAt: new Date('1970-01-01T09:00:00'),
          endAt: new Date('1970-01-01T18:00:00'),
          dental: dental,
        },
        {
          dayOfWeek: DayOfWeek.FRIDAY,
          startAt: new Date('1970-01-01T09:00:00'),
          endAt: new Date('1970-01-01T18:00:00'),
          dental: dental,
        },
        {
          dayOfWeek: DayOfWeek.SATURDAY,
          startAt: new Date('1970-01-01T10:00:00'),
          endAt: new Date('1970-01-01T16:00:00'),
          dental: dental,
        },
        {
          dayOfWeek: DayOfWeek.SUNDAY,
          startAt: null,
          endAt: null,
          dental: dental,
        },
      ]);
    }
  }
}
