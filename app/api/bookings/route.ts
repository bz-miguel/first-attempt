// app/api/bookings/route.ts
export const runtime = "nodejs";

import {
  badRequest,
  json,
  parseCursor,
  parseLimit,
  serverError,
} from "@/lib/http";
import { prisma } from "@/lib/prisma";
import { BookingCreateSchema } from "@/lib/validators";
import { Prisma } from "@prisma/client";
import type { NextRequest } from "next/server";

// GET /api/bookings
export async function GET(req: NextRequest) {
  try {
    const limit = parseLimit(req);
    const cursor = parseCursor(req);

    const items = await prisma.booking.findMany({
      where: { deletedAt: null },
      take: limit + 1,
      ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
      orderBy: { startAt: "desc" },
      select: {
        id: true,
        status: true,
        startAt: true,
        endAt: true,
        totalPriceCents: true,
        currency: true,
        timezone: true,
        notes: true,
        client: { select: { id: true, displayName: true, email: true } },
        provider: { select: { id: true, displayName: true, email: true } },
        service: {
          select: { id: true, title: true, priceCents: true, currency: true },
        },
        createdAt: true,
        updatedAt: true,
      },
    });

    const nextCursor = items.length > limit ? items.pop()!.id : undefined;
    return json({ data: items, nextCursor });
  } catch (err: unknown) {
    console.error("GET /api/bookings error:", err);
    return serverError();
  }
}

// POST /api/bookings
export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const parsed = BookingCreateSchema.safeParse(body);
    if (!parsed.success)
      return badRequest("Invalid body", parsed.error.flatten());

    const { clientId, serviceId, startAt, endAt, timezone, notes } =
      parsed.data;

    const service = await prisma.service.findUnique({
      where: { id: serviceId },
      select: { id: true, providerId: true, priceCents: true, currency: true },
    });
    if (!service) return badRequest("Service not found");

    const clientExists = await prisma.client.findUnique({
      where: { id: clientId },
      select: { id: true },
    });
    if (!clientExists) return badRequest("Client not found");

    const created = await prisma.booking.create({
      data: {
        clientId,
        serviceId,
        providerId: service.providerId,
        startAt: new Date(startAt),
        endAt: new Date(endAt),
        totalPriceCents: service.priceCents,
        currency: service.currency,
        timezone: timezone ?? null,
        notes: notes ?? null,
      },
      select: {
        id: true,
        status: true,
        startAt: true,
        endAt: true,
        totalPriceCents: true,
        currency: true,
        timezone: true,
        notes: true,
        clientId: true,
        serviceId: true,
        providerId: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    return json({ data: created }, 201);
  } catch (err: unknown) {
    if (err instanceof Prisma.PrismaClientKnownRequestError) {
      if (err.code === "P2003")
        return badRequest("Related record not found (foreign key)");
    }
    console.error("POST /api/bookings error:", err);
    return serverError();
  }
}
