import { MigrationInterface, QueryRunner } from "typeorm";

export class FixMatchingTable1759312868425 implements MigrationInterface {
  name = "FixMatchingTable1759312868425";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`matching\` DROP FOREIGN KEY \`FK_041c83f8cc38d32dd7f1aa1ef1e\``
    );
    await queryRunner.query(
      `ALTER TABLE \`matching\` DROP FOREIGN KEY \`FK_dfe787485d689b84153d22f75c3\``
    );
    await queryRunner.query(`ALTER TABLE \`matching\` DROP COLUMN \`from\``);
    await queryRunner.query(
      `ALTER TABLE \`matching\` DROP COLUMN \`creator_id\``
    );
    await queryRunner.query(
      `ALTER TABLE \`matching\` DROP COLUMN \`venue_id\``
    );
    await queryRunner.query(
      `ALTER TABLE \`matching\` ADD \`status\` enum ('pending', 'matching', 'rejected') NOT NULL`
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE \`matching\` DROP COLUMN \`status\``);
    await queryRunner.query(
      `ALTER TABLE \`matching\` ADD \`venue_id\` int NULL`
    );
    await queryRunner.query(
      `ALTER TABLE \`matching\` ADD \`creator_id\` int NULL`
    );
    await queryRunner.query(
      `ALTER TABLE \`matching\` ADD \`from\` enum ('creator', 'venue') NOT NULL`
    );
    await queryRunner.query(
      `ALTER TABLE \`matching\` ADD CONSTRAINT \`FK_dfe787485d689b84153d22f75c3\` FOREIGN KEY (\`venue_id\`) REFERENCES \`venue\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`
    );
    await queryRunner.query(
      `ALTER TABLE \`matching\` ADD CONSTRAINT \`FK_041c83f8cc38d32dd7f1aa1ef1e\` FOREIGN KEY (\`creator_id\`) REFERENCES \`creator\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`
    );
  }
}
