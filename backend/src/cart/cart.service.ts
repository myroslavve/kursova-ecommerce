import { Injectable } from '@nestjs/common';
import { RedisService } from '../redis/redis.service';
import { AddItemDto } from './dto/add-item.dto';
import { Cart, CartItem } from './cart.types';

/**
 * Cart service — all state lives exclusively in Redis.
 *
 * Key schema:  cart:{sessionId}
 * Value:       JSON-serialised Cart object
 * TTL:         24 hours (reset on every write to extend the session)
 *
 * Rationale for Redis-only storage:
 *  • Carts are ephemeral; most are never converted to orders.
 *  • Sub-millisecond reads/writes keep add-to-cart latency imperceptible.
 *  • No need for durability — a lost cart is a minor UX inconvenience,
 *    not a data integrity issue.
 */
@Injectable()
export class CartService {
  private readonly TTL = 60 * 60 * 24; // 24 h

  constructor(private readonly redis: RedisService) {}

  private cartKey(sessionId: string): string {
    return `cart:${sessionId}`;
  }

  private computeTotal(items: CartItem[]): number {
    return items.reduce((sum, i) => sum + i.price * i.quantity, 0);
  }

  // ── Getters ───────────────────────────────────────────────────────────────

  async getCart(sessionId: string): Promise<Cart> {
    const cached = await this.redis.getJson<Cart>(this.cartKey(sessionId));
    return (
      cached ?? {
        sessionId,
        items: [],
        total: 0,
      }
    );
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  /**
   * Add or increment a cart item.
   * If the product already exists in the cart the quantity is summed.
   */
  async addItem(sessionId: string, dto: AddItemDto): Promise<Cart> {
    const cart = await this.getCart(sessionId);

    const existing = cart.items.find((i) => i.productId === dto.productId);
    if (existing) {
      existing.quantity += dto.quantity;
    } else {
      cart.items.push({ ...dto });
    }

    cart.total = this.computeTotal(cart.items);

    await this.redis.setJson(this.cartKey(sessionId), cart, this.TTL);
    return cart;
  }

  /**
   * Remove the entire cart entry (called after a successful order placement).
   */
  async clearCart(sessionId: string): Promise<void> {
    await this.redis.del(this.cartKey(sessionId));
  }
}
