-- DropIndex
DROP INDEX "orders_sessionId_idx";

-- DropIndex
DROP INDEX "orders_status_idx";

-- DropIndex
DROP INDEX "products_category_idx";

-- AlterTable
ALTER TABLE "orders" ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "total" DROP DEFAULT,
ALTER COLUMN "createdAt" SET DATA TYPE TIMESTAMP(3);

-- AlterTable
ALTER TABLE "products" ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "createdAt" SET DATA TYPE TIMESTAMP(3),
ALTER COLUMN "updatedAt" DROP DEFAULT,
ALTER COLUMN "updatedAt" SET DATA TYPE TIMESTAMP(3);
