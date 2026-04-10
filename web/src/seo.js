import { DONATIONS_CATEGORY_ID } from "./data/donationConstants.js";

export const SITE_ORIGIN = "https://nuvelo.one";

const OG_IMAGE = `${SITE_ORIGIN}/og-image.png`;

function ensureMetaName(name, content) {
  let el = document.querySelector(`meta[name="${name}"]`);
  if (!el) {
    el = document.createElement("meta");
    el.setAttribute("name", name);
    document.head.appendChild(el);
  }
  el.setAttribute("content", content);
}

function ensureMetaProperty(property, content) {
  let el = document.querySelector(`meta[property="${property}"]`);
  if (!el) {
    el = document.createElement("meta");
    el.setAttribute("property", property);
    document.head.appendChild(el);
  }
  el.setAttribute("content", content);
}

function ensureCanonical(href) {
  let el = document.querySelector('link[rel="canonical"]');
  if (!el) {
    el = document.createElement("link");
    el.setAttribute("rel", "canonical");
    document.head.appendChild(el);
  }
  el.setAttribute("href", href);
}

export function truncateDesc(s, max = 150) {
  const t = String(s || "").replace(/\s+/g, " ").trim();
  if (t.length <= max) {
    return t;
  }
  return `${t.slice(0, max - 1).trim()}…`;
}

