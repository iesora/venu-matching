import { MigrationInterface, QueryRunner } from "typeorm";

export class AddImageUrlToCreatorTable1757046794805
  implements MigrationInterface
{
  name = "AddImageUrlToCreatorTable1757046794805";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`creator\` ADD \`image_url\` varchar(255) NULL`
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`creator\` DROP COLUMN \`image_url\``
    );
  }
}
