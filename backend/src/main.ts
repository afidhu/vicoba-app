import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import helmet from 'helmet';
import { AppModule } from './app.module';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';
import { ExpressAdapter } from '@nestjs/platform-express';
import express from 'express';

// Create a raw express instance reference
const server = express();

async function bootstrap() {
  // Pass the express instance directly down into the Nest application context
  const app = await NestFactory.create(AppModule, new ExpressAdapter(server));

  app.use(helmet());
  app.enableCors({
    origin:
      process.env.CORS_ORIGIN?.split(',').map((origin) => origin.trim()).filter(Boolean) ||
      ['https://vicoba-app-rt7m.vercel.app', 'http://localhost:5173'],
    credentials: true,
  });
  app.setGlobalPrefix('api');
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: false,
    }),
  );
  app.useGlobalFilters(new AllExceptionsFilter());

  // ONLY listen on a port if we are NOT running on a serverless provider (Vercel)
  if (!process.env.VERCEL) {
    const port = process.env.PORT || 3000;
    await app.listen(port);
    console.log(`VICOBA API running locally on http://localhost:${port}/api`);
  } else {
    // Crucial: Vercel needs initialization triggered explicitly if not listening
    await app.init();
  }
}

// Start once and cache the promise so every request waits for Nest to be ready
// (on Vercel cold starts requests could otherwise hit an uninitialised app).
const ready = bootstrap();

// Vercel serverless handler
export default async function handler(req: any, res: any) {
  await ready;
  return server(req, res);
}