/** Move legacy #/path URLs to real paths (one-time per navigation). */
export function migrateLegacyHashToPath() {
  const { hash, search, pathname } = window.location;
  if (!hash || !/^#!?\//.test(hash)) {
    return;
  }
  let path = hash.replace(/^#!?/, "");
  if (!path.startsWith("/")) {
    path = `/${path}`;
  }
  if (path.length > 1 && path.endsWith("/")) {
    path = path.slice(0, -1);
  }
  const next = path + search;
  if (next !== pathname + search) {
    window.history.replaceState(null, "", next);
  }
}

export function clearListingJsonLd() {
  document.getElementById("nuvelo-listing-jsonld")?.remove();
}

/**
 * @param {object} listing
 */
export function applyListingJsonLd(listing) {
  clearListingJsonLd();
  if (!listing || listing.categoryId === DONATIONS_CATEGORY_ID) {
    return;
  }
  const n = Number(listing.price);
  const price = Number.isFinite(n) && n >= 0 ? String(Math.floor(n)) : "0";
  const script = document.createElement("script");
  script.type = "application/ld+json";
  script.id = "nuvelo-listing-jsonld";
  const schema = {
    "@context": "https://schema.org",
    "@type": "Product",
    name: listing.title,
    description: truncateDesc(listing.description || "", 5000),
    offers: {
      "@type": "Offer",
      price,
      priceCurrency: listing.currency || "HUF",
      availability: "https://schema.org/InStock"
    }
  };
  script.textContent = JSON.stringify(schema);
  document.head.appendChild(script);
}

/**
 * @param {{ title: string, description: string, ogImage?: string | null, ogType?: string }} p
 */
export function applyDocumentMeta({ title, description, ogImage, ogType = "website" }) {
  const canonicalUrl = `${window.location.origin}${window.location.pathname}${window.location.search}`;
  const desc = truncateDesc(description, 160);
  const image = ogImage && String(ogImage).trim() ? String(ogImage).trim() : OG_IMAGE;
  document.title = title;
  ensureMetaName("description", desc);
  ensureMetaProperty("og:title", title);
  ensureMetaProperty("og:description", desc);
  ensureMetaProperty("og:url", canonicalUrl);
  ensureMetaProperty("og:image", image);
  ensureMetaProperty("og:type", ogType);
  ensureMetaProperty("og:site_name", "Nuvelo");
  ensureCanonical(canonicalUrl);
}

const DEFAULT_HOME = {
  title: "Nuvelo — Buy, Sell & Rent in Hungary | Free Classifieds",
  description:
    "Hungary's marketplace for the international community. Find jobs, rentals, vehicles, electronics and more. Free to list, easy to use."
};

const CATEGORY_META = {
  vehicles: { title: "Vehicles for Sale in Hungary | Nuvelo", desc: "Cars, bikes and transport in Hungary. Buy and sell vehicles on Nuvelo — free listings for internationals and locals." },
  electronics: { title: "Electronics for Sale in Hungary | Nuvelo", desc: "Phones, laptops, gadgets and tech in Hungary. Browse electronics listings on Nuvelo." },
  furniture: { title: "Furniture & Home in Hungary | Nuvelo", desc: "Furniture and home goods in Hungary. Find sofas, tables and more on Nuvelo." },
  fashion: { title: "Fashion & Clothes in Hungary | Nuvelo", desc: "Clothing and fashion in Hungary. Buy and sell on Nuvelo." },
  goods: { title: "Goods & Items in Hungary | Nuvelo", desc: "General goods and second-hand items in Hungary on Nuvelo." },
  jobs: { title: "Jobs in Hungary | Nuvelo", desc: "Job listings in Hungary for internationals and locals. Find work on Nuvelo." },
  rentals: { title: "Rentals & Housing in Hungary | Nuvelo", desc: "Apartments, rooms and rentals in Hungary. Browse Nuvelo classifieds." },
  services: { title: "Services in Hungary | Nuvelo", desc: "Local services — repairs, lessons, professional help in Hungary on Nuvelo." },
  donations: { title: "Free Donations in Hungary | Nuvelo", desc: "Give and receive free items in Hungary. Donation listings on Nuvelo." },
  "babies-kids": { title: "Babies & Kids in Hungary | Nuvelo", desc: "Baby and kids items in Hungary. Buy and sell on Nuvelo." },
  other: { title: "Marketplace Listings in Hungary | Nuvelo", desc: "Browse misc listings in Hungary on Nuvelo." }
};

const STATIC_META = {
  browse: {
    title: "Browse Ads in Hungary | Nuvelo",
    description: "Search rentals, jobs, vehicles, services and more across Hungary. Filter by category and location on Nuvelo."
  },
  post: {
    title: "Post a Free Ad | Nuvelo",
    description: "Create a free classified listing in Hungary. Add photos, set your price and reach buyers on Nuvelo."
  },
  events: {
    title: "Events in Hungary | Nuvelo",
    description: "Community events and meetups in Hungary. Discover what is on near you on Nuvelo."
  },
  about: {
    title: "About Nuvelo | Hungary's International Marketplace",
    description: "Nuvelo connects internationals and locals in Hungary for rentals, jobs, goods and services."
  },
  faq: {
    title: "FAQ | Nuvelo",
    description: "Frequently asked questions about buying, selling and renting on Nuvelo in Hungary."
  },
  terms: {
    title: "Terms & Conditions | Nuvelo",
    description: "Terms of use for the Nuvelo marketplace in Hungary."
  },
  privacy: {
    title: "Privacy Policy | Nuvelo",
    description: "How Nuvelo handles your data and privacy."
  },
  cookies: {
    title: "Cookie Policy | Nuvelo",
    description: "How Nuvelo uses cookies and similar technologies."
  },
  safety: {
    title: "Safety Tips | Nuvelo",
    description: "Stay safe when buying and selling on Nuvelo in Hungary."
  },
  "how-to-buy": {
    title: "How to Buy Safely on Nuvelo | Nuvelo",
    description:
      "Step-by-step guide to buying safely on Nuvelo in Hungary: vet sellers, meet in public, pay securely, and report problems."
  },
  "verified-sellers": {
    title: "Verified Sellers on Nuvelo | Nuvelo",
    description:
      "What the Verified badge means on Nuvelo, buyer benefits, how to get verified, and how to report misuse."
  },
  contact: {
    title: "Contact Nuvelo",
    description: "Get in touch with the Nuvelo team."
  }
};

/**
 * @param {object} route — output of parseRoute()
 * @param {{ categorySlug?: string }} [extra]
 */
export function applyRouteMeta(route, extra = {}) {
  clearListingJsonLd();

  if (!route || route.view === "landing") {
    applyDocumentMeta(DEFAULT_HOME);
    return;
  }

  if (route.view === "list") {
    const urlSlug = route.categoryUrlSlug || extra.categoryUrlSlug || "";
    if (urlSlug && CATEGORY_META[urlSlug]) {
      applyDocumentMeta(CATEGORY_META[urlSlug]);
      return;
    }
    applyDocumentMeta(STATIC_META.browse);
    return;
  }

  if (route.view === "post") {
    applyDocumentMeta(STATIC_META.post);
    return;
  }

  if (route.view === "events" || route.view === "eventDetail") {
    applyDocumentMeta(STATIC_META.events);
    return;
  }

  if (route.view === "static" && route.page && STATIC_META[route.page]) {
    applyDocumentMeta(STATIC_META[route.page]);
    return;
  }

  if (route.view === "static") {
    applyDocumentMeta({
      title: `${String(route.page || "Page").replace(/-/g, " ")} | Nuvelo`,
      description: DEFAULT_HOME.description
    });
    return;
  }

  if (route.view === "profile" || route.view === "profileSettings") {
    applyDocumentMeta({
      title: "My account | Nuvelo",
      description: "Manage your Nuvelo profile, ads, messages and settings."
    });
    return;
  }

  if (route.view === "detail") {
    applyDocumentMeta({
      title: "Listing | Nuvelo",
      description: "View this classified listing on Nuvelo — Hungary's marketplace."
    });
    return;
  }

  applyDocumentMeta(DEFAULT_HOME);
}

/**
 * @param {object} listing
 */
function resolveOgImageUrl(raw) {
  if (raw == null || typeof raw !== "string") {
    return null;
  }
  const u = raw.trim();
  if (!u) {
    return null;
  }
  if (/^https?:\/\//i.test(u)) {
    return u;
  }
  if (u.startsWith("//")) {
    return `https:${u}`;
  }
  const origin = typeof window !== "undefined" ? window.location.origin : SITE_ORIGIN;
  if (u.startsWith("/")) {
    return `${origin}${u}`;
  }
  return `${origin}/${u.replace(/^\.?\//, "")}`;
}

export function applyListingPageMeta(listing) {
  if (!listing) {
    return;
  }
  const title = `${listing.title} — Nuvelo`;
  const description = truncateDesc(
    listing.description || `${listing.title} — ${listing.location || "Hungary"}. View on Nuvelo.`,
    160
  );
  const imgs = Array.isArray(listing.images) ? listing.images : [];
  const first = imgs.find((x) => typeof x === "string" && x.trim());
  const ogImage = resolveOgImageUrl(first);
  applyDocumentMeta({
    title,
    description,
    ogImage: ogImage || undefined,
    ogType: "article"
  });
  applyListingJsonLd(listing);
}
