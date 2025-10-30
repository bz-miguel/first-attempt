-- CreateEnum
CREATE TYPE "BookingStatus" AS ENUM ('PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED');

-- AlterTable (add locale/timezone metadata)
ALTER TABLE "client"
  ADD COLUMN "locale"   VARCHAR(8),
  ADD COLUMN "timezone" VARCHAR(64);

ALTER TABLE "provider"
  ADD COLUMN "locale"   VARCHAR(8),
  ADD COLUMN "timezone" VARCHAR(64);

-- CreateTable: service
CREATE TABLE "service" (
  "id"                TEXT        NOT NULL,
  "provider_id"       TEXT        NOT NULL,
  "title"             TEXT        NOT NULL,
  "description"       TEXT,
  "price_cents"       INTEGER     NOT NULL,
  "currency"          VARCHAR(3)  NOT NULL,
  "duration_minutes"  INTEGER     NOT NULL,
  "is_active"         BOOLEAN     NOT NULL DEFAULT TRUE,
  "deleted_at"        TIMESTAMPTZ(6),
  "created_at"        TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at"        TIMESTAMPTZ(6) NOT NULL,

  CONSTRAINT "service_pkey" PRIMARY KEY ("id")
);

-- CreateTable: booking (all timestamps are timezone-aware)
CREATE TABLE "booking" (
  "id"                 TEXT             NOT NULL,
  "client_id"          TEXT             NOT NULL,
  "provider_id"        TEXT             NOT NULL,
  "service_id"         TEXT             NOT NULL,
  "status"             "BookingStatus"  NOT NULL DEFAULT 'PENDING',
  "start_at"           TIMESTAMPTZ(6)   NOT NULL,
  "end_at"             TIMESTAMPTZ(6)   NOT NULL,
  "total_price_cents"  INTEGER          NOT NULL,
  "currency"           VARCHAR(3)       NOT NULL,
  "cancelled_at"       TIMESTAMPTZ(6),
  "completed_at"       TIMESTAMPTZ(6),
  "notes"              TEXT,
  "deleted_at"         TIMESTAMPTZ(6),
  "created_at"         TIMESTAMPTZ(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at"         TIMESTAMPTZ(6)   NOT NULL,
  "timezone"           VARCHAR(64),
  "local_offset_mins"  INTEGER,

  CONSTRAINT "booking_pkey" PRIMARY KEY ("id")
);

-- Indexes
CREATE INDEX "service_provider_id_idx"         ON "service" ("provider_id");
CREATE INDEX "service_title_idx"               ON "service" ("title");
CREATE INDEX "booking_provider_id_start_at_idx" ON "booking" ("provider_id", "start_at");
CREATE INDEX "booking_client_id_start_at_idx"   ON "booking" ("client_id", "start_at");

-- Foreign Keys
ALTER TABLE "service"
  ADD CONSTRAINT "service_provider_id_fkey"
  FOREIGN KEY ("provider_id") REFERENCES "provider"("id")
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "booking"
  ADD CONSTRAINT "booking_client_id_fkey"
  FOREIGN KEY ("client_id") REFERENCES "client"("id")
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "booking"
  ADD CONSTRAINT "booking_provider_id_fkey"
  FOREIGN KEY ("provider_id") REFERENCES "provider"("id")
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "booking"
  ADD CONSTRAINT "booking_service_id_fkey"
  FOREIGN KEY ("service_id") REFERENCES "service"("id")
  ON DELETE RESTRICT ON UPDATE CASCADE;

-- ---- Anti-overlap constraint (timezone-aware) ----

-- Needed for GiST with equality on provider_id
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Generated range column using timestamptz
ALTER TABLE "booking"
  ADD COLUMN "time_range" tstzrange
  GENERATED ALWAYS AS (tstzrange("start_at", "end_at", '[)')) STORED;

-- Supporting GiST index
CREATE INDEX IF NOT EXISTS "booking_time_range_gist"
  ON "booking" USING GIST ("time_range");

-- Exclusion constraint: no overlapping active bookings per provider
ALTER TABLE "booking"
  ADD CONSTRAINT "booking_no_overlap_per_provider"
  EXCLUDE USING GIST (
    "provider_id" WITH =,
    "time_range"  WITH &&
  )
  WHERE (
    "deleted_at" IS NULL
    AND "status" IN ('PENDING','CONFIRMED')
  );
