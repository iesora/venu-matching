import { MigrationInterface, QueryRunner } from 'typeorm';

export class DropDupRelationIdColumns1756810444116
  implements MigrationInterface
{
  name = 'DropDupRelationIdColumns1756810444116';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`venu\` DROP FOREIGN KEY \`FK_6f76a8175fe7c6d896445eb7a9d\``,
    );
    await queryRunner.query(
      `ALTER TABLE \`venu\` CHANGE \`user_id\` \`user_id\` int NULL`,
    );
    await queryRunner.query(
      `ALTER TABLE \`creator\` DROP FOREIGN KEY \`FK_bceab0a953e7603ff5fd64f5286\``,
    );
    await queryRunner.query(
      `ALTER TABLE \`creator\` CHANGE \`user_id\` \`user_id\` int NULL`,
    );
    await queryRunner.query(
      `ALTER TABLE \`venu\` ADD CONSTRAINT \`FK_6f76a8175fe7c6d896445eb7a9d\` FOREIGN KEY (\`user_id\`) REFERENCES \`user\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE \`creator\` ADD CONSTRAINT \`FK_bceab0a953e7603ff5fd64f5286\` FOREIGN KEY (\`user_id\`) REFERENCES \`user\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`creator\` DROP FOREIGN KEY \`FK_bceab0a953e7603ff5fd64f5286\``,
    );
    await queryRunner.query(
      `ALTER TABLE \`venu\` DROP FOREIGN KEY \`FK_6f76a8175fe7c6d896445eb7a9d\``,
    );
    await queryRunner.query(
      `ALTER TABLE \`creator\` CHANGE \`user_id\` \`user_id\` int NOT NULL`,
    );
    await queryRunner.query(
      `ALTER TABLE \`creator\` ADD CONSTRAINT \`FK_bceab0a953e7603ff5fd64f5286\` FOREIGN KEY (\`user_id\`) REFERENCES \`user\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE \`venu\` CHANGE \`user_id\` \`user_id\` int NOT NULL`,
    );
    await queryRunner.query(
      `ALTER TABLE \`venu\` ADD CONSTRAINT \`FK_6f76a8175fe7c6d896445eb7a9d\` FOREIGN KEY (\`user_id\`) REFERENCES \`user\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
  }
}
