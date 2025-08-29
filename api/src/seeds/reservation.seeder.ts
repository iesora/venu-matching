import { Seeder } from 'typeorm-extension';
import { DataSource } from 'typeorm';
import { Reservation } from '../entities/reservation.entity';

export default class ReservationSeeder implements Seeder {
  async run(dataSource: DataSource): Promise<void> {
    const reservationRepository = dataSource.getRepository(Reservation);

    // reservationデータを挿入
    await reservationRepository.insert([
      {
        name: 'test',
        reservationDate: new Date(),
        tel: '09012345678',
        course: { id: 1 },
      },
    ]);
  }
}
