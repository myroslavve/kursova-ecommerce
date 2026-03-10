# Stage 1: builder
FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

# NUXT_PUBLIC_API_BASE is baked into the client bundle at build time.
ARG NUXT_PUBLIC_API_BASE=http://localhost:3000/api
ENV NUXT_PUBLIC_API_BASE=${NUXT_PUBLIC_API_BASE}

RUN npm run build


# Stage 2: runner
FROM node:22-alpine AS runner

WORKDIR /app

COPY --from=builder /app/.output ./

EXPOSE 3000

ENV API_BASE_INTERNAL=http://backend:3000/api

CMD ["node", "server/index.mjs"]
