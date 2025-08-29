import { MigrationInterface, QueryRunner } from "typeorm";

export class InitTableCreatorAndVenu1756454401483 implements MigrationInterface {
    name = 'InitTableCreatorAndVenu1756454401483'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE \`creator\` (\`id\` int NOT NULL AUTO_INCREMENT, \`name\` varchar(255) NOT NULL, \`description\` text NULL, \`user_id\` int NOT NULL, \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6), \`updated_at\` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6), PRIMARY KEY (\`id\`)) ENGINE=InnoDB`);
        await queryRunner.query(`CREATE TABLE \`venu\` (\`id\` int NOT NULL AUTO_INCREMENT, \`name\` varchar(255) NOT NULL, \`address\` varchar(500) NULL, \`tel\` varchar(20) NULL, \`user_id\` int NOT NULL, \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6), \`updated_at\` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6), PRIMARY KEY (\`id\`)) ENGINE=InnoDB`);
        await queryRunner.query(`ALTER TABLE \`creator\` ADD CONSTRAINT \`FK_bceab0a953e7603ff5fd64f5286\` FOREIGN KEY (\`user_id\`) REFERENCES \`user\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE \`venu\` ADD CONSTRAINT \`FK_6f76a8175fe7c6d896445eb7a9d\` FOREIGN KEY (\`user_id\`) REFERENCES \`user\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE \`venu\` DROP FOREIGN KEY \`FK_6f76a8175fe7c6d896445eb7a9d\``);
        await queryRunner.query(`ALTER TABLE \`creator\` DROP FOREIGN KEY \`FK_bceab0a953e7603ff5fd64f5286\``);
        await queryRunner.query(`DROP TABLE \`venu\``);
        await queryRunner.query(`DROP TABLE \`creator\``);
    }

}
