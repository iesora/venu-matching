import { MigrationInterface, QueryRunner } from "typeorm";

export class AddCreateEventTable1757504535599 implements MigrationInterface {
  name = "AddCreateEventTable1757504535599";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE \`creator_event\` (\`id\` int NOT NULL AUTO_INCREMENT, \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6), \`updated_at\` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6), \`creator_id\` int NULL, \`event_id\` int NULL, PRIMARY KEY (\`id\`)) ENGINE=InnoDB`
    );
    await queryRunner.query(
      `ALTER TABLE \`creator_event\` ADD CONSTRAINT \`FK_58c332cbd2dba58221ba8ce2b1d\` FOREIGN KEY (\`creator_id\`) REFERENCES \`creator\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`
    );
    await queryRunner.query(
      `ALTER TABLE \`creator_event\` ADD CONSTRAINT \`FK_189e9f9cbf90fc2e1e3f4fd9d6e\` FOREIGN KEY (\`event_id\`) REFERENCES \`event\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`creator_event\` DROP FOREIGN KEY \`FK_189e9f9cbf90fc2e1e3f4fd9d6e\``
    );
    await queryRunner.query(
      `ALTER TABLE \`creator_event\` DROP FOREIGN KEY \`FK_58c332cbd2dba58221ba8ce2b1d\``
    );
    await queryRunner.query(`DROP TABLE \`creator_event\``);
  }
}
