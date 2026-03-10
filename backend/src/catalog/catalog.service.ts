import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import type { Product } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';

const PRODUCTS_CACHE_KEY = 'catalog:products';
const PRODUCT_CACHE_TTL = 60 * 10; // 10 minutes

@Injectable()
export class CatalogService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
  ) {}

  /**
   * GET /api/products
   *
   * Cache-aside strategy:
   *  1. Try Redis first.
   *  2. On miss → query PostgreSQL, write result to Redis, return data.
   *
   * In a production setup the cache would be invalidated on product updates
   * (via an event or a short TTL). For this project a 10-minute TTL is used.
   */
  async findAll(): Promise<Product[]> {
    const cached = await this.redis.getJson<Product[]>(PRODUCTS_CACHE_KEY);
    if (cached) {
      return cached;
    }

    const products = await this.prisma.product.findMany({
      orderBy: { createdAt: 'desc' },
    });

    await this.redis.setJson(PRODUCTS_CACHE_KEY, products, PRODUCT_CACHE_TTL);
    return products;
  }

  /**
   * GET /api/products/:id
   *
   * Individual product cache — used by Nuxt SSR to render product pages
   * without hitting PostgreSQL on every request.
   */
  async findOne(id: string): Promise<Product> {
    const cacheKey = `catalog:product:${id}`;
    const cached = await this.redis.getJson<Product>(cacheKey);
    if (cached) {
      return cached;
    }

    const product = await this.prisma.product.findUnique({ where: { id } });
    if (!product) {
      throw new NotFoundException(`Product ${id} not found`);
    }

    await this.redis.setJson(cacheKey, product, PRODUCT_CACHE_TTL);
    return product;
  }
}
