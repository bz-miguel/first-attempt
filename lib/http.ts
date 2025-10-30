// lib/http.ts
import type { NextRequest } from "next/server";
import { NextResponse } from "next/server";

export function json<T>(data: T, init?: number | ResponseInit) {
  const resInit = typeof init === "number" ? { status: init } : init;
  return NextResponse.json<T>(data, resInit);
}

export function badRequest(message: string, issues?: unknown) {
  return json({ error: message, issues }, 400);
}
export function conflict(message: string) {
  return json({ error: message }, 409);
}
export function notFound(message = "Not found") {
  return json({ error: message }, 404);
}
export function serverError(message = "Internal server error") {
  return json({ error: message }, 500);
}

export function parseLimit(req: NextRequest, fallback = 20, max = 100) {
  const url = new URL(req.url);
  const v = Number(url.searchParams.get("limit"));
  if (!Number.isFinite(v) || v <= 0) return fallback;
  return Math.min(v, max);
}
export function parseCursor(req: NextRequest) {
  const url = new URL(req.url);
  return url.searchParams.get("cursor") ?? undefined;
}
