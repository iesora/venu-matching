import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddAcceptFlatToCreateEvent1757660283810
  implements MigrationInterface
{
  name = 'AddAcceptFlatToCreateEvent1757660283810';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`creator_event\` ADD \`acceptFlag\` tinyint NOT NULL DEFAULT 0`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`creator_event\` DROP COLUMN \`acceptFlag\``,
    );
  }
}
