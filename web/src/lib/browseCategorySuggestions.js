/** When to show mid-results category suggestions (Jiji-style). */
export const BROWSE_SUGGEST_MIN_RESULTS = 24;
export const BROWSE_SUGGEST_INSERT_AT = 8;
export const BROWSE_SUGGEST_MAX_DOMINANCE = 0.6;
export const BROWSE_SUGGEST_MAX_CATEGORIES = 4;

/** Keyword → category_id hints (EN + HU). */
const KEYWORD_CATEGORY_HINTS = [
  {
    re: /\b(flat|apartment|rent|rental|room|studio|house|lakás|lakas|bérlemény|berlemeny|albérlet|alberlet|kiadó|kiado)\b/i,
    categories: ["rentals"]
  },
  {
    re: /\b(job|jobs|hire|hiring|vacancy|career|állás|allas|munka|munkát|munkat)\b/i,
    categories: ["jobs"]
  },
  {
    re: /\b(cv|resume|curriculum|seeking|keresek|állást keres|allast keres|job seeker)\b/i,
    categories: ["seeking-work"]
  },
  {
    re: /\b(service|repair|clean|cleaning|fix|szolgáltat|szolgaltat|javít|javitas)\b/i,
    categories: ["services"]
  },
  {
    re: /\b(car|auto|vehicle|motor|bmw|toyota|jármű|jarmu|autó|auto)\b/i,
    categories: ["vehicles"]
  },
  {
    re: /\b(phone|iphone|laptop|macbook|tablet|electronics|telefon|laptop|számítógép|szamitogep)\b/i,
    categories: ["electronics"]
  },
  {
    re: /\b(furniture|sofa|table|bed|desk|bútor|butor|kanapé|kanape)\b/i,
    categories: ["furniture", "clothes"]
  },
  {
    re: /\b(donation|free|donate|adomány|adomany|ingyen)\b/i,
    categories: ["donations"]
  }
];

/**
 * @param {Array<{ categoryId?: string }>} listings
 * @returns {Record<string, number>}
 */
export function countListingsByCategoryId(listings) {
  const out = {};
  for (const row of listings || []) {
    const id = String(row?.categoryId || "").trim();
    if (!id) {
      continue;
    }
    out[id] = (out[id] || 0) + 1;
  }
  return out;
}

/**
 * @param {string} query
 * @returns {string[]}
 */
function keywordHintCategoryIds(query) {
  const q = String(query || "").trim();
  if (!q) {
    return [];
  }
  const hinted = new Set();
  for (const row of KEYWORD_CATEGORY_HINTS) {
    if (row.re.test(q)) {
      for (const id of row.categories) {
        hinted.add(id);
      }
    }
  }
  return [...hinted];
}

/**
 * @param {object} filters — parseBrowseParams shape
 * @param {Array<object>} listings — filtered + sorted full result set
 * @returns {{ insertAtIndex: number, items: Array<{ categoryId: string, count: number }> } | null}
 */
export function getBrowseCategorySuggestionPlan(filters, listings) {
  const query = String(filters?.query || "").trim();
  if (!query || filters?.categoryId) {
    return null;
  }
  if ((filters?.page || 1) !== 1) {
    return null;
  }
  const rows = Array.isArray(listings) ? listings : [];
  const total = rows.length;
  if (total < BROWSE_SUGGEST_MIN_RESULTS) {
    return null;
  }

  const byCat = countListingsByCategoryId(rows);
  const entries = Object.entries(byCat)
    .map(([categoryId, count]) => ({ categoryId, count: Number(count) || 0 }))
    .filter((x) => x.count > 0);
  if (entries.length < 2) {
    return null;
  }

  entries.sort((a, b) => b.count - a.count);
  const topShare = entries[0].count / total;
  if (topShare >= BROWSE_SUGGEST_MAX_DOMINANCE) {
    return null;
  }

  const hinted = keywordHintCategoryIds(query);
  const score = (entry) => {
    let s = entry.count;
    if (hinted.includes(entry.categoryId)) {
      s += total * 0.15;
    }
    return s;
  };
  entries.sort((a, b) => score(b) - score(a));

  const items = entries.slice(0, BROWSE_SUGGEST_MAX_CATEGORIES).map(({ categoryId, count }) => ({
    categoryId,
    count
  }));
  if (items.length < 2) {
    return null;
  }

  return {
    insertAtIndex: BROWSE_SUGGEST_INSERT_AT,
    items
  };
}

/**
 * @param {object} filters
 * @param {string} categoryId
 * @returns {string}
 */
export function browseHrefWithCategory(filters, categoryId) {
  const p = new URLSearchParams();
  const q = String(filters?.query || "").trim();
  if (q) {
    p.set("q", q);
  }
  p.set("cat", String(categoryId));
  const loc = String(filters?.location || "").trim();
  if (loc) {
    p.set("loc", loc);
  }
  const qs = p.toString();
  return `/browse${qs ? `?${qs}` : ""}`;
}
