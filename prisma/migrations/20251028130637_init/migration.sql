/*
  Warnings:

  - You are about to drop the `User` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropTable
DROP TABLE "public"."User";

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
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "deactivated_at" TIMESTAMP(3),
    "deleted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "provider_pkey" PRIMARY KEY ("id")
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
