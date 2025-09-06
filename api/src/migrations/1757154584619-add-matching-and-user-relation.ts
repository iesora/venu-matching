import { MigrationInterface, QueryRunner } from "typeorm";

export class AddMatchingAndUserRelation1757154584619
  implements MigrationInterface
{
  name = "AddMatchingAndUserRelation1757154584619";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`matching\` ADD \`from_user_id\` int NULL`
    );
    await queryRunner.query(
      `ALTER TABLE \`matching\` ADD \`to_user_id\` int NULL`
    );
    await queryRunner.query(
      `ALTER TABLE \`matching\` ADD CONSTRAINT \`FK_410c63a869fcf67725517dac75b\` FOREIGN KEY (\`from_user_id\`) REFERENCES \`user\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`
    );
    await queryRunner.query(
      `ALTER TABLE \`matching\` ADD CONSTRAINT \`FK_683c3c56e743b83a5fd392a6390\` FOREIGN KEY (\`to_user_id\`) REFERENCES \`user\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`matching\` DROP FOREIGN KEY \`FK_683c3c56e743b83a5fd392a6390\``
    );
    await queryRunner.query(
      `ALTER TABLE \`matching\` DROP FOREIGN KEY \`FK_410c63a869fcf67725517dac75b\``
    );
    await queryRunner.query(
      `ALTER TABLE \`matching\` DROP COLUMN \`to_user_id\``
    );
    await queryRunner.query(
      `ALTER TABLE \`matching\` DROP COLUMN \`from_user_id\``
    );
  }
}
