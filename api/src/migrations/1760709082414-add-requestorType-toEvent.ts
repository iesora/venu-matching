import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddRequestorTypeToEvent1760709082414
  implements MigrationInterface
{
  name = 'AddRequestorTypeToEvent1760709082414';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`event\` ADD \`requestor_type\` enum ('creator', 'venue') NULL`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`event\` DROP COLUMN \`requestor_type\``,
    );
  }
}
