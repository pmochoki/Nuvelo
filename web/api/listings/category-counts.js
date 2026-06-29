const { applyCors } = require("../_cors");
const store = require("../_listingsStore");
const { isListingsDbEnabled } = require("../_supabaseAdmin");
const { countApprovedByCategory } = require("../_listingsDb");

function countsFromStore() {
  const byCategoryId = {};
  for (const listing of store.getAll()) {
    if (listing.status && listing.status !== "approved") {
      continue;
    }
    const id = String(listing.categoryId || "");
    if (!id) {
      continue;
    }
    byCategoryId[id] = (byCategoryId[id] || 0) + 1;
  }
  const total = Object.values(byCategoryId).reduce((sum, n) => sum + n, 0);
  return { byCategoryId, total };
}

module.exports = async (req, res) => {
  applyCors(req, res);
  if (req.method === "OPTIONS") {
    res.statusCode = 204;
    return res.end();
  }
  if (req.method !== "GET") {
    res.statusCode = 405;
    res.setHeader("Content-Type", "application/json");
    return res.end(JSON.stringify({ error: "Method not allowed" }));
  }
  try {
    const result = isListingsDbEnabled() ? await countApprovedByCategory() : countsFromStore();
    res.statusCode = 200;
    res.setHeader("Content-Type", "application/json");
    res.setHeader("Cache-Control", "public, s-maxage=300, stale-while-revalidate=600");
    return res.end(JSON.stringify(result));
  } catch (e) {
    console.error("[api/listings/category-counts] GET", e);
    res.statusCode = 500;
    res.setHeader("Content-Type", "application/json");
    return res.end(JSON.stringify({ error: "Failed to load category counts" }));
  }
};
