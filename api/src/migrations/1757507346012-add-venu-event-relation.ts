import { MigrationInterface, QueryRunner } from "typeorm";

export class AddVenuEventRelation1757507346012 implements MigrationInterface {
  name = "AddVenuEventRelation1757507346012";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE \`event\` ADD \`venu_id\` int NULL`);
    await queryRunner.query(
      `ALTER TABLE \`event\` ADD CONSTRAINT \`FK_0c8b444cca000afb0ecf6836058\` FOREIGN KEY (\`venu_id\`) REFERENCES \`venu\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`event\` DROP FOREIGN KEY \`FK_0c8b444cca000afb0ecf6836058\``
    );
    await queryRunner.query(`ALTER TABLE \`event\` DROP COLUMN \`venu_id\``);
  }
}
