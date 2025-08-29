import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors({
    credentials: true,
    origin: [
      'http://localhost:3000',
      'http://localhost:3001',
      'http://localhost:3002',
      'https://five-zero-develop-admin-584693937256.asia-northeast1.run.app',
      'https://five-zero-develop-web-584693937256.asia-northeast1.run.app',
    ],
  });
  await app.listen(process.env.PORT);
}
bootstrap();
