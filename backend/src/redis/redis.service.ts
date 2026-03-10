import { Injectable, OnModuleDestroy, Logger } from '@nestjs/common';
import Redis from 'ioredis';

/**
 * Thin wrapper around ioredis.
 *
 * In production this would be replaced by Redis Cluster mode:
 *   new Redis.Cluster([{ host, port }, ...])
 * The rest of the codebase stays identical because ioredis Cluster
 * exposes the same API surface.
 */
@Injectable()
export class RedisService implements OnModuleDestroy {
  private readonly logger = new Logger(RedisService.name);
  private readonly client: Redis;

  constructor() {
    this.client = new Redis({
      host: process.env.REDIS_HOST ?? 'localhost',
      port: parseInt(process.env.REDIS_PORT ?? '6379', 10),
      password: process.env.REDIS_PASSWORD ?? undefined,
      lazyConnect: true,
    });

    this.client.on('error', (err) =>
      this.logger.error('Redis connection error', err),
    );
  }

  onModuleDestroy(): void {
    this.client.disconnect();
  }

  // ── String helpers ─────────────────────────────────────────────────────────

  async get(key: string): Promise<string | null> {
    return this.client.get(key);
  }

  async set(key: string, value: string, ttlSeconds?: number): Promise<void> {
    if (ttlSeconds) {
      await this.client.set(key, value, 'EX', ttlSeconds);
    } else {
      await this.client.set(key, value);
    }
  }

  async del(key: string): Promise<void> {
    await this.client.del(key);
  }

  // ── JSON convenience helpers ───────────────────────────────────────────────

  async getJson<T>(key: string): Promise<T | null> {
    const raw = await this.client.get(key);
    return raw ? (JSON.parse(raw) as T) : null;
  }

  async setJson<T>(key: string, value: T, ttlSeconds?: number): Promise<void> {
    const serialised = JSON.stringify(value);
    await this.set(key, serialised, ttlSeconds);
  }
}
