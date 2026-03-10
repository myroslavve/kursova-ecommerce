export interface CartItem {
  productId: string;
  name: string;
  price: number;
  quantity: number;
}

export interface CartState {
  sessionId: string;
  items: CartItem[];
  total: number;
}

export const useCart = () => {
  const config = useRuntimeConfig();
  const session = useSession();

  const cart = useState<CartState>('cart', () => ({
    sessionId: '',
    items: [],
    total: 0,
  }));

  const loadCart = async () => {
    if (!session.value) return;
    try {
      const data = await $fetch<CartState>(
        `${config.public.apiBase}/cart/${session.value}`,
      );
      cart.value = data;
    } catch {
      // cart may not exist yet — ignore 404
    }
  };

  const addItem = async (item: Omit<CartItem, never>) => {
    const data = await $fetch<CartState>(
      `${config.public.apiBase}/cart/${session.value}/items`,
      { method: 'POST', body: item },
    );
    cart.value = data;
  };

  const itemCount = computed(() =>
    cart.value.items.reduce((sum, i) => sum + i.quantity, 0),
  );

  return { cart, loadCart, addItem, itemCount };
};
