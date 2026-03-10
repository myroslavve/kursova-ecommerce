# =============================================================================
# Backend Dockerfile — multi-stage build
#
# Stage 1 (builder): installs ALL deps, generates Prisma client, compiles TS
# Stage 2 (runner):  only production deps + compiled output → smallest image
# =============================================================================

# ── Stage 1: builder ─────────────────────────────────────────────────────────
FROM node:22-alpine AS builder

WORKDIR /app

# Install deps first (cached layer if package.json unchanged)
COPY package*.json ./
RUN npm ci

# Copy source
COPY . .

# Generate Prisma client (schema → generated/prisma/*)
RUN npx prisma generate

# Compile TypeScript → dist/
RUN npm run build


# ── Stage 2: runner ───────────────────────────────────────────────────────────
FROM node:22-alpine AS runner

# psql CLI is needed in the entrypoint to apply the SQL migration
RUN apk add --no-cache postgresql-client

WORKDIR /app

# Production-only node_modules
COPY package*.json ./
RUN npm ci --omit=dev

# Compiled app
COPY --from=builder /app/dist ./dist

# Generated Prisma client (runtime artefacts)
COPY --from=builder /app/generated ./generated

# SQL migration file (applied at startup by entrypoint.sh)
COPY --from=builder /app/prisma ./prisma

COPY docker-entrypoint.sh ./
RUN chmod +x docker-entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["./docker-entrypoint.sh"]
