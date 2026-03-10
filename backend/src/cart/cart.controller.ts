import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { CartService } from './cart.service';
import { AddItemDto } from './dto/add-item.dto';

@Controller('cart')
export class CartController {
  constructor(private readonly cartService: CartService) {}

  /**
   * GET /api/cart/:sessionId
   * Returns the current cart contents for the given session.
   */
  @Get(':sessionId')
  getCart(@Param('sessionId') sessionId: string) {
    return this.cartService.getCart(sessionId);
  }

  /**
   * POST /api/cart/:sessionId/items
   * Adds a product to the cart (or increments its quantity if already present).
   *
   * Body: { productId, name, price, quantity }
   */
  @Post(':sessionId/items')
  addItem(
    @Param('sessionId') sessionId: string,
    @Body() dto: AddItemDto,
  ) {
    return this.cartService.addItem(sessionId, dto);
  }
}
