import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddRelationEventAndMatching1760690891541
  implements MigrationInterface
{
  name = 'AddRelationEventAndMatching1760690891541';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`event\` ADD \`matching_id\` int NULL`,
    );
    await queryRunner.query(
      `ALTER TABLE \`event\` ADD CONSTRAINT \`FK_41349963804f914e12ca300e091\` FOREIGN KEY (\`matching_id\`) REFERENCES \`matching\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`event\` DROP FOREIGN KEY \`FK_41349963804f914e12ca300e091\``,
    );
    await queryRunner.query(
      `ALTER TABLE \`event\` DROP COLUMN \`matching_id\``,
    );
  }
}
