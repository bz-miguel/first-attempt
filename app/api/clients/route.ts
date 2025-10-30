// app/api/clients/route.ts
export const runtime = "nodejs";

import {
  badRequest,
  json,
  parseCursor,
  parseLimit,
  serverError,
} from "@/lib/http";
import { prisma } from "@/lib/prisma";
import { ClientCreateSchema } from "@/lib/validators";
import { Prisma } from "@prisma/client";
import type { NextRequest } from "next/server";

export async function GET(req: NextRequest) {
  try {
    const limit = parseLimit(req);
    const cursor = parseCursor(req);

    const items = await prisma.client.findMany({
      where: { deletedAt: null },
      take: limit + 1,
      ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
      orderBy: { createdAt: "desc" },
      select: {
        id: true,
        displayName: true,
        email: true,
        phone: true,
        timezone: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    const nextCursor = items.length > limit ? items.pop()!.id : undefined;
    return json({ data: items, nextCursor });
  } catch (err: unknown) {
    console.error("GET /api/clients error:", err);
    return serverError();
  }
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const parsed = ClientCreateSchema.safeParse(body);
    if (!parsed.success)
      return badRequest("Invalid body", parsed.error.flatten());

    const created = await prisma.client.create({ data: parsed.data });
    return json({ data: created }, 201);
  } catch (err: unknown) {
    if (err instanceof Prisma.PrismaClientKnownRequestError) {
      // Unique constraint (e.g., email)
      if (err.code === "P2002") {
        return badRequest("Client already exists with a unique field");
      }
    }
    console.error("POST /api/clients error:", err);
    return serverError();
  }
}
