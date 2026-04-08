/**
 * Static demo listings for UI / integration tests.
 * Disable with VITE_DEMO_LISTINGS=false (Vercel env + redeploy).
 */

const img = (seed) => `https://picsum.photos/seed/nuvelo-${seed}/800/600`;

/** Normalized listing shape (same as normalizeListingRow output) */
export const DEMO_LISTINGS = [
  {
    id: "a1000000-0000-4000-8000-000000000001",
    userId: "d0000000-0000-4000-8000-000000000001",
    categoryId: "rentals",
    title: "Bright 2-room flat near Keleti — long-term",
    description:
      "Fully furnished two-bedroom apartment, fourth floor with lift. Bills excluded. Available from May. International students welcome. Minimum 6 months.",
    price: 245000,
    currency: "HUF",
    condition: "used",
    location: "Budapest, District VIII",
    images: [img("r1")],
    categoryFields: { type: "apartment", bedrooms: 2, bathrooms: 1, area: 58 },
    createdAt: "2026-04-07T09:15:00.000Z",
    updatedAt: "2026-04-07T09:15:00.000Z",
    featured: true,
    isFeatured: true,
    viewCount: 412,
    views: 412,
    sellerName: "Anna M.",
    sellerVerified: false,
    enterprise: false
  },
  {
    id: "a1000000-0000-4000-8000-000000000002",
    userId: "d0000000-0000-4000-8000-000000000002",
    categoryId: "jobs",
    title: "English-speaking barista — downtown café",
    description:
      "Morning shifts, friendly team, training provided. Hungarian not required; work permit required. Send a short intro and availability.",
    price: 450000,
    currency: "HUF",
    condition: "other",
    location: "Budapest, District V",
    images: [img("j1")],
    categoryFields: { role: "Barista", contractType: "full-time" },
    createdAt: "2026-04-06T14:30:00.000Z",
    updatedAt: "2026-04-06T14:30:00.000Z",
    featured: false,
    isFeatured: false,
    viewCount: 289,
    views: 289,
    sellerName: "River Roast Kft.",
    sellerVerified: true,
    enterprise: true
  },
  {
    id: "a1000000-0000-4000-8000-000000000003",
    userId: "d0000000-0000-4000-8000-000000000003",
    categoryId: "services",
    title: "Certified electrician — same-week slots",
    description:
      "Installations, fault finding, new outlets. Insured. English & Hungarian. Debrecen and surrounding area.",
    price: 12000,
    currency: "HUF",
    condition: "used",
    location: "Debrecen",
    images: [img("s1")],
    categoryFields: { serviceType: "Electrical" },
    createdAt: "2026-04-05T11:00:00.000Z",
    updatedAt: "2026-04-05T11:00:00.000Z",
    featured: false,
    isFeatured: false,
    viewCount: 156,
    views: 156,
    sellerName: "Zsolt K.",
    sellerVerified: false,
    enterprise: false
  },
  {
    id: "a1000000-0000-4000-8000-000000000004",
    userId: "d0000000-0000-4000-8000-000000000004",
    categoryId: "clothes",
    title: "Winter coat — North Face, size M, like new",
    description:
      "Worn twice. Original tags available. Pickup in Szeged or ship at buyer cost. Perfect for Hungarian winters.",
    price: 42000,
    currency: "HUF",
    condition: "new",
    location: "Szeged",
    images: [img("c1"), img("c1b")],
    categoryFields: {},
    createdAt: "2026-04-04T16:45:00.000Z",
    updatedAt: "2026-04-04T16:45:00.000Z",
    featured: false,
    isFeatured: false,
    viewCount: 98,
    views: 98,
    sellerName: "Chris P.",
    sellerVerified: false,
    enterprise: false
  },
  {
    id: "a1000000-0000-4000-8000-000000000005",
    userId: "d0000000-0000-4000-8000-000000000005",
    categoryId: "vehicles",
    title: "2016 VW Golf — well maintained, full service history",
    description:
      "Petrol, manual, 118k km. New tyres 2025. Climate control, parking sensors. Reason for sale: relocating.",
    price: 3850000,
    currency: "HUF",
    condition: "used",
    location: "Győr",
    images: [img("v1"), img("v2")],
    categoryFields: { make: "Volkswagen", model: "Golf", year: 2016 },
    createdAt: "2026-04-03T10:20:00.000Z",
    updatedAt: "2026-04-03T10:20:00.000Z",
    featured: true,
    isFeatured: true,
    viewCount: 601,
    views: 601,
    sellerName: "Márton T.",
    sellerVerified: false,
    enterprise: false
  },
  {
    id: "a1000000-0000-4000-8000-000000000006",
    userId: "d0000000-0000-4000-8000-000000000006",
    categoryId: "electronics",
    title: 'MacBook Air M2 13" — 256 GB, battery 96%',
    description:
      "Space grey, Hungarian keyboard layout. No repairs. Box and charger included. Meet in person at WestEnd or Andrássy.",
    price: 329000,
    currency: "HUF",
    condition: "used",
    location: "Budapest, District VI",
    images: [img("e1")],
    categoryFields: { brand: "Apple", model: "MacBook Air M2" },
    createdAt: "2026-04-02T08:00:00.000Z",
    updatedAt: "2026-04-02T08:00:00.000Z",
    featured: false,
    isFeatured: false,
    viewCount: 512,
    views: 512,
    sellerName: "Eszter L.",
    sellerVerified: true,
    enterprise: false
  },
  {
    id: "a1000000-0000-4000-8000-000000000007",
    userId: "d0000000-0000-4000-8000-000000000007",
    categoryId: "electronics",
    title: "Sony WH-1000XM5 noise cancelling headphones",
    description:
      "Barely used, all accessories. Great for open-office or flights. Cash or Revolut on pickup in Pécs.",
    price: 89000,
    currency: "HUF",
    condition: "new",
    location: "Pécs",
    images: [img("e2")],
    categoryFields: { brand: "Sony", model: "WH-1000XM5" },
    createdAt: "2026-04-01T19:10:00.000Z",
    updatedAt: "2026-04-01T19:10:00.000Z",
    featured: false,
    isFeatured: false,
    viewCount: 203,
    views: 203,
    sellerName: "Balázs R.",
    sellerVerified: false,
    enterprise: false
  },
  {
    id: "a1000000-0000-4000-8000-000000000008",
    userId: "d0000000-0000-4000-8000-000000000008",
    categoryId: "rentals",
    title: "Room in shared flat — Corvin quarter, quiet housemates",
    description:
      "One private room in a 3-bed flat. Shared kitchen and bath. 2 minutes to metro. Ideal for students or young professionals.",
    price: 185000,
    currency: "HUF",
    condition: "used",
    location: "Budapest, District IX",
    images: [img("r2")],
    categoryFields: { type: "room", bedrooms: 1, bathrooms: 1, area: 12 },
    createdAt: "2026-03-30T12:00:00.000Z",
    updatedAt: "2026-03-30T12:00:00.000Z",
    featured: false,
    isFeatured: false,
    viewCount: 377,
    views: 377,
    sellerName: "Shared Living BP",
    sellerVerified: false,
    enterprise: false
  },
  {
    id: "a1000000-0000-4000-8000-000000000009",
    userId: "d0000000-0000-4000-8000-000000000009",
    categoryId: "jobs",
    title: "Part-time nanny — afternoons, English preferred",
    description:
      "Two kids (4 and 7). Pickup from kindergarten twice a week. District XII. References required.",
    price: 2200,
    currency: "HUF",
    condition: "other",
    location: "Budapest, District XII",
    images: [img("j2")],
    categoryFields: { role: "Nanny", contractType: "part-time" },
    createdAt: "2026-03-29T07:30:00.000Z",
    updatedAt: "2026-03-29T07:30:00.000Z",
    featured: false,
    isFeatured: false,
    viewCount: 144,
    views: 144,
    sellerName: "Family K.",
    sellerVerified: false,
    enterprise: false
  },
  {
    id: "a1000000-0000-4000-8000-00000000000a",
    userId: "d0000000-0000-4000-8000-00000000000a",
    categoryId: "real-estate",
    title: "Commercial unit — suitable for small office or studio",
    description:
      "Ground floor, street front, 45 m². Previously a design studio. Flexible lease terms. Viewing on weekends.",
    price: null,
    currency: "HUF",
    condition: "used",
    location: "Miskolc",
    images: [img("re1")],
    categoryFields: { type: "commercial", bedrooms: 0, bathrooms: 1, area: 45 },
    createdAt: "2026-03-28T15:45:00.000Z",
    updatedAt: "2026-03-28T15:45:00.000Z",
    featured: false,
    isFeatured: false,
    viewCount: 88,
    views: 88,
    sellerName: "Horizon Properties",
    sellerVerified: true,
    enterprise: true
  },
  {
    id: "a1000000-0000-4000-8000-00000000000b",
    userId: "d0000000-0000-4000-8000-00000000000b",
    categoryId: "services",
    title: "Hungarian ↔ English translation — certified available",
    description:
      "Contracts, CVs, university documents. Fast turnaround. 10+ years experience. Remote or in-person in Veszprém.",
    price: 8000,
    currency: "HUF",
    condition: "other",
    location: "Veszprém",
    images: [img("s2")],
    categoryFields: { serviceType: "Translation" },
    createdAt: "2026-03-27T09:00:00.000Z",
    updatedAt: "2026-03-27T09:00:00.000Z",
    featured: false,
    isFeatured: false,
    viewCount: 67,
    views: 67,
    sellerName: "TranslatePro",
    sellerVerified: false,
    enterprise: false
  },
  {
    id: "a1000000-0000-4000-8000-00000000000c",
    userId: "d0000000-0000-4000-8000-00000000000c",
    categoryId: "clothes",
    title: "Kids’ bike 20” — serviced, ready to ride",
    description:
      "Outgrown but in great shape. Helmet included. Meet near Balatonfüred marina.",
    price: 28000,
    currency: "HUF",
    condition: "used",
    location: "Balatonfüred",
    images: [img("k1")],
    categoryFields: {},
    createdAt: "2026-03-26T13:20:00.000Z",
    updatedAt: "2026-03-26T13:20:00.000Z",
    featured: false,
    isFeatured: false,
    viewCount: 45,
    views: 45,
    sellerName: "Petra N.",
    sellerVerified: false,
    enterprise: false
  }
];

