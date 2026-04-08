import { HUNGARIAN_LOCATIONS } from "./hungarianLocations.js";
import { DEMO_DONATION_LISTINGS } from "./demoDonations.js";

/**
 * Static demo listings for UI/integration tests.
 * Disable with VITE_DEMO_LISTINGS=false (Vercel env + redeploy).
 */

const DEMO_TEMPLATES = [
  {
    key: "rentals",
    categoryId: "rentals",
    title: "Furnished studio near city center",
    description:
      "Bright apartment with washing machine, fast Wi-Fi, and low utility costs. Landlord speaks English and supports expat paperwork.",
    image: "https://images.unsplash.com/photo-1493666438817-866a91353ca9?w=800&q=80",
    price: 195000,
    condition: "used",
    fields: { type: "studio", bedrooms: 1, bathrooms: 1, area: 34 }
  },
  {
    key: "jobs",
    categoryId: "jobs",
    title: "Customer support specialist (English)",
    description:
      "International team, hybrid schedule, and onboarding support for newcomers. Prior helpdesk experience is a plus.",
    image: "https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=800&q=80",
    price: 620000,
    condition: "other",
    fields: { role: "Customer Support", contractType: "full-time" }
  },
  {
    key: "services",
    categoryId: "services",
    title: "Home cleaning service (weekly slots)",
    description:
      "Trusted cleaner with references from expat families. Supplies available on request, invoicing possible for companies.",
    image: "https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800&q=80",
    price: 14000,
    condition: "other",
    fields: { serviceType: "Home cleaning" }
  },
  {
    key: "goods-items",
    categoryId: "clothes",
    title: "Dyson air purifier in excellent condition",
    description:
      "Perfect for apartments with pets or allergies. Filter recently replaced and works quietly during night mode.",
    image: "https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=800&q=80",
    price: 89000,
    condition: "used",
    fields: {}
  },
  {
    key: "vehicles",
    categoryId: "vehicles",
    title: "2017 VW Golf 1.4 TSI, full service history",
    description:
      "Reliable city and highway car with valid technical inspection, winter tires included, and documented maintenance records.",
    image: "https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800&q=80",
    price: 4190000,
    condition: "used",
    fields: { make: "Volkswagen", model: "Golf", year: 2017 }
  },
  {
    key: "electronics",
    categoryId: "electronics",
    title: "iPhone 14, 128GB, factory unlocked",
    description:
      "Battery health above 90%, no cracks, original box and cable included. Great option for students and remote workers.",
    image: "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800&q=80",
    price: 249000,
    condition: "used",
    fields: { brand: "Apple", model: "iPhone 14" }
  },
  {
    key: "furniture-home",
    categoryId: "electronics",
    title: "Solid oak dining table with 4 chairs",
    description:
      "Sturdy table set for small apartments, easy to transport in two parts. Minor wear on the tabletop edge.",
    image: "https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800&q=80",
    price: 125000,
    condition: "used",
    fields: { brand: "HomeCraft", model: "Oak Set" }
  },
  {
    key: "fashion",
    categoryId: "clothes",
    title: "Zara trench coat, beige, size M",
    description:
      "Classic spring/autumn coat worn only a few times. Clean, smoke-free home, pickup near tram lines.",
    image: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800&q=80",
    price: 32000,
    condition: "new",
    fields: {}
  },
  {
    key: "babies-kids",
    categoryId: "clothes",
    title: "Baby stroller with rain cover and cup holder",
    description:
      "Smooth wheels and compact fold. Perfect for city walking and public transport around Hungary.",
    image: "https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=800&q=80",
    price: 74000,
    condition: "used",
    fields: {}
  },
  {
    key: "other",
    categoryId: "real-estate",
    title: "Private Hungarian language tutoring (A1-B2)",
    description:
      "Personalized lessons for expats: everyday situations, job interviews, and bureaucracy vocabulary with practical exercises.",
    image: "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&q=80",
    price: 8500,
    condition: "other",
    fields: { type: "service", bedrooms: 0, bathrooms: 0, area: 0 }
  },
  {
    key: "vehicles-2",
    categoryId: "vehicles",
    title: "2018 Toyota Yaris Hybrid, low mileage",
    description:
      "Automatic hybrid ideal for Budapest traffic, recently serviced, and economical fuel consumption in daily commute.",
    image: "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&q=80",
    price: 5390000,
    condition: "used",
    fields: { make: "Toyota", model: "Yaris Hybrid", year: 2018 }
  }
];

const locations = HUNGARIAN_LOCATIONS.filter((x) => x.value !== "all");

const buildListing = (idx, city, template) => {
  const createdTs = Date.now() - idx * 3600_000;
  return {
    id: `demo-${String(idx + 1).padStart(4, "0")}`,
    userId: `demo-user-${String((idx % 35) + 1).padStart(3, "0")}`,
    categoryId: template.categoryId,
    title: `${template.title} — ${city.label}`,
    description: `${template.description} Location: ${city.label}.`,
    price: template.price + ((idx % 7) - 3) * 3500,
    currency: "HUF",
    condition: template.condition,
    location: city.label,
    images: [template.image],
    categoryFields: template.fields,
    createdAt: new Date(createdTs).toISOString(),
    updatedAt: new Date(createdTs).toISOString(),
    featured: idx % 19 === 0,
    isFeatured: idx % 19 === 0,
    viewCount: 45 + (idx % 30) * 11,
    views: 45 + (idx % 30) * 11,
    sellerName: `Nuvelo Demo Seller ${idx + 1}`,
    sellerVerified: idx % 3 === 0,
    enterprise: idx % 5 === 0
  };
};

const DEMO_LISTINGS_BASE = locations.flatMap((city, i) => {
  const t1 = DEMO_TEMPLATES[(i * 2) % DEMO_TEMPLATES.length];
  const t2 = DEMO_TEMPLATES[(i * 2 + 1) % DEMO_TEMPLATES.length];
  return [buildListing(i * 2, city, t1), buildListing(i * 2 + 1, city, t2)];
});

export const DEMO_LISTINGS = [...DEMO_LISTINGS_BASE, ...DEMO_DONATION_LISTINGS];

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
