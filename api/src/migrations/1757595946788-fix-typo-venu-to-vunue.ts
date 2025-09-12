import { MigrationInterface, QueryRunner } from 'typeorm';

export class FixTypoVenuToVunue1757595946788 implements MigrationInterface {
  name = 'FixTypoVenuToVunue1757595946788';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`event\` DROP FOREIGN KEY \`FK_0c8b444cca000afb0ecf6836058\``,
    );
    await queryRunner.query(
      `ALTER TABLE \`matching\` DROP FOREIGN KEY \`FK_5c65f3f30d9e2ad795300acc518\``,
    );
    await queryRunner.query(
      `ALTER TABLE \`event\` CHANGE \`venu_id\` \`venue_id\` int NULL`,
    );
    await queryRunner.query(
      `ALTER TABLE \`matching\` CHANGE \`venu_id\` \`venue_id\` int NULL`,
    );
    await queryRunner.query(
      `CREATE TABLE \`venue\` (\`id\` int NOT NULL AUTO_INCREMENT, \`name\` varchar(255) NOT NULL, \`address\` varchar(500) NULL, \`latitude\` varchar(255) NULL, \`longitude\` varchar(255) NULL, \`tel\` varchar(20) NULL, \`description\` text NULL, \`capacity\` int NULL, \`facilities\` varchar(1000) NULL, \`available_time\` varchar(255) NULL, \`image_url\` varchar(1000) NULL, \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6), \`updated_at\` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6), \`user_id\` int NULL, PRIMARY KEY (\`id\`)) ENGINE=InnoDB`,
    );
    await queryRunner.query(
      `ALTER TABLE \`matching\` CHANGE \`from\` \`from\` enum ('creator', 'venue') NOT NULL`,
    );
    await queryRunner.query(
      `ALTER TABLE \`event\` ADD CONSTRAINT \`FK_128347780df4ef90d1426da6c77\` FOREIGN KEY (\`venue_id\`) REFERENCES \`venue\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE \`venue\` ADD CONSTRAINT \`FK_bdc89b4a2cc92a957b3b7d879ee\` FOREIGN KEY (\`user_id\`) REFERENCES \`user\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE \`matching\` ADD CONSTRAINT \`FK_dfe787485d689b84153d22f75c3\` FOREIGN KEY (\`venue_id\`) REFERENCES \`venue\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`matching\` DROP FOREIGN KEY \`FK_dfe787485d689b84153d22f75c3\``,
    );
    await queryRunner.query(
      `ALTER TABLE \`venue\` DROP FOREIGN KEY \`FK_bdc89b4a2cc92a957b3b7d879ee\``,
    );
    await queryRunner.query(
      `ALTER TABLE \`event\` DROP FOREIGN KEY \`FK_128347780df4ef90d1426da6c77\``,
    );
    await queryRunner.query(
      `ALTER TABLE \`matching\` CHANGE \`from\` \`from\` enum ('creator', 'venu') NOT NULL`,
    );
    await queryRunner.query(`DROP TABLE \`venue\``);
    await queryRunner.query(
      `ALTER TABLE \`matching\` CHANGE \`venue_id\` \`venu_id\` int NULL`,
    );
    await queryRunner.query(
      `ALTER TABLE \`event\` CHANGE \`venue_id\` \`venu_id\` int NULL`,
    );
    await queryRunner.query(
      `ALTER TABLE \`matching\` ADD CONSTRAINT \`FK_5c65f3f30d9e2ad795300acc518\` FOREIGN KEY (\`venu_id\`) REFERENCES \`venu\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE \`event\` ADD CONSTRAINT \`FK_0c8b444cca000afb0ecf6836058\` FOREIGN KEY (\`venu_id\`) REFERENCES \`venu\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
  }
}
