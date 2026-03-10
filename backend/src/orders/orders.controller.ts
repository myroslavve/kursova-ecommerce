import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { CheckoutDto } from './dto/create-order.dto';

@Controller('orders')
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  /**
   * POST /api/orders/checkout
   *
   * Конвертує кошик із Redis у замовлення в PostgreSQL.
   * Body: { sessionId: string, customerName: string }
   */
  @Post('checkout')
  checkout(@Body() dto: CheckoutDto) {
    return this.ordersService.checkout(dto);
  }

  /** GET /api/orders/session/:sessionId — історія замовлень сесії */
  @Get('session/:sessionId')
  findBySession(@Param('sessionId') sessionId: string) {
    return this.ordersService.findBySession(sessionId);
  }
}
