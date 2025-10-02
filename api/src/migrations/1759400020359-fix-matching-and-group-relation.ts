import { MigrationInterface, QueryRunner } from "typeorm";

export class FixMatchingAndGroupRelation1759400020359
  implements MigrationInterface
{
  name = "FixMatchingAndGroupRelation1759400020359";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`chat_groups\` DROP FOREIGN KEY \`FK_4c8e88daa532a398b0a7f8e23a7\``
    );
    await queryRunner.query(
      `ALTER TABLE \`chat_groups\` ADD UNIQUE INDEX \`IDX_4c8e88daa532a398b0a7f8e23a\` (\`matching_id\`)`
    );
    await queryRunner.query(
      `CREATE UNIQUE INDEX \`REL_4c8e88daa532a398b0a7f8e23a\` ON \`chat_groups\` (\`matching_id\`)`
    );
    await queryRunner.query(
      `ALTER TABLE \`chat_groups\` ADD CONSTRAINT \`FK_4c8e88daa532a398b0a7f8e23a7\` FOREIGN KEY (\`matching_id\`) REFERENCES \`matching\`(\`id\`) ON DELETE NO ACTION ON UPDATE NO ACTION`
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`chat_groups\` DROP FOREIGN KEY \`FK_4c8e88daa532a398b0a7f8e23a7\``
    );
    await queryRunner.query(
      `DROP INDEX \`REL_4c8e88daa532a398b0a7f8e23a\` ON \`chat_groups\``
    );
    await queryRunner.query(
      `ALTER TABLE \`chat_groups\` DROP INDEX \`IDX_4c8e88daa532a398b0a7f8e23a\``
    );
    await queryRunner.query(
      `ALTER TABLE \`chat_groups\` ADD CONSTRAINT \`FK_4c8e88daa532a398b0a7f8e23a7\` FOREIGN KEY (\`matching_id\`) REFERENCES \`matching\`(\`id\`) ON DELETE NO ACTION ON UPDATE NO ACTION`
    );
  }
}
