# Stage 1: builder
FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

RUN npx prisma generate

# Compile TypeScript → dist/
RUN npm run build


# Stage 2: runner
FROM node:22-alpine AS runner

# psql CLI is needed in the entrypoint to apply the SQL migration
RUN apk add --no-cache postgresql-client

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

# Compiled app
COPY --from=builder /app/dist ./dist

COPY --from=builder /app/generated ./generated

COPY --from=builder /app/prisma ./prisma

COPY docker-entrypoint.sh ./
RUN chmod +x docker-entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["./docker-entrypoint.sh"]
