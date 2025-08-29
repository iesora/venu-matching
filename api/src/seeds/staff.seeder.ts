import { Seeder } from 'typeorm-extension';
import { DataSource } from 'typeorm';
import { Staff } from '../entities/staff.entity';

export default class StaffSeeder implements Seeder {
  async run(dataSource: DataSource): Promise<void> {
    const staffRepository = dataSource.getRepository(Staff);

    // 各歯科医院（id 1-24）に15人ずつスタッフを追加
    const staffData = [];

    for (let dentalId = 1; dentalId <= 24; dentalId++) {
      for (let staffIndex = 1; staffIndex <= 15; staffIndex++) {
        const staff = {
          firstName: `スタッフ${staffIndex}`,
          lastName: `歯科${dentalId}`,
          firstNameKana: `スタッフ${staffIndex}`,
          lastNameKana: `シカ${dentalId}`,
          birthDate: new Date(
            1980 + Math.floor(Math.random() * 30),
            Math.floor(Math.random() * 12),
            Math.floor(Math.random() * 28) + 1,
          ),
          email: `staff${staffIndex}@dental${dentalId}.com`,
          address: `東京都新宿区西新宿${dentalId}-${staffIndex}-${
            Math.floor(Math.random() * 999) + 1
          }`,
          deleteFlag: false,
          dental: { id: dentalId },
        };
        staffData.push(staff);
      }
    }

    await staffRepository.insert(staffData);
  }
}
