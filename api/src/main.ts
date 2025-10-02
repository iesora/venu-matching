import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app.module";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors({
    credentials: true,
    origin: true, // オリジンによるフィルターを消すためにtrueを設定
  });
  await app.listen(process.env.PORT);
}
bootstrap();
