import { runSeeders } from 'typeorm-extension';
import { AppDataSource } from '../utils/data-source';

async function main() {
  await AppDataSource.initialize();
  await runSeeders(AppDataSource, {
    seeds: [
      __dirname + '/user.seeder.ts',
      __dirname + '/course.seeder.ts',
      __dirname + '/staff.seeder.ts',
      __dirname + '/reservation.seeder.ts',
      __dirname + '/dental.seeder.ts',
    ],
  });
  await AppDataSource.destroy();
}

main()
  .then(() => console.log('Seeding completed successfully'))
  .catch((error) => console.error('Seeding failed:', error));
