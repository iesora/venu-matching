import { runSeeders } from 'typeorm-extension';
import { AppDataSource } from '../utils/data-source';

async function main() {
  await AppDataSource.initialize();
  await runSeeders(AppDataSource, {
    seeds: [__dirname + '/user.seeder.ts'],
  });
  await AppDataSource.destroy();
}

main()
  .then(() => console.log('Seeding completed successfully'))
  .catch((error) => console.error('Seeding failed:', error));
