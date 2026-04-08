import { HUNGARIAN_LOCATIONS } from "./hungarianLocations.js";
import { DONATIONS_CATEGORY_ID } from "./donationConstants.js";

const city = (value) => HUNGARIAN_LOCATIONS.find((r) => r.value === value)?.label || "Budapest";

/**
 * At least 2 demo donations per sub-category, varied cities.
 * categoryFields.claimed can be overridden by localStorage in listingsApi.
 */
const DONATION_TEMPLATES = [
  {
    sub: "food",
    cityKey: "debrecen",
    title: "Sealed pantry staples bundle",
    description:
      "Unopened tins, pasta, rice, and spices. Moving abroad and clearing the cupboard. Best before dates mostly 2026.",
    donationCondition: "good",
    collectionMethod: "pickup",
    claimed: false,
    quantity: 1,
    image: "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=800&q=80"
  },
  {
    sub: "food",
    cityKey: "szeged",
    title: "Homemade soup portions (frozen)",
    description:
      "Vegetable soup in freezer-safe containers. Made yesterday; please bring a cool bag for pickup.",
    donationCondition: "new",
    collectionMethod: "pickup",
    claimed: true,
    quantity: 8,
    image: "https://images.unsplash.com/photo-1547592166-23abf457d0d0?w=800&q=80"
  },
  {
    sub: "clothing",
    cityKey: "budapest",
    title: "Bag of winter clothes — all sizes",
    description:
      "Mixed adult and teen jackets, scarves, gloves. Washed and folded. Some items have minor pilling.",
    donationCondition: "good",
    collectionMethod: "pickup",
    claimed: false,
    quantity: 1,
    image: "https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=800&q=80"
  },
  {
    sub: "clothing",
    cityKey: "pecs",
    title: "Kids' shoes and rain boots",
    description:
      "Sizes roughly EU 28–32. Outgrown but still usable; rain boots have scuffs on toes.",
    donationCondition: "worn",
    collectionMethod: "local_delivery",
    deliveryKm: 5,
    claimed: false,
    quantity: 4,
    image: "https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=800&q=80"
  },
  {
    sub: "bikes",
    cityKey: "gyor",
    title: "Adult city bike (needs tune-up)",
    description:
      "Steel frame, 7-speed. Brakes work; gears could use adjustment. Free to someone who can collect.",
    donationCondition: "worn",
    collectionMethod: "pickup",
    claimed: false,
    quantity: 1,
    image: "https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=800&q=80"
  },
  {
    sub: "bikes",
    cityKey: "miskolc",
    title: "Child scooter + helmet",
    description:
      "Scooter for ages 5–8; helmet adjustable. Helmet never dropped hard.",
    donationCondition: "good",
    collectionMethod: "pickup",
    claimed: false,
    quantity: 1,
    image: "https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=800&q=80"
  },
  {
    sub: "household",
    cityKey: "nyiregyhaza",
    title: "Electric kettle and toaster set",
    description:
      "Both working. Kettle has some limescale; descale before use. EU plugs.",
    donationCondition: "like_new",
    collectionMethod: "local_delivery",
    deliveryKm: 10,
    claimed: false,
    quantity: 2,
    image: "https://images.unsplash.com/photo-1556911220-bff31c812dba?w=800&q=80"
  },
  {
    sub: "household",
    cityKey: "kecskemet",
    title: "Dinner plates and cutlery set",
    description:
      "6 plates, bowls, forks, knives — IKEA-style white ceramic. No chips.",
    donationCondition: "good",
    collectionMethod: "pickup",
    claimed: true,
    quantity: 1,
    image: "https://images.unsplash.com/photo-1603199509609-286e6d7c7d7c?w=800&q=80"
  },
  {
    sub: "books",
    cityKey: "szekesfehervar",
    title: "Hungarian course textbooks bundle",
    description:
      "A1–B1 level course books with exercises. Some pencil notes in margins.",
    donationCondition: "good",
    collectionMethod: "post",
    claimed: false,
    quantity: 1,
    image: "https://images.unsplash.com/photo-1512820790803-83ca734da794?w=800&q=80"
  },
  {
    sub: "books",
    cityKey: "szombathely",
    title: "Novels in English (paperback)",
    description:
      "Contemporary fiction — 12 books. Good condition; swap for nothing, just passing them on.",
    donationCondition: "like_new",
    collectionMethod: "pickup",
    claimed: false,
    quantity: 12,
    image: "https://images.unsplash.com/photo-1524995997943-a263c4f7c7d0?w=800&q=80"
  },
  {
    sub: "toys",
    cityKey: "szolnok",
    title: "LEGO Duplo mixed bricks",
    description:
      "Large tub of Duplo bricks and figures. Washed and sorted.",
    donationCondition: "good",
    collectionMethod: "pickup",
    claimed: false,
    quantity: 1,
    image: "https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=800&q=80"
  },
  {
    sub: "toys",
    cityKey: "tatabanya",
    title: "Board games and puzzles",
    description:
      "Settlers of Catan (complete), 500-piece puzzle (unopened), kids' memory game.",
    donationCondition: "good",
    collectionMethod: "local_delivery",
    deliveryKm: 8,
    claimed: false,
    quantity: 3,
    image: "https://images.unsplash.com/photo-1606503153255-59d8b8bff0e6?w=800&q=80"
  },
  {
    sub: "furniture",
    cityKey: "kaposvar",
    title: "Small bookshelf (IKEA-style)",
    description:
      "Particle board, 5 shelves. Disassembled with screws bagged; collection only from ground floor.",
    donationCondition: "worn",
    collectionMethod: "pickup",
    claimed: false,
    quantity: 1,
    image: "https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=800&q=80"
  },
  {
    sub: "furniture",
    cityKey: "bekescsaba",
    title: "Office desk (120 cm)",
    description:
      "Light wood surface, metal legs. Surface scratches from use; structurally solid.",
    donationCondition: "good",
    collectionMethod: "pickup",
    claimed: true,
    quantity: 1,
    image: "https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=800&q=80"
  },
  {
    sub: "garden",
    cityKey: "veszprem",
    title: "Terracotta pots and plant cuttings",
    description:
      "Assorted pots (small/medium) + herb cuttings from balcony garden. Bring a box.",
    donationCondition: "good",
    collectionMethod: "pickup",
    claimed: false,
    quantity: 1,
    image: "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800&q=80"
  },
  {
    sub: "garden",
    cityKey: "zalaegerszeg",
    title: "Garden hand tools bundle",
    description:
      "Spade, rake, shears — used but functional. Rust cleaned off where possible.",
    donationCondition: "worn",
    collectionMethod: "local_delivery",
    deliveryKm: 15,
    claimed: false,
    quantity: 1,
    image: "https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?w=800&q=80"
  },
  {
    sub: "other",
    cityKey: "sopron",
    title: "Moving boxes and bubble wrap",
    description:
      "20 flattened cardboard boxes + one roll of bubble wrap. Free to whoever collects first.",
    donationCondition: "good",
    collectionMethod: "pickup",
    claimed: false,
    quantity: 20,
    image: "https://images.unsplash.com/photo-1600880292203-757bb62b4baf?w=800&q=80"
  },
  {
    sub: "other",
    cityKey: "eger",
    title: "USB cables and adapters",
    description:
      "Mixed USB-A/C, micro-USB, HDMI. Tested before listing; surplus from upgrade.",
    donationCondition: "like_new",
    collectionMethod: "post",
    claimed: false,
    quantity: 1,
    image: "https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04?w=800&q=80"
  }
];

