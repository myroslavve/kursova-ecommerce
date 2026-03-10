<template>
  <div>
    <!-- Loading -->
    <div v-if="status === 'pending'" class="loading">
      <div class="spinner" />
      <p>Loading…</p>
    </div>

    <!-- Error / Not found -->
    <div v-else-if="status === 'error'" class="error-box">
      <p>⚠️ Product not found.</p>
      <NuxtLink to="/catalog" class="back-link">← Back to Catalog</NuxtLink>
    </div>

    <!-- Product detail -->
    <div v-else-if="product" class="detail-layout">
      <NuxtLink to="/catalog" class="back-link">← Back to Catalog</NuxtLink>

      <div class="detail-card">
        <!-- Image -->
        <div class="image-box">
          <img
            v-if="product.imageUrl"
            :src="product.imageUrl"
            :alt="product.name"
            class="product-image"
          />
          <div v-else class="image-placeholder">🧱</div>
        </div>

        <!-- Info -->
        <div class="info">
          <span v-if="product.category" class="category-badge">{{
            product.category
          }}</span>
          <h1>{{ product.name }}</h1>
          <p v-if="product.description" class="description">
            {{ product.description }}
          </p>

          <div class="price-row">
            <span class="price">${{ product.price.toFixed(2) }}</span>
            <span
              :class="[
                'stock-badge',
                product.stock > 0 ? 'in-stock' : 'out-stock',
              ]"
            >
              {{
                product.stock > 0 ? `${product.stock} in stock` : 'Out of stock'
              }}
            </span>
          </div>

          <div class="qty-row">
            <label for="qty">Quantity:</label>
            <input
              id="qty"
              v-model.number="qty"
              type="number"
              min="1"
              :max="product.stock"
            />
          </div>

          <button
            class="add-btn"
            :disabled="product.stock === 0 || adding"
            @click="addToCart"
          >
            {{ adding ? 'Adding…' : '🛒 Add to Cart' }}
          </button>

          <p v-if="addedMsg" class="added-msg">{{ addedMsg }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Product } from '~/pages/catalog/index.vue';

const route = useRoute();
const config = useRuntimeConfig();
const { addItem } = useCart();

const id = route.params.id as string;

const { data: product, status } = await useFetch<Product>(
  `${config.public.apiBase}/products/${id}`,
);

useSeoMeta({
  title: () =>
    product.value ? `${product.value.name} — LEGOStore` : 'Product',
  description: () => product.value?.description ?? '',
  ogImage: () => product.value?.imageUrl ?? undefined,
});

const qty = ref(1);
const adding = ref(false);
const addedMsg = ref('');

async function addToCart() {
  if (!product.value) return;
  adding.value = true;
  addedMsg.value = '';
  try {
    await addItem({
      productId: product.value.id,
      name: product.value.name,
      price: product.value.price,
      quantity: qty.value,
    });
    addedMsg.value = `✅ Added ${qty.value} × "${product.value.name}" to cart!`;
  } catch (e: unknown) {
    addedMsg.value = '❌ Failed to add item. Is the backend running?';
  } finally {
    adding.value = false;
  }
}
</script>

<style scoped>
.loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  padding: 4rem 0;
  color: #666;
}
.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #e0e0e0;
  border-top-color: #1a1a2e;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.error-box {
  background: #fff0f0;
  border: 1px solid #f5c2c2;
  border-radius: 8px;
  padding: 2rem;
  text-align: center;
  color: #c0392b;
}

.back-link {
  display: inline-block;
  margin-bottom: 1.5rem;
  color: #555;
  font-size: 0.9rem;
  transition: color 0.2s;
}
.back-link:hover {
  color: #1a1a2e;
}

.detail-card {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2.5rem;
  padding: 2.5rem;
}
@media (max-width: 700px) {
  .detail-card {
    grid-template-columns: 1fr;
  }
}

.image-box {
  aspect-ratio: 1;
  border-radius: 8px;
  overflow: hidden;
  background: #f0f0f0;
  display: flex;
  align-items: center;
  justify-content: center;
}
.product-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.image-placeholder {
  font-size: 5rem;
}

.info {
  display: flex;
  flex-direction: column;
  gap: 0.9rem;
}

.category-badge {
  display: inline-block;
  background: #e8f0fe;
  color: #1a73e8;
  font-size: 0.78rem;
  font-weight: 600;
  padding: 0.2rem 0.6rem;
  border-radius: 4px;
  width: fit-content;
}

h1 {
  font-size: 1.8rem;
  font-weight: 700;
}

.description {
  color: #555;
  line-height: 1.6;
}

.price-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex-wrap: wrap;
}
.price {
  font-size: 2rem;
  font-weight: 700;
  color: #1a1a2e;
}

.stock-badge {
  font-size: 0.82rem;
  font-weight: 600;
  padding: 0.25rem 0.6rem;
  border-radius: 4px;
}
.in-stock {
  background: #d4edda;
  color: #155724;
}
.out-stock {
  background: #f8d7da;
  color: #721c24;
}

.qty-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}
.qty-row label {
  font-weight: 500;
}
.qty-row input {
  width: 70px;
  padding: 0.4rem 0.6rem;
  border: 1px solid #ccc;
  border-radius: 6px;
  font-size: 0.95rem;
}

.add-btn {
  padding: 0.75rem 1.5rem;
  background: #1a1a2e;
  color: #fff;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
  width: fit-content;
}
.add-btn:hover:not(:disabled) {
  background: #2d2d4e;
}
.add-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.added-msg {
  font-size: 0.9rem;
  color: #155724;
}
</style>
