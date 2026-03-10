# =============================================================================
# Frontend Dockerfile — multi-stage build
#
# Stage 1 (builder): installs deps, builds Nuxt → .output/
# Stage 2 (runner):  copies only .output/ — no node_modules needed at runtime
# =============================================================================

# ── Stage 1: builder ─────────────────────────────────────────────────────────
FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

# NUXT_PUBLIC_API_BASE is embedded into the client bundle at build time.
# We set it to the host-exposed backend port so the browser can reach it.
# The server-side SSR calls use API_BASE_INTERNAL at runtime (not baked in).
ARG NUXT_PUBLIC_API_BASE=http://localhost:3000/api
ENV NUXT_PUBLIC_API_BASE=${NUXT_PUBLIC_API_BASE}

RUN npm run build


# ── Stage 2: runner ───────────────────────────────────────────────────────────
FROM node:22-alpine AS runner

WORKDIR /app

# Nuxt standalone output — no node_modules required
COPY --from=builder /app/.output ./

EXPOSE 3000

# API_BASE_INTERNAL is read at runtime by useApiBase() on the server side.
# Set it in docker-compose to the Docker-internal backend URL.
ENV API_BASE_INTERNAL=http://backend:3000/api

CMD ["node", "server/index.mjs"]
