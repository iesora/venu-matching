import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddAcceptStatusToEvent1760707964624 implements MigrationInterface {
  name = 'AddAcceptStatusToEvent1760707964624';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`event\` ADD \`status\` enum ('pending', 'accepted', 'rejected') NOT NULL DEFAULT 'pending'`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE \`event\` DROP COLUMN \`status\``);
  }
}
