// app/api/providers/route.ts
export const runtime = "nodejs";

import {
  badRequest,
  json,
  parseCursor,
  parseLimit,
  serverError,
} from "@/lib/http";
import { prisma } from "@/lib/prisma";
import { ProviderCreateSchema } from "@/lib/validators";
import { Prisma } from "@prisma/client";
import type { NextRequest } from "next/server";

export async function GET(req: NextRequest) {
  try {
    const limit = parseLimit(req);
    const cursor = parseCursor(req);

    const items = await prisma.provider.findMany({
      where: { deletedAt: null },
      take: limit + 1,
      ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
      orderBy: { createdAt: "desc" },
      select: {
        id: true,
        displayName: true, // schema field
        email: true,
        phone: true,
        city: true,
        timezone: true,
        ratingAverage: true,
        ratingCount: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    const nextCursor = items.length > limit ? items.pop()!.id : undefined;
    return json({ data: items, nextCursor });
  } catch (err: unknown) {
    console.error("GET /api/providers error:", err);
    return serverError();
  }
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const parsed = ProviderCreateSchema.safeParse(body);
    if (!parsed.success)
      return badRequest("Invalid body", parsed.error.flatten());

    const created = await prisma.provider.create({
      data: {
        displayName: parsed.data.displayName, // map API -> DB field
        email: parsed.data.email,
        phone: parsed.data.phone ?? null,
        city: parsed.data.city ?? null,
        timezone: parsed.data.timezone ?? null,
      },
      select: {
        id: true,
        displayName: true,
        email: true,
        phone: true,
        city: true,
        timezone: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    return json({ data: created }, 201);
  } catch (err: unknown) {
    if (err instanceof Prisma.PrismaClientKnownRequestError) {
      if (err.code === "P2002")
        return badRequest("Provider already exists with a unique field");
    }
    console.error("POST /api/providers error:", err);
    return serverError();
  }
}
