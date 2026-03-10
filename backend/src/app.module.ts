import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { RedisModule } from './redis/redis.module';
import { CatalogModule } from './catalog/catalog.module';
import { CartModule } from './cart/cart.module';
import { OrdersModule } from './orders/orders.module';

/**
 * Root application module — modular monolith.
 *
 * Domain breakdown:
 *  • PrismaModule  — global, provides PrismaService across all modules
 *  • RedisModule   — global, provides RedisService across all modules
 *  • CatalogModule — GET /api/products, GET /api/products/:id
 *  • CartModule    — GET/POST /api/cart/:sessionId[/items]
 *  • OrdersModule  — POST /api/orders
 */
@Module({
  imports: [PrismaModule, RedisModule, CatalogModule, CartModule, OrdersModule],
})
export class AppModule {}
