export const runtime = "nodejs";

import {
  badRequest,
  json,
  parseCursor,
  parseLimit,
  serverError,
} from "@/lib/http";
import { prisma } from "@/lib/prisma";
import { ServiceCreateSchema } from "@/lib/validators";
import { Prisma } from "@prisma/client";
import type { NextRequest } from "next/server";

// GET /api/services
export async function GET(req: NextRequest) {
  try {
    const limit = parseLimit(req);
    const cursor = parseCursor(req);

    const items = await prisma.service.findMany({
      where: { deletedAt: null },
      take: limit + 1,
      ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
      orderBy: { createdAt: "desc" },
      select: {
        id: true,
        providerId: true,
        title: true,
        description: true,
        priceCents: true,
        currency: true,
        durationMinutes: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    const nextCursor = items.length > limit ? items.pop()!.id : undefined;
    return json({ data: items, nextCursor });
  } catch (e) {
    console.error("GET /api/services error:", e);
    return serverError();
  }
}

// POST /api/services
export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const parsed = ServiceCreateSchema.safeParse(body);
    if (!parsed.success)
      return badRequest("Invalid body", parsed.error.flatten());

    const created = await prisma.service.create({
      data: {
        providerId: parsed.data.providerId,
        title: parsed.data.title,
        description: parsed.data.description ?? null,
        priceCents: parsed.data.priceCents,
        currency: parsed.data.currency,
        durationMinutes: parsed.data.durationMinutes,
      },
      select: {
        id: true,
        providerId: true,
        title: true,
        description: true,
        priceCents: true,
        currency: true,
        durationMinutes: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    return json({ data: created }, 201);
  } catch (err: unknown) {
    if (err instanceof Prisma.PrismaClientKnownRequestError) {
      if (err.code === "P2003")
        return badRequest("Related record not found (foreign key)"); // bad providerId
    }
    console.error("POST /api/services error:", err);
    return serverError();
  }
}
