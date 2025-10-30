-- CreateEnum
CREATE TYPE "BookingStatus" AS ENUM ('PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED');

-- CreateTable
CREATE TABLE "client" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "phone" VARCHAR(32),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "deactivated_at" TIMESTAMP(3),
    "deleted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "timezone" VARCHAR(64),
    "locale" VARCHAR(8),

    CONSTRAINT "client_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "provider" (
    "id" TEXT NOT NULL,
    "auth_user_id" TEXT,
    "display_name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "phone" VARCHAR(32),
    "description" TEXT,
    "country" VARCHAR(2),
    "city" TEXT,
    "address_line_1" TEXT,
    "address_line_2" TEXT,
    "postal_code" TEXT,
    "is_verified" BOOLEAN NOT NULL DEFAULT false,
    "rating_average" DECIMAL(3,2),
    "rating_count" INTEGER NOT NULL DEFAULT 0,
    "stripe_account_id" TEXT,
    "concurrent_capacity" INTEGER NOT NULL DEFAULT 1,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "deactivated_at" TIMESTAMP(3),
    "deleted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "timezone" VARCHAR(64),
    "locale" VARCHAR(8),

    CONSTRAINT "provider_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "service" (
    "id" TEXT NOT NULL,
    "provider_id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "price_cents" INTEGER NOT NULL,
    "currency" VARCHAR(3) NOT NULL,
    "duration_minutes" INTEGER NOT NULL,
    "concurrent_capacity" INTEGER,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "deleted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "service_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "booking" (
    "id" TEXT NOT NULL,
    "client_id" TEXT NOT NULL,
    "provider_id" TEXT NOT NULL,
    "service_id" TEXT NOT NULL,
    "status" "BookingStatus" NOT NULL DEFAULT 'PENDING',
    "start_at" TIMESTAMPTZ(6) NOT NULL,
    "end_at" TIMESTAMPTZ(6) NOT NULL,
    "total_price_cents" INTEGER,
    "currency" VARCHAR(3) NOT NULL,
    "cancelled_at" TIMESTAMP(3),
    "completed_at" TIMESTAMP(3),
    "notes" TEXT,
    "deleted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "timezone" VARCHAR(64),
    "local_offset_mins" INTEGER,

    CONSTRAINT "booking_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "client_email_key" ON "client"("email");

-- CreateIndex
CREATE INDEX "client_name_idx" ON "client"("name");

-- CreateIndex
CREATE UNIQUE INDEX "provider_auth_user_id_key" ON "provider"("auth_user_id");

-- CreateIndex
CREATE UNIQUE INDEX "provider_email_key" ON "provider"("email");

-- CreateIndex
CREATE UNIQUE INDEX "provider_stripe_account_id_key" ON "provider"("stripe_account_id");

-- CreateIndex
CREATE INDEX "provider_display_name_idx" ON "provider"("display_name");

-- CreateIndex
CREATE INDEX "provider_city_idx" ON "provider"("city");

-- CreateIndex
CREATE INDEX "service_provider_id_idx" ON "service"("provider_id");

-- CreateIndex
CREATE INDEX "service_title_idx" ON "service"("title");

-- CreateIndex
CREATE INDEX "booking_provider_id_start_at_idx" ON "booking"("provider_id", "start_at");

-- CreateIndex
CREATE INDEX "booking_client_id_start_at_idx" ON "booking"("client_id", "start_at");

-- AddForeignKey
ALTER TABLE "service" ADD CONSTRAINT "service_provider_id_fkey" FOREIGN KEY ("provider_id") REFERENCES "provider"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking" ADD CONSTRAINT "booking_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "client"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking" ADD CONSTRAINT "booking_provider_id_fkey" FOREIGN KEY ("provider_id") REFERENCES "provider"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "booking" ADD CONSTRAINT "booking_service_id_fkey" FOREIGN KEY ("service_id") REFERENCES "service"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