const byId = new Map(DEMO_LISTINGS.map((l) => [l.id, l]));

export function getDemoListingById(id) {
  return byId.get(id) ?? null;
}

export function filterDemoListings(params = {}) {
  const { categoryId, location, query: keyword, minPrice, maxPrice } = params;
  let out = [...DEMO_LISTINGS];
  if (categoryId) {
    out = out.filter((l) => l.categoryId === categoryId);
  }
  const loc = String(location || "").trim().toLowerCase();
  if (loc) {
    out = out.filter((l) => String(l.location || "").toLowerCase().includes(loc));
  }
  const kw = String(keyword || "").trim().toLowerCase();
  if (kw) {
    out = out.filter(
      (l) =>
        String(l.title || "").toLowerCase().includes(kw) ||
        String(l.description || "").toLowerCase().includes(kw)
    );
  }
  if (minPrice != null && minPrice !== "" && !Number.isNaN(Number(minPrice))) {
    const n = Number(minPrice);
    out = out.filter((l) => l.price != null && Number(l.price) >= n);
  }
  if (maxPrice != null && maxPrice !== "" && !Number.isNaN(Number(maxPrice))) {
    const n = Number(maxPrice);
    out = out.filter((l) => l.price != null && Number(l.price) <= n);
  }
  return out;
}

export function mergeListingsWithDemos(realListings, params) {
  const demos = filterDemoListings(params);
  const merged = new Map();
  for (const x of demos) {
    merged.set(x.id, x);
  }
  for (const x of realListings) {
    merged.set(x.id, x);
  }
  return Array.from(merged.values()).sort(
    (a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0)
  );
}
