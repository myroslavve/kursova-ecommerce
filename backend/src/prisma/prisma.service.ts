import {
  Injectable,
  OnModuleInit,
  OnModuleDestroy,
  Logger,
} from '@nestjs/common';
import { Pool } from 'pg';
import { PrismaPg } from '@prisma/adapter-pg';
// Explicit .js extension required by TypeScript nodenext module resolution
import { PrismaClient, Prisma } from '../../generated/prisma/client.js';
// Product and Order are type aliases defined in client.ts
export type { Product, Order } from '../../generated/prisma/client.js';

// Type alias for convenience
type Client = InstanceType<typeof PrismaClient>;

/**
 * PrismaService — Prisma 7 composition pattern.
 *
 * Prisma 7 removed the binary engine and moved to driver adapters for all
 * database connections. Unlike Prisma ≤5 (where you could `extends PrismaClient`),
 * here we hold a PrismaClient instance and delegate the surface we need.
 *
 * Connection flow:
 *   pg.Pool  →  PrismaPg adapter  →  PrismaClient
 *
 * In production this pool endpoint can point to PgBouncer for connection
 * pooling at high concurrency.
 */
@Injectable()
export class PrismaService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);
  private _client!: Client;
  private _pool!: Pool;

  async onModuleInit(): Promise<void> {
    const connectionString =
      process.env.DATABASE_URL ?? 'postgresql://localhost:5432/ecommstore';

    this._pool = new Pool({ connectionString });
    const adapter = new PrismaPg(this._pool);

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    this._client = new PrismaClient({ adapter } as any);
    await this._client.$connect();
    this.logger.log('Prisma connected');
  }

  async onModuleDestroy(): Promise<void> {
    await this._client?.$disconnect();
    await this._pool?.end();
  }

  // ── Delegated model accessors ─────────────────────────────────────────────

  get product(): Client['product'] {
    return this._client.product;
  }

  get order(): Client['order'] {
    return this._client.order;
  }

  // ── Delegated raw query helpers ───────────────────────────────────────────

  get $queryRaw(): Client['$queryRaw'] {
    return this._client.$queryRaw.bind(this._client) as Client['$queryRaw'];
  }

  get $executeRaw(): Client['$executeRaw'] {
    return this._client.$executeRaw.bind(this._client) as Client['$executeRaw'];
  }

  // Re-export for callers that need Prisma.sql / Prisma.raw etc.
  readonly Prisma = Prisma;
}
