import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import { PrismaClient, Prisma } from '../generated/prisma/client';
export type { Product, Order } from '../generated/prisma/client';

/**
 * PrismaService — офіційний NestJS + Prisma 7 патерн (docs.nestjs.com/recipes/prisma).
 *
 * extends PrismaClient — рекомендований спосіб:
 *   • Всі методи (product, order, $connect тощо) доступні напряму.
 *   • Driver adapter (PrismaPg) передається через super().
 *
 * У продакшені DATABASE_URL може вказувати на PgBouncer (connection pooling).
 */
@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  constructor() {
    const pool = new Pool({
      connectionString:
        process.env.DATABASE_URL ?? 'postgresql://localhost:5432/ecommstore',
    });
    const adapter = new PrismaPg(pool);
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    super({ adapter } as any);
  }

  async onModuleInit(): Promise<void> {
    await this.$connect();
  }

  async onModuleDestroy(): Promise<void> {
    await this.$disconnect();
  }

  // Re-export namespace so callers can use Prisma.validator(), etc.
  readonly Prisma = Prisma;
}
