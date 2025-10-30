/*
  Warnings:

  - You are about to drop the column `time_range` on the `booking` table. All the data in the column will be lost.

*/
-- DropIndex
DROP INDEX "public"."booking_time_range_gist";

-- AlterTable
ALTER TABLE "booking" DROP COLUMN "time_range",
ALTER COLUMN "start_at" SET DATA TYPE TIMESTAMP(3),
ALTER COLUMN "end_at" SET DATA TYPE TIMESTAMP(3),
ALTER COLUMN "cancelled_at" SET DATA TYPE TIMESTAMP(3),
ALTER COLUMN "completed_at" SET DATA TYPE TIMESTAMP(3),
ALTER COLUMN "deleted_at" SET DATA TYPE TIMESTAMP(3),
ALTER COLUMN "created_at" SET DATA TYPE TIMESTAMP(3),
ALTER COLUMN "updated_at" SET DATA TYPE TIMESTAMP(3);

-- AlterTable
ALTER TABLE "service" ALTER COLUMN "deleted_at" SET DATA TYPE TIMESTAMP(3),
ALTER COLUMN "created_at" SET DATA TYPE TIMESTAMP(3),
ALTER COLUMN "updated_at" SET DATA TYPE TIMESTAMP(3);
