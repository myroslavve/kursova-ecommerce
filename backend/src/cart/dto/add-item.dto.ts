export class AddItemDto {
  /** UUID of the product being added */
  productId: string;

  /** Human-readable name (denormalised to avoid extra lookups at checkout) */
  name: string;

  /** Unit price snapshot at the time of adding to cart */
  price: number;

  /** Number of units */
  quantity: number;
}
