import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CartService } from '../cart/cart.service';
import { CheckoutDto } from './dto/create-order.dto';

@Injectable()
export class OrdersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly cartService: CartService,
  ) {}

  /**
   * POST /api/orders/checkout
   *
   * Flow:
   *  1. Дістаємо кошик із Redis за sessionId.
   *  2. Перевіряємо, що кошик не порожній.
   *  3. Зберігаємо замовлення в PostgreSQL через prisma.order.create().
   *  4. Очищаємо кошик у Redis.
   *  5. Повертаємо orderId і статус.
   */
  async checkout(dto: CheckoutDto) {
    const cart = await this.cartService.getCart(dto.sessionId);

    if (!cart.items.length) {
      throw new BadRequestException('Кошик порожній');
    }

    const order = await this.prisma.order.create({
      data: {
        sessionId: dto.sessionId,
        customerName: dto.customerName,
        items: cart.items as object[],
        total: cart.total,
      },
    });

    // Очищаємо кошик лише після успішного запису в БД
    await this.cartService.clearCart(dto.sessionId);

    return {
      message: 'Замовлення успішно оформлено!',
      orderId: order.id,
      status: 'success',
    };
  }

  /** GET /api/orders/session/:sessionId — історія замовлень сесії */
  async findBySession(sessionId: string) {
    return this.prisma.order.findMany({
      where: { sessionId },
      orderBy: { createdAt: 'desc' },
    });
  }
}
