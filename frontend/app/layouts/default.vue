<template>
  <div class="site-wrapper">
    <header class="navbar">
      <nav class="nav-inner">
        <NuxtLink to="/" class="brand">🎲 CubeStore</NuxtLink>
        <div class="nav-links">
          <NuxtLink to="/catalog" class="nav-link">Catalog</NuxtLink>
          <NuxtLink to="/cart" class="nav-link cart-link">
            🛒 Cart
            <span v-if="itemCount > 0" class="badge">{{ itemCount }}</span>
          </NuxtLink>
        </div>
      </nav>
    </header>

    <main class="main-content">
      <slot />
    </main>

    <footer class="footer">
      <p>&copy; 2026 CubeStore. All rights reserved.</p>
    </footer>
  </div>
</template>

<script setup lang="ts">
const { itemCount, loadCart } = useCart();

// Load cart on every page navigation to keep badge in sync
onMounted(loadCart);
</script>

<style>
*,
*::before,
*::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family:
    system-ui,
    -apple-system,
    BlinkMacSystemFont,
    'Segoe UI',
    sans-serif;
  background: #f5f5f5;
  color: #111;
}

a {
  color: inherit;
  text-decoration: none;
}
</style>

<style scoped>
.site-wrapper {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.navbar {
  background: #1a1a2e;
  color: #fff;
  position: sticky;
  top: 0;
  z-index: 100;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
}

.nav-inner {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1.5rem;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.brand {
  font-size: 1.4rem;
  font-weight: 700;
  letter-spacing: -0.5px;
}

.nav-links {
  display: flex;
  gap: 1.5rem;
  align-items: center;
}

.nav-link {
  font-size: 0.95rem;
  font-weight: 500;
  padding: 0.4rem 0.75rem;
  border-radius: 6px;
  transition: background 0.2s;
}
.nav-link:hover,
.router-link-active {
  background: rgba(255, 255, 255, 0.12);
}

.cart-link {
  position: relative;
}

.badge {
  position: absolute;
  top: -4px;
  right: -8px;
  background: #e63946;
  color: #fff;
  font-size: 0.7rem;
  font-weight: 700;
  min-width: 18px;
  height: 18px;
  border-radius: 9px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 4px;
}

.main-content {
  flex: 1;
  max-width: 1200px;
  width: 100%;
  margin: 0 auto;
  padding: 2rem 1.5rem;
}

.footer {
  background: #1a1a2e;
  color: rgba(255, 255, 255, 0.5);
  text-align: center;
  padding: 1rem;
  font-size: 0.85rem;
}
</style>
