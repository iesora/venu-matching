import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddDeleteFlagToCreatorEvent1758115593728
  implements MigrationInterface
{
  name = 'AddDeleteFlagToCreatorEvent1758115593728';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`creator_event\` ADD \`delete_flag\` tinyint NOT NULL DEFAULT 0`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`creator_event\` DROP COLUMN \`delete_flag\``,
    );
  }
}
