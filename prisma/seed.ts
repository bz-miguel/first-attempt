// prisma/seed.ts
import { BookingStatus, PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

async function main() {
  // Provider
  const provider = await prisma.provider.upsert({
    where: { email: "patas@example.com" },
    update: {},
    create: {
      displayName: "Clínica Patas",
      email: "patas@example.com",
      city: "Lisboa",
      timezone: "Europe/Lisbon",
      isVerified: true,
    },
  });

  // Service
  const service = await prisma.service.upsert({
    where: { id: "svc-consulta" },
    update: {},
    create: {
      id: "svc-consulta",
      providerId: provider.id,
      title: "Consulta Geral",
      description: "Check-up básico",
      priceCents: 3000,
      currency: "EUR",
      durationMinutes: 30,
    },
  });

  // Client
  const client = await prisma.client.upsert({
    where: { email: "ana@example.com" },
    update: {},
    create: {
      displayName: "Ana Cliente",
      email: "ana@example.com",
      timezone: "Europe/Lisbon",
      locale: "pt-PT",
    },
  });

  // Booking (não sobrepõe — a constraint de overlap protege)
  const start = new Date("2025-11-01T10:00:00Z");
  const end = new Date("2025-11-01T10:30:00Z");

  await prisma.booking.upsert({
    where: { id: "bk-1" },
    update: {},
    create: {
      id: "bk-1",
      clientId: client.id,
      providerId: provider.id,
      serviceId: service.id,
      status: BookingStatus.CONFIRMED,
      startAt: start,
      endAt: end,
      totalPriceCents: 3000,
      currency: "EUR",
      timezone: "Europe/Lisbon",
      localOffsetMins: 60,
    },
  });
}

main()
  .then(() => console.log("✅ Seed concluído"))
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
