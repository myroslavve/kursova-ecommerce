<template>
  <div>
    <h1 class="page-title">Your Cart</h1>

    <!-- Empty -->
    <div v-if="cart.items.length === 0 && !checkoutDone" class="empty">
      <p>🛒 Your cart is empty.</p>
      <NuxtLink to="/catalog" class="action-btn">Browse Cubes</NuxtLink>
    </div>

    <!-- Order confirmed -->
    <div v-else-if="checkoutDone" class="success-box">
      <h2>🎉 Order Placed!</h2>
      <p>
        Thank you, <strong>{{ lastCustomerName }}</strong
        >! Your order has been received.
      </p>
      <NuxtLink to="/catalog" class="action-btn">Continue Shopping</NuxtLink>
    </div>

    <!-- Cart + checkout form -->
    <div v-else class="cart-layout">
      <!-- Items table -->
      <section class="cart-items">
        <h2>Items</h2>
        <table>
          <thead>
            <tr>
              <th>Product</th>
              <th>Unit price</th>
              <th>Qty</th>
              <th>Subtotal</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in cart.items" :key="item.productId">
              <td>
                <NuxtLink :to="`/catalog/${item.productId}`" class="item-link">
                  {{ item.name }}
                </NuxtLink>
              </td>
              <td>${{ item.price.toFixed(2) }}</td>
              <td>{{ item.quantity }}</td>
              <td>${{ (item.price * item.quantity).toFixed(2) }}</td>
            </tr>
          </tbody>
        </table>

        <div class="cart-total">
          <span>Total</span>
          <strong>${{ cart.total.toFixed(2) }}</strong>
        </div>
      </section>

      <!-- Checkout form -->
      <section class="checkout-form">
        <h2>Checkout</h2>
        <form @submit.prevent="placeOrder">
          <label for="name">Full name</label>
          <input
            id="name"
            v-model="customerName"
            type="text"
            placeholder="John Doe"
            required
          />

          <label for="email">Email</label>
          <input
            id="email"
            v-model="email"
            type="email"
            placeholder="john@example.com"
            required
          />

          <label for="address">Shipping address</label>
          <textarea
            id="address"
            v-model="address"
            rows="3"
            placeholder="123 Puzzle Ave, Cubeville"
            required
          />

          <p v-if="checkoutError" class="error-msg">{{ checkoutError }}</p>

          <button type="submit" class="submit-btn" :disabled="placing">
            {{ placing ? 'Placing order…' : 'Place Order' }}
          </button>
        </form>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
const config = useRuntimeConfig();
const session = useSession();
const { cart, loadCart } = useCart();

// Load cart on mount (client-side refresh to pick up latest session)
onMounted(loadCart);

useSeoMeta({ title: 'Cart & Checkout — CubeStore' });

const customerName = ref('');
const email = ref('');
const address = ref('');
const placing = ref(false);
const checkoutError = ref('');
const checkoutDone = ref(false);
const lastCustomerName = ref('');

async function placeOrder() {
  placing.value = true;
  checkoutError.value = '';
  try {
    await $fetch(`${config.public.apiBase}/orders/checkout`, {
      method: 'POST',
      body: {
        sessionId: session.value,
        customerName: customerName.value,
      },
    });
    lastCustomerName.value = customerName.value;
    checkoutDone.value = true;
    // Reset cart state
    cart.value = { sessionId: '', items: [], total: 0 };
  } catch {
    checkoutError.value = '❌ Checkout failed. Please try again.';
  } finally {
    placing.value = false;
  }
}
</script>

<style scoped>
.page-title {
  font-size: 2rem;
  font-weight: 700;
  margin-bottom: 1.75rem;
}

.empty {
  text-align: center;
  padding: 4rem 0;
  color: #999;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.25rem;
}

.success-box {
  background: #d4edda;
  border: 1px solid #c3e6cb;
  border-radius: 12px;
  padding: 2.5rem;
  text-align: center;
  max-width: 480px;
  margin: 0 auto;
}
.success-box h2 {
  font-size: 1.5rem;
  margin-bottom: 0.75rem;
}

.action-btn {
  display: inline-block;
  background: #1a1a2e;
  color: #fff;
  padding: 0.65rem 1.4rem;
  border-radius: 8px;
  font-weight: 600;
  transition: background 0.2s;
}
.action-btn:hover {
  background: #2d2d4e;
}

.cart-layout {
  display: grid;
  grid-template-columns: 1fr 380px;
  gap: 2rem;
  align-items: start;
}
@media (max-width: 800px) {
  .cart-layout {
    grid-template-columns: 1fr;
  }
}

.cart-items {
  background: #fff;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.07);
}
.cart-items h2 {
  font-size: 1.2rem;
  margin-bottom: 1rem;
}

table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.93rem;
}
th {
  text-align: left;
  padding: 0.5rem 0.75rem;
  border-bottom: 2px solid #eee;
  color: #555;
}
td {
  padding: 0.6rem 0.75rem;
  border-bottom: 1px solid #f0f0f0;
}

.item-link {
  color: #1a1a2e;
  font-weight: 500;
}
.item-link:hover {
  text-decoration: underline;
}

.cart-total {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: 1rem;
  padding-top: 1rem;
  font-size: 1.1rem;
}

.checkout-form {
  background: #fff;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.07);
}
.checkout-form h2 {
  font-size: 1.2rem;
  margin-bottom: 1.25rem;
}

form {
  display: flex;
  flex-direction: column;
  gap: 0.6rem;
}

label {
  font-size: 0.88rem;
  font-weight: 600;
  color: #444;
}

input,
textarea {
  padding: 0.55rem 0.75rem;
  border: 1px solid #ccc;
  border-radius: 7px;
  font-size: 0.95rem;
  font-family: inherit;
  transition: border-color 0.2s;
}
input:focus,
textarea:focus {
  outline: none;
  border-color: #1a1a2e;
}

.error-msg {
  color: #c0392b;
  font-size: 0.88rem;
}

.submit-btn {
  margin-top: 0.5rem;
  padding: 0.75rem;
  background: #1a1a2e;
  color: #fff;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}
.submit-btn:hover:not(:disabled) {
  background: #2d2d4e;
}
.submit-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
