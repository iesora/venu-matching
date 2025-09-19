import { MigrationInterface, QueryRunner } from "typeorm";

export class AddLatitudeLongitudeVenuTable1758285979917
  implements MigrationInterface
{
  name = "AddLatitudeLongitudeVenuTable1758285979917";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE \`venue\` DROP COLUMN \`latitude\``);
    await queryRunner.query(
      `ALTER TABLE \`venue\` ADD \`latitude\` decimal(10,8) NULL`
    );
    await queryRunner.query(`ALTER TABLE \`venue\` DROP COLUMN \`longitude\``);
    await queryRunner.query(
      `ALTER TABLE \`venue\` ADD \`longitude\` decimal(11,8) NULL`
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE \`venue\` DROP COLUMN \`longitude\``);
    await queryRunner.query(
      `ALTER TABLE \`venue\` ADD \`longitude\` varchar(255) NULL`
    );
    await queryRunner.query(`ALTER TABLE \`venue\` DROP COLUMN \`latitude\``);
    await queryRunner.query(
      `ALTER TABLE \`venue\` ADD \`latitude\` varchar(255) NULL`
    );
  }
}
