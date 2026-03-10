import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module';
import { RedisModule } from './redis/redis.module';
import { CatalogModule } from './catalog/catalog.module';
import { CartModule } from './cart/cart.module';
import { OrdersModule } from './orders/orders.module';

/**
 * Root application module — modular monolith.
 *
 * ConfigModule.forRoot() MUST be first — it calls dotenv.config() synchronously,
 * which populates process.env before any other provider constructor runs.
 *
 * Domain breakdown:
 *  • PrismaModule  — global, provides PrismaService across all modules
 *  • RedisModule   — global, provides RedisService across all modules
 *  • CatalogModule — GET /api/products, GET /api/products/:id
 *  • CartModule    — GET/POST /api/cart/:sessionId[/items]
 *  • OrdersModule  — POST /api/orders
 */
@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    RedisModule,
    CatalogModule,
    CartModule,
    OrdersModule,
  ],
})
export class AppModule {}