function buildDonation(idx, t) {
  const locLabel = city(t.cityKey);
  const createdTs = Date.now() - (idx + 100) * 7200_000;
  const contactPref = ["message via app", "show email", "show phone"][idx % 3];
  const cf = {
    donationSubCategory: t.sub,
    donationCondition: t.donationCondition,
    collectionMethod: t.collectionMethod,
    deliveryKm: t.deliveryKm ?? null,
    claimed: Boolean(t.claimed),
    contactPreference: contactPref,
    quantity: t.quantity ?? 1,
    sellerMemberSince: `${2019 + (idx % 5)}`
  };
  return {
    id: `demo-donation-${String(idx + 1).padStart(3, "0")}`,
    userId: `demo-user-${String((idx % 35) + 1).padStart(3, "0")}`,
    categoryId: DONATIONS_CATEGORY_ID,
    title: `${t.title} — ${locLabel}`,
    description: `${t.description} Location: ${locLabel}.`,
    price: 0,
    currency: "HUF",
    condition: "other",
    location: locLabel,
    images: [t.image],
    categoryFields: cf,
    createdAt: new Date(createdTs).toISOString(),
    updatedAt: new Date(createdTs).toISOString(),
    featured: false,
    isFeatured: false,
    viewCount: 12 + (idx % 40) * 3,
    views: 12 + (idx % 40) * 3,
    sellerName: `Nuvelo Donor ${idx + 1}`,
    sellerVerified: idx % 4 === 0,
    enterprise: false
  };
}

export const DEMO_DONATION_LISTINGS = DONATION_TEMPLATES.map((t, i) => buildDonation(i, t));
