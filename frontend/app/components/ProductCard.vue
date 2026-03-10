<template>
  <NuxtLink :to="`/catalog/${product.id}`" class="card">
    <!-- Image -->
    <div class="card-image">
      <img
        v-if="product.imageUrl"
        :src="product.imageUrl"
        :alt="product.name"
        loading="lazy"
      />
      <div v-else class="placeholder">🎲</div>
    </div>

    <!-- Body -->
    <div class="card-body">
      <span v-if="product.category" class="category">{{
        product.category
      }}</span>
      <h3 class="name">{{ product.name }}</h3>
      <p v-if="product.description" class="description">{{ truncated }}</p>
    </div>

    <!-- Footer -->
    <div class="card-footer">
      <span class="price">${{ product.price.toFixed(2) }}</span>
      <span :class="['stock', product.stock > 0 ? 'in-stock' : 'out-stock']">
        {{ product.stock > 0 ? 'In stock' : 'Sold out' }}
      </span>
    </div>
  </NuxtLink>
</template>

<script setup lang="ts">
import type { Product } from '~/pages/catalog/index.vue';

const props = defineProps<{ product: Product }>();

const truncated = computed(() => {
  const d = props.product.description ?? '';
  return d.length > 90 ? d.slice(0, 90) + '…' : d;
});
</script>

<style scoped>
.card {
  display: flex;
  flex-direction: column;
  background: #fff;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 1px 6px rgba(0, 0, 0, 0.08);
  transition:
    transform 0.18s,
    box-shadow 0.18s;
  cursor: pointer;
}
.card:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.12);
}

.card-image {
  aspect-ratio: 4/3;
  background: #f0f2f5;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}
.card-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.placeholder {
  font-size: 3.5rem;
}

.card-body {
  padding: 0.9rem 1rem 0.25rem;
  flex: 1;
}

.category {
  font-size: 0.72rem;
  font-weight: 600;
  color: #1a73e8;
  background: #e8f0fe;
  padding: 0.18rem 0.5rem;
  border-radius: 4px;
}

.name {
  margin-top: 0.5rem;
  font-size: 1rem;
  font-weight: 700;
  color: #111;
  line-height: 1.3;
}

.description {
  margin-top: 0.35rem;
  font-size: 0.82rem;
  color: #777;
  line-height: 1.45;
}

.card-footer {
  padding: 0.75rem 1rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-top: 1px solid #f0f0f0;
  margin-top: 0.5rem;
}

.price {
  font-size: 1.05rem;
  font-weight: 700;
  color: #1a1a2e;
}

.stock {
  font-size: 0.78rem;
  font-weight: 600;
  padding: 0.2rem 0.5rem;
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
</style>
