import { MigrationInterface, QueryRunner } from 'typeorm';

export class ReplaceAcceptFlagToEnumStatus1758105840241
  implements MigrationInterface
{
  name = 'ReplaceAcceptFlagToEnumStatus1758105840241';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`creator_event\` CHANGE \`acceptFlag\` \`acceptStatus\` tinyint NOT NULL DEFAULT '0'`,
    );
    await queryRunner.query(
      `ALTER TABLE \`creator_event\` DROP COLUMN \`acceptStatus\``,
    );
    await queryRunner.query(
      `ALTER TABLE \`creator_event\` ADD \`acceptStatus\` enum ('pending', 'accepted', 'rejected') NOT NULL DEFAULT 'pending'`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`creator_event\` DROP COLUMN \`acceptStatus\``,
    );
    await queryRunner.query(
      `ALTER TABLE \`creator_event\` ADD \`acceptStatus\` tinyint NOT NULL DEFAULT '0'`,
    );
    await queryRunner.query(
      `ALTER TABLE \`creator_event\` CHANGE \`acceptStatus\` \`acceptFlag\` tinyint NOT NULL DEFAULT '0'`,
    );
  }
}
