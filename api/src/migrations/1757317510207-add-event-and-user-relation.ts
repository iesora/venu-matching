import { MigrationInterface, QueryRunner } from "typeorm";

export class AddEventAndUserRelation1757317510207
  implements MigrationInterface
{
  name = "AddEventAndUserRelation1757317510207";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`event\` ADD \`matching_flag\` tinyint NOT NULL DEFAULT 0`
    );
    await queryRunner.query(
      `ALTER TABLE \`event\` ADD \`request_at\` datetime NULL`
    );
    await queryRunner.query(
      `ALTER TABLE \`event\` ADD \`matching_at\` datetime NULL`
    );
    await queryRunner.query(
      `ALTER TABLE \`event\` ADD \`from_user_id\` int NULL`
    );
    await queryRunner.query(
      `ALTER TABLE \`event\` ADD \`to_user_id\` int NULL`
    );
    await queryRunner.query(
      `ALTER TABLE \`event\` ADD CONSTRAINT \`FK_442622d55e7deff92c2d39529e9\` FOREIGN KEY (\`from_user_id\`) REFERENCES \`user\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`
    );
    await queryRunner.query(
      `ALTER TABLE \`event\` ADD CONSTRAINT \`FK_71620a7319e81c75dcad632113f\` FOREIGN KEY (\`to_user_id\`) REFERENCES \`user\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`event\` DROP FOREIGN KEY \`FK_71620a7319e81c75dcad632113f\``
    );
    await queryRunner.query(
      `ALTER TABLE \`event\` DROP FOREIGN KEY \`FK_442622d55e7deff92c2d39529e9\``
    );
    await queryRunner.query(`ALTER TABLE \`event\` DROP COLUMN \`to_user_id\``);
    await queryRunner.query(
      `ALTER TABLE \`event\` DROP COLUMN \`from_user_id\``
    );
    await queryRunner.query(
      `ALTER TABLE \`event\` DROP COLUMN \`matching_at\``
    );
    await queryRunner.query(`ALTER TABLE \`event\` DROP COLUMN \`request_at\``);
    await queryRunner.query(
      `ALTER TABLE \`event\` DROP COLUMN \`matching_flag\``
    );
  }
}
