#!/bin/sh
# =============================================================================
# docker-entrypoint.sh — backend container startup
#
# 1. Waits until PostgreSQL is accepting connections.
# 2. Applies the SQL migration idempotently (IF NOT EXISTS guards in the SQL).
# 3. Starts the NestJS server.
# =============================================================================
set -e

DB_HOST="${DB_HOST:-postgres}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-cubestore}"

echo "⏳  Waiting for PostgreSQL at ${DB_HOST}:${DB_PORT}…"
until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -q; do
  sleep 1
done
echo "✅  PostgreSQL is ready."

echo "🗄️   Applying SQL migration…"
psql "$DATABASE_URL" \
  --single-transaction \
  --file /app/prisma/migrations/001_partitioned_orders/migration.sql
echo "✅  Migration applied."

echo "🚀  Starting NestJS backend…"
exec node dist/main
