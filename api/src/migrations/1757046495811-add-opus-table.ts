import { MigrationInterface, QueryRunner } from "typeorm";

export class AddOpusTable1757046495811 implements MigrationInterface {
  name = "AddOpusTable1757046495811";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE \`opus\` (\`id\` int NOT NULL AUTO_INCREMENT, \`name\` varchar(255) NOT NULL, \`description\` text NULL, \`image_url\` varchar(255) NULL, \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6), \`updated_at\` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6), \`creator_id\` int NULL, PRIMARY KEY (\`id\`)) ENGINE=InnoDB`
    );
    await queryRunner.query(
      `ALTER TABLE \`creator\` ADD \`email\` varchar(255) NULL`
    );
    await queryRunner.query(
      `ALTER TABLE \`creator\` ADD \`website\` varchar(255) NULL`
    );
    await queryRunner.query(
      `ALTER TABLE \`creator\` ADD \`phone_number\` varchar(255) NULL`
    );
    await queryRunner.query(
      `ALTER TABLE \`creator\` ADD \`social_media_handle\` varchar(255) NULL`
    );
    await queryRunner.query(
      `ALTER TABLE \`opus\` ADD CONSTRAINT \`FK_eb26360a5aff77bfc265a030b45\` FOREIGN KEY (\`creator_id\`) REFERENCES \`creator\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`opus\` DROP FOREIGN KEY \`FK_eb26360a5aff77bfc265a030b45\``
    );
    await queryRunner.query(
      `ALTER TABLE \`creator\` DROP COLUMN \`social_media_handle\``
    );
    await queryRunner.query(
      `ALTER TABLE \`creator\` DROP COLUMN \`phone_number\``
    );
    await queryRunner.query(`ALTER TABLE \`creator\` DROP COLUMN \`website\``);
    await queryRunner.query(`ALTER TABLE \`creator\` DROP COLUMN \`email\``);
    await queryRunner.query(`DROP TABLE \`opus\``);
  }
}
