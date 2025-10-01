import { MigrationInterface, QueryRunner } from "typeorm";

export class AddChatTable1759040466213 implements MigrationInterface {
  name = "AddChatTable1759040466213";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE \`chat_messages\` (\`id\` int NOT NULL AUTO_INCREMENT, \`text\` varchar(5000) NOT NULL DEFAULT '', \`url\` varchar(5000) NOT NULL DEFAULT '', \`type\` enum ('file', 'text', 'image') NOT NULL DEFAULT 'text', \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6), \`updated_at\` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6), \`chat_group_id\` int NULL, \`author_id\` int NULL, PRIMARY KEY (\`id\`)) ENGINE=InnoDB`
    );
    await queryRunner.query(
      `CREATE TABLE \`chat_group_user\` (\`id\` int NOT NULL AUTO_INCREMENT, \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6), \`updated_at\` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6), \`user_id\` int NULL, \`chat_group_id\` int NULL, PRIMARY KEY (\`id\`)) ENGINE=InnoDB`
    );
    await queryRunner.query(
      `CREATE TABLE \`chat_groups\` (\`id\` int NOT NULL AUTO_INCREMENT, \`name\` varchar(500) NOT NULL DEFAULT '', \`unread_message_count\` int NOT NULL, \`latest_message\` text NOT NULL, \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6), \`updated_at\` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6), \`matching_id\` int NULL, FULLTEXT INDEX \`IDX_f94b012b277ef6e3d63b6cdf74\` (\`name\`) WITH PARSER ngram, PRIMARY KEY (\`id\`)) ENGINE=InnoDB`
    );
    await queryRunner.query(
      `ALTER TABLE \`chat_messages\` ADD CONSTRAINT \`FK_7f6838b32b891a20e10f99553cc\` FOREIGN KEY (\`chat_group_id\`) REFERENCES \`chat_groups\`(\`id\`) ON DELETE NO ACTION ON UPDATE NO ACTION`
    );
    await queryRunner.query(
      `ALTER TABLE \`chat_messages\` ADD CONSTRAINT \`FK_85a3fc9253b9b06d74fec69241d\` FOREIGN KEY (\`author_id\`) REFERENCES \`user\`(\`id\`) ON DELETE CASCADE ON UPDATE CASCADE`
    );
    await queryRunner.query(
      `ALTER TABLE \`chat_group_user\` ADD CONSTRAINT \`FK_7bb2e6d15a271078f6b9c88738f\` FOREIGN KEY (\`user_id\`) REFERENCES \`user\`(\`id\`) ON DELETE NO ACTION ON UPDATE NO ACTION`
    );
    await queryRunner.query(
      `ALTER TABLE \`chat_group_user\` ADD CONSTRAINT \`FK_e6ec365eabbd018b83a55bfe565\` FOREIGN KEY (\`chat_group_id\`) REFERENCES \`chat_groups\`(\`id\`) ON DELETE NO ACTION ON UPDATE NO ACTION`
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
      `ALTER TABLE \`chat_group_user\` DROP FOREIGN KEY \`FK_e6ec365eabbd018b83a55bfe565\``
    );
    await queryRunner.query(
      `ALTER TABLE \`chat_group_user\` DROP FOREIGN KEY \`FK_7bb2e6d15a271078f6b9c88738f\``
    );
    await queryRunner.query(
      `ALTER TABLE \`chat_messages\` DROP FOREIGN KEY \`FK_85a3fc9253b9b06d74fec69241d\``
    );
    await queryRunner.query(
      `ALTER TABLE \`chat_messages\` DROP FOREIGN KEY \`FK_7f6838b32b891a20e10f99553cc\``
    );
    await queryRunner.query(
      `DROP INDEX \`IDX_f94b012b277ef6e3d63b6cdf74\` ON \`chat_groups\``
    );
    await queryRunner.query(`DROP TABLE \`chat_groups\``);
    await queryRunner.query(`DROP TABLE \`chat_group_user\``);
    await queryRunner.query(`DROP TABLE \`chat_messages\``);
  }
}
