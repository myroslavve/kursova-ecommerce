-- =============================================================================
-- Migration: 001_init
-- Database:   PostgreSQL 15+
-- Опис: Початкова схема — таблиці products та orders (без партиціювання).
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. ПРОДУКТИ
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "products" (
    "id"          UUID             NOT NULL DEFAULT gen_random_uuid(),
    "name"        TEXT             NOT NULL,
    "description" TEXT,
    "price"       DOUBLE PRECISION NOT NULL CHECK ("price" >= 0),
    "stock"       INTEGER          NOT NULL DEFAULT 0 CHECK ("stock" >= 0),
    "category"    TEXT,
    "imageUrl"    TEXT,
    "createdAt"   TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    "updatedAt"   TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    CONSTRAINT "products_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "products_category_idx" ON "products" ("category");


-- ---------------------------------------------------------------------------
-- 2. ЗАМОВЛЕННЯ
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "orders" (
    "id"           UUID             NOT NULL DEFAULT gen_random_uuid(),
    "sessionId"    TEXT             NOT NULL,
    "customerName" TEXT             NOT NULL,
    "items"        JSONB            NOT NULL,
    "total"        DOUBLE PRECISION NOT NULL DEFAULT 0,
    "status"       TEXT             NOT NULL DEFAULT 'pending',
    "createdAt"    TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    CONSTRAINT "orders_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "orders_sessionId_idx" ON "orders" ("sessionId");
CREATE INDEX IF NOT EXISTS "orders_status_idx"    ON "orders" ("status");


-- ---------------------------------------------------------------------------
-- 3. ТРИГЕР автооновлення products.updatedAt
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW."updatedAt" = NOW();
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER "products_updated_at"
    BEFORE UPDATE ON "products"
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();


-- ---------------------------------------------------------------------------
-- 4. SEED — тестові товари (LEGO-кубики)
-- ---------------------------------------------------------------------------
INSERT INTO "products" ("name", "description", "price", "stock", "category", "imageUrl")
VALUES
    ('LEGO Classic Brick Box',           'Набір класичних кубиків, 484 деталі',   29.99, 120, 'classic',      'https://images.lego.com/classic-brick-box.jpg'),
    ('LEGO Technic Bugatti Chiron',       'Технік Бугатті, 3599 деталей, 1:8',   449.99,  15, 'technic',      'https://images.lego.com/technic-bugatti.jpg'),
    ('LEGO Star Wars Millennium Falcon',  'Сокіл Тисячоліття, 7541 деталей',     849.99,   8, 'star-wars',    'https://images.lego.com/sw-falcon.jpg'),
    ('LEGO City Police Station',          'Поліцейська дільниця, 743 деталі',     59.99,  60, 'city',         'https://images.lego.com/city-police.jpg'),
    ('LEGO Creator 3-in-1 Dragon',        'Дракон/Риба/Фенікс, 314 деталей',     19.99, 200, 'creator',      'https://images.lego.com/creator-dragon.jpg'),
    ('LEGO Architecture Eiffel Tower',    'Ейфелева вежа, 10001 деталь',         629.99,  20, 'architecture', 'https://images.lego.com/arch-eiffel.jpg')
ON CONFLICT DO NOTHING;



