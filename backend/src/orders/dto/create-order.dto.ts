export class CheckoutDto {
  /** ID сесії, чий кошик буде конвертовано в замовлення */
  sessionId: string;

  /** Ім'я замовника */
  customerName: string;
}
