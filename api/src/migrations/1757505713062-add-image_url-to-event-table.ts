import { MigrationInterface, QueryRunner } from "typeorm";

export class AddImageUrlToEventTable1757505713062
  implements MigrationInterface
{
  name = "AddImageUrlToEventTable1757505713062";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`event\` ADD \`image_url\` varchar(255) NOT NULL`
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE \`event\` DROP COLUMN \`image_url\``);
  }
}
