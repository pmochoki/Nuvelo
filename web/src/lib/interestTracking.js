/** @typedef {Record<string, number>} InterestWeights */

const INTEREST_STORE_KEY = "nuvelo_interest_weights";
const MAX_CATEGORY_WEIGHT = 100;

/** Maps UI slugs to listing API category ids (mirrors main.js CATEGORY_SLUGS). */
const SLUG_TO_API = {
  events: "events",
  donations: "donations",
  rentals: "rentals",
  jobs: "jobs",
  services: "services",
  goods: "clothes",
  vehicles: "vehicles",
  electronics: "electronics",
  furniture: "electronics",
  fashion: "clothes",
  "babies-kids": "clothes",
  other: "real-estate"
};

/** Avoid double-counting browse interest on re-renders of the same URL. */
let lastBrowseInterestKey = "";

/**
 * @param {string|null|undefined} raw
 * @returns {string}
 */
export function normalizeCategoryId(raw) {
  if (raw == null || raw === "") {
    return "";
  }
  const s = String(raw).trim().toLowerCase();
  return SLUG_TO_API[s] || s;
}

/**
 * @returns {InterestWeights}
 */
export function readInterestWeights() {
  try {
    const raw = localStorage.getItem(INTEREST_STORE_KEY);
    if (!raw) {
      return {};
    }
    const parsed = JSON.parse(raw);
    if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
      return {};
    }
    /** @type {InterestWeights} */
    const out = {};
    for (const [key, val] of Object.entries(parsed)) {
      const id = normalizeCategoryId(key);
      const n = Number(val);
      if (id && Number.isFinite(n) && n > 0) {
        out[id] = Math.min(MAX_CATEGORY_WEIGHT, Math.round(n));
      }
    }
    return out;
  } catch {
    return {};
  }
}

/**
 * @param {InterestWeights} weights
 */
function writeInterestWeights(weights) {
  try {
    localStorage.setItem(INTEREST_STORE_KEY, JSON.stringify(weights));
  } catch {
    /* ignore quota */
  }
}

/**
 * @param {string|null|undefined} categoryId
 * @param {number} [delta=1]
 */
export function recordCategoryInterest(categoryId, delta = 1) {
  const id = normalizeCategoryId(categoryId);
  const add = Number(delta);
  if (!id || !Number.isFinite(add) || add <= 0) {
    return;
  }
  const weights = readInterestWeights();
  const next = Math.min(MAX_CATEGORY_WEIGHT, (weights[id] || 0) + Math.round(add));
  weights[id] = next;
  writeInterestWeights(weights);
}

/**
 * Record interest once per browse URL when a category filter is active.
 * @param {string|null|undefined} categoryId
 * @param {number} [delta=2]
 */
export function maybeRecordBrowseCategoryInterest(categoryId, delta = 2) {
  const id = normalizeCategoryId(categoryId);
  if (!id) {
    return;
  }
  const key = `${window.location.pathname}${window.location.search}`;
  if (key === lastBrowseInterestKey) {
    return;
  }
  lastBrowseInterestKey = key;
  recordCategoryInterest(id, delta);
}

/**
 * @param {object} listing
 * @param {InterestWeights} weights
 * @param {boolean} hasPersonalInterest
 */
function trendingScore(listing, weights, hasPersonalInterest) {
  const cat = normalizeCategoryId(listing.categoryId);
  const featured = listing.isFeatured || listing.featured ? 1 : 0;
  const views = Number(listing.viewCount) || Number(listing.views) || 0;
  const created = new Date(listing.createdAt || 0).getTime();
  const ageDays = Number.isFinite(created)
    ? Math.max(0, (Date.now() - created) / 86400000)
    : 365;
  const recency = Math.max(0, 14 - ageDays);

  let score = featured * 10000 + Math.log1p(views) * 25 + recency * 8;

  if (hasPersonalInterest && cat) {
    const interest = weights[cat] || 0;
    score += interest * 120;
  }

  return score;
}

/**
 * Homepage trending: global popularity plus per-user category weights from localStorage.
 * @param {Array<object>} listings
 * @returns {Array<object>}
 */
export function sortListingsForTrending(listings) {
  if (!Array.isArray(listings) || listings.length <= 1) {
    return [...(listings || [])];
  }
  const weights = readInterestWeights();
  const totalInterest = Object.values(weights).reduce((sum, n) => sum + n, 0);
  const hasPersonalInterest = totalInterest > 0;

  return [...listings].sort((a, b) => {
    const sb = trendingScore(b, weights, hasPersonalInterest);
    const sa = trendingScore(a, weights, hasPersonalInterest);
    if (sb !== sa) {
      return sb - sa;
    }
    return new Date(b.createdAt || 0) - new Date(a.createdAt || 0);
  });
}
