import { MigrationInterface, QueryRunner } from "typeorm";

export class InitMatchingTable1756456453677 implements MigrationInterface {
    name = 'InitMatchingTable1756456453677'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE \`matching\` (\`id\` int NOT NULL AUTO_INCREMENT, \`from\` enum ('creator', 'venu') NOT NULL, \`matching_flag\` tinyint NOT NULL DEFAULT 0, \`creator_id\` int NULL, \`venu_id\` int NULL, \`request_at\` datetime NULL, \`matching_at\` datetime NULL, \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6), \`updated_at\` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6), PRIMARY KEY (\`id\`)) ENGINE=InnoDB`);
        await queryRunner.query(`ALTER TABLE \`matching\` ADD CONSTRAINT \`FK_041c83f8cc38d32dd7f1aa1ef1e\` FOREIGN KEY (\`creator_id\`) REFERENCES \`creator\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE \`matching\` ADD CONSTRAINT \`FK_5c65f3f30d9e2ad795300acc518\` FOREIGN KEY (\`venu_id\`) REFERENCES \`venu\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE \`matching\` DROP FOREIGN KEY \`FK_5c65f3f30d9e2ad795300acc518\``);
        await queryRunner.query(`ALTER TABLE \`matching\` DROP FOREIGN KEY \`FK_041c83f8cc38d32dd7f1aa1ef1e\``);
        await queryRunner.query(`DROP TABLE \`matching\``);
    }

}
