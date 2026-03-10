import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // All routes are served under /api — e.g. GET /api/products
  app.setGlobalPrefix('api');

  // Allow the Nuxt SSR frontend (port 3001) to call the API during dev
  app.enableCors({
    origin: process.env.CORS_ORIGIN ?? 'http://localhost:3001',
  });

  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
