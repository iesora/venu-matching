import { MigrationInterface, QueryRunner } from "typeorm";

export class AddNewColumnVenuTable1756990887449 implements MigrationInterface {
  name = "AddNewColumnVenuTable1756990887449";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`venu\` ADD \`description\` text NULL`
    );
    await queryRunner.query(`ALTER TABLE \`venu\` ADD \`capacity\` int NULL`);
    await queryRunner.query(
      `ALTER TABLE \`venu\` ADD \`facilities\` varchar(1000) NULL`
    );
    await queryRunner.query(
      `ALTER TABLE \`venu\` ADD \`available_time\` varchar(255) NULL`
    );
    await queryRunner.query(
      `ALTER TABLE \`venu\` ADD \`image_url\` varchar(1000) NULL`
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE \`venu\` DROP COLUMN \`image_url\``);
    await queryRunner.query(
      `ALTER TABLE \`venu\` DROP COLUMN \`available_time\``
    );
    await queryRunner.query(`ALTER TABLE \`venu\` DROP COLUMN \`facilities\``);
    await queryRunner.query(`ALTER TABLE \`venu\` DROP COLUMN \`capacity\``);
    await queryRunner.query(`ALTER TABLE \`venu\` DROP COLUMN \`description\``);
  }
}
