import { z } from "zod";

export const UUID = z.string().uuid();
export const ISODate = z.string().datetime({ offset: true }); // expects ISO with timezone, e.g. 2025-10-29T10:00:00Z

// Clients
export const ClientCreateSchema = z.object({
  displayName: z.string().min(1),
  email: z.string().email(),
  phone: z.string().max(32).optional(),
  city: z.string().optional(),
  timezone: z.string().min(1),
  description: z.string().max(1000).optional(),
});
export type ClientCreateInput = z.infer<typeof ClientCreateSchema>;

// Providers
export const ProviderCreateSchema = z.object({
  displayName: z.string().min(1), // ✅ use this, not getDisplayName
  email: z.string().email(),
  phone: z.string().max(32).optional(),
  city: z.string().optional(),
  timezone: z.string().min(1),
  description: z.string().max(1000).optional(),
});
export type ProviderCreateInput = z.infer<typeof ProviderCreateSchema>;

// Bookings
export const BookingCreateSchema = z
  .object({
    clientId: z.string().uuid(),
    serviceId: z.string().uuid(),
    startAt: z.string().datetime(),
    endAt: z.string().datetime(),
    timezone: z.string().optional(),
    notes: z.string().max(1000).optional(),
  })
  .refine((d) => new Date(d.endAt).getTime() > new Date(d.startAt).getTime(), {
    message: "endAt must be after startAt",
    path: ["endAt"],
  });

export type BookingCreateInput = z.infer<typeof BookingCreateSchema>;

// Services
export const ServiceCreateSchema = z.object({
  providerId: UUID,
  title: z.string().min(1),
  description: z.string().max(1000).optional(),
  priceCents: z.number().int().nonnegative(),
  currency: z.string().length(3),
  durationMinutes: z.number().int().positive(),
});
export type ServiceCreateInput = z.infer<typeof ServiceCreateSchema>;
