<template>
  <div>
    <div class="page-header">
      <h1>Catalog</h1>
      <p class="subtitle">
        Browse our collection of Rubik's Cubes & twisty puzzles
      </p>
    </div>

    <!-- Loading state -->
    <div v-if="status === 'pending'" class="loading">
      <div class="spinner" />
      <p>Loading products…</p>
    </div>

    <!-- Error state -->
    <div v-else-if="status === 'error'" class="error-box">
      <p>⚠️ Could not load products. Make sure the backend is running.</p>
      <button @click="refresh()">Retry</button>
    </div>

    <!-- Empty state -->
    <div v-else-if="!products?.length" class="empty">
      <p>No products found. Run the SQL migration to seed the database.</p>
    </div>

    <!-- Product grid -->
    <div v-else class="product-grid">
      <ProductCard
        v-for="product in products"
        :key="product.id"
        :product="product"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
export interface Product {
  id: string;
  name: string;
  description: string | null;
  price: number;
  stock: number;
  category: string | null;
  imageUrl: string | null;
}

const {
  data: products,
  status,
  refresh,
} = await useFetch<Product[]>(() => `${useApiBase()}/products`);

useSeoMeta({
  title: 'Catalog — CubeStore',
  description:
    "Browse our full collection of Rubik's Cubes and twisty puzzles. Fast delivery, great prices.",
});
</script>

<style scoped>
.page-header {
  margin-bottom: 2rem;
}
.page-header h1 {
  font-size: 2rem;
  font-weight: 700;
}
.subtitle {
  color: #666;
  margin-top: 0.35rem;
}

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
  padding: 1.5rem;
  text-align: center;
  color: #c0392b;
}
.error-box button {
  margin-top: 0.75rem;
  padding: 0.5rem 1.25rem;
  background: #c0392b;
  color: #fff;
  border: none;
  border-radius: 6px;
  cursor: pointer;
}

.empty {
  text-align: center;
  padding: 4rem 0;
  color: #999;
}

.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 1.5rem;
}
</style>
