import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateLikeTable1761896467419 implements MigrationInterface {
  name = 'CreateLikeTable1761896467419';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE \`like\` (\`id\` int NOT NULL AUTO_INCREMENT, \`createdAt\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6), \`requestor_id\` int NOT NULL, \`supporter_id\` int NULL, \`venue_id\` int NULL, \`creator_id\` int NULL, PRIMARY KEY (\`id\`)) ENGINE=InnoDB`,
    );
    await queryRunner.query(
      `ALTER TABLE \`like\` ADD CONSTRAINT \`FK_a5f37dd93ecad27b6ed521dae01\` FOREIGN KEY (\`requestor_id\`) REFERENCES \`user\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE \`like\` ADD CONSTRAINT \`FK_fdec8f89088fc21ad78c609e4d4\` FOREIGN KEY (\`supporter_id\`) REFERENCES \`user\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE \`like\` ADD CONSTRAINT \`FK_11c80522f2aaecd27d1a828ab91\` FOREIGN KEY (\`venue_id\`) REFERENCES \`venue\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE \`like\` ADD CONSTRAINT \`FK_02eef45b864391adcb4b78f90fc\` FOREIGN KEY (\`creator_id\`) REFERENCES \`creator\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`like\` DROP FOREIGN KEY \`FK_02eef45b864391adcb4b78f90fc\``,
    );
    await queryRunner.query(
      `ALTER TABLE \`like\` DROP FOREIGN KEY \`FK_11c80522f2aaecd27d1a828ab91\``,
    );
    await queryRunner.query(
      `ALTER TABLE \`like\` DROP FOREIGN KEY \`FK_fdec8f89088fc21ad78c609e4d4\``,
    );
    await queryRunner.query(
      `ALTER TABLE \`like\` DROP FOREIGN KEY \`FK_a5f37dd93ecad27b6ed521dae01\``,
    );
    await queryRunner.query(`DROP TABLE \`like\``);
  }
}
