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
-- 4. SEED — тестові товари (Кубики Рубіка)
-- ---------------------------------------------------------------------------
INSERT INTO "products" ("name", "description", "price", "stock", "category", "imageUrl")
VALUES
    ('Rubik''s Cube 3×3 Original',         'Класичний кубик Рубіка 3×3. Офіційний оригінал від Rubik''s Brand.',                        12.99, 250, '3x3',       NULL),
    ('MoYu WeiLong WR M 3×3 Magnetic',    'Магнітний спідкубінг 3×3. Рекордний час збірки — рекомендований для змагань.',               29.99,  80, 'speedcube', NULL),
    ('GAN 12 M Leap 3×3 Magnetic',        'Преміум магнітний кубик GAN із системою IPG v5. Ідеал для спортсменів.',                     49.99,  40, 'speedcube', NULL),
    ('Rubik''s Cube 4×4 Revenge',          'Кубик Рубіка 4×4 — «Помста». Середній рівень складності, 304 рухомі деталі.',               19.99, 100, '4x4',       NULL),
    ('MoYu AoSu WRM 5×5 Magnetic',        'Магнітний 5×5 для досвідчених кубістів. Плавне обертання, регульований магнетизм.',          39.99,  35, '5x5',       NULL),
    ('QiYi Pyraminx M Magnetic',           'Пірамінкс — тетраедральний кутовий пазл. Відмінний вибір для початківців.',                   9.99, 150, 'pyraminx',  NULL),
    ('MoYu AoHun Megaminx Magnetic',      'Мегамінкс 12-гранний пазл із магнітним позиціонуванням. 50 кутових деталей.',               24.99,  45, 'megaminx',  NULL),
    ('GAN Mirror Blocks Gold',            'Дзеркальний кубик 3×3 — золотий. Збирається за формою, а не за кольором.',                  16.99,  60, 'specialty', NULL)
ON CONFLICT DO NOTHING;



