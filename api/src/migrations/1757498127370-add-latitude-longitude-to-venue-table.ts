import { MigrationInterface, QueryRunner } from "typeorm";

export class AddLatitudeLongitudeToVenueTable1757498127370
  implements MigrationInterface
{
  name = "AddLatitudeLongitudeToVenueTable1757498127370";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`venu\` ADD \`latitude\` varchar(255) NULL`
    );
    await queryRunner.query(
      `ALTER TABLE \`venu\` ADD \`longitude\` varchar(255) NULL`
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE \`venu\` DROP COLUMN \`longitude\``);
    await queryRunner.query(`ALTER TABLE \`venu\` DROP COLUMN \`latitude\``);
  }
}
