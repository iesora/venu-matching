import { MigrationInterface, QueryRunner } from "typeorm";

export class AddStatusMatchingTable1757320432393 implements MigrationInterface {
  name = "AddStatusMatchingTable1757320432393";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`event\` DROP COLUMN \`matching_flag\``
    );
    await queryRunner.query(
      `ALTER TABLE \`event\` ADD \`reject_at\` datetime NULL`
    );
    await queryRunner.query(
      `ALTER TABLE \`event\` ADD \`matching_status\` enum ('pending', 'matching', 'rejected') NULL`
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`event\` DROP COLUMN \`matching_status\``
    );
    await queryRunner.query(`ALTER TABLE \`event\` DROP COLUMN \`reject_at\``);
    await queryRunner.query(
      `ALTER TABLE \`event\` ADD \`matching_flag\` tinyint NOT NULL DEFAULT '0'`
    );
  }
}
