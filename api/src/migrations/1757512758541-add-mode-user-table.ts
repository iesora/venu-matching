import { MigrationInterface, QueryRunner } from "typeorm";

export class AddModeUserTable1757512758541 implements MigrationInterface {
  name = "AddModeUserTable1757512758541";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`user\` ADD \`mode\` enum ('normal', 'business') NOT NULL DEFAULT 'normal'`
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE \`user\` DROP COLUMN \`mode\``);
  }
}
