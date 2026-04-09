const { getSupabaseAdmin } = require("./_supabaseAdmin");

const TABLE = "nuvelo_listings";

function mapRow(row) {
  if (!row) {
    return null;
  }
  let images = row.images;
  if (typeof images === "string") {
    try {
      images = JSON.parse(images);
    } catch {
      images = [];
    }
  }
  if (!Array.isArray(images)) {
    images = [];
  }
  let categoryFields = row.category_fields;
  if (typeof categoryFields === "string") {
    try {
      categoryFields = JSON.parse(categoryFields);
    } catch {
      categoryFields = {};
    }
  }
  if (!categoryFields || typeof categoryFields !== "object") {
    categoryFields = {};
  }
  const price = row.price;
  return {
    id: row.id,
    userId: row.user_id,
    categoryId: row.category_id,
    title: row.title,
    description: row.description ?? "",
    price: price === null || price === undefined ? null : Number(price),
    currency: row.currency || "HUF",
    condition: row.condition || "other",
    location: row.location || "",
    images,
    categoryFields,
    status: row.status,
    featured: Boolean(row.featured),
    viewCount: Number(row.view_count) || 0,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    moderationNote: row.moderation_note ?? undefined,
    moderatedAt: row.moderated_at ?? undefined,
    moderatedBy: row.moderated_by ?? undefined
  };
}

function applyClientFilters(listings, q) {
  const {
    query: keyword,
    categoryId,
    location,
    minPrice,
    maxPrice,
    userId,
    status: statusFilter
  } = q;

  return listings.filter((listing) => {
    if (userId) {
      if (String(listing.userId) !== String(userId)) {
        return false;
      }
    } else if (listing.status && listing.status !== "approved") {
      return false;
    }
    if (statusFilter && listing.status !== statusFilter) {
      return false;
    }
    if (categoryId && String(listing.categoryId) !== String(categoryId)) {
      return false;
    }
    if (location && listing.location) {
      if (!String(listing.location).toLowerCase().includes(String(location).toLowerCase())) {
        return false;
      }
    }
    if (keyword) {
      const text = `${listing.title || ""} ${listing.description || ""}`.toLowerCase();
      if (!text.includes(String(keyword).toLowerCase())) {
        return false;
      }
    }
    const p = listing.price;
    if (minPrice != null && minPrice !== "" && p != null && Number(p) < Number(minPrice)) {
      return false;
    }
    if (maxPrice != null && maxPrice !== "" && p != null && Number(p) > Number(maxPrice)) {
      return false;
    }
    return true;
  });
}

/**
 * @param {Record<string, string>} q — same shape as req.query (path/slug/id already stripped)
 */
async function listListings(q) {
  const supabase = getSupabaseAdmin();
  const { userId, status: statusFilter } = q;

  let query = supabase.from(TABLE).select("*");

  if (userId) {
    query = query.eq("user_id", String(userId));
    if (statusFilter) {
      query = query.eq("status", String(statusFilter));
    }
  } else {
    const st = statusFilter || "approved";
    query = query.eq("status", st);
  }

  if (q.categoryId) {
    query = query.eq("category_id", String(q.categoryId));
  }

  query = query.order("created_at", { ascending: false });

  const { data, error } = await query;
  if (error) {
    throw error;
  }
  const rows = (data || []).map(mapRow);
  return applyClientFilters(rows, q);
}

async function getById(id) {
  const supabase = getSupabaseAdmin();
  const { data, error } = await supabase.from(TABLE).select("*").eq("id", id).maybeSingle();
  if (error) {
    throw error;
  }
  return data ? mapRow(data) : null;
}

async function insertListing(row) {
  const supabase = getSupabaseAdmin();
  const payload = {
    user_id: String(row.userId || "anonymous"),
    category_id: String(row.categoryId),
    title: row.title,
    description: row.description ?? "",
    price: row.price ?? null,
    currency: row.currency || "HUF",
    condition: row.condition || "other",
    location: row.location || "Hungary",
    images: Array.isArray(row.images) ? row.images : [],
    category_fields:
      row.categoryFields && typeof row.categoryFields === "object" ? row.categoryFields : {},
    status: row.status || "pending",
    featured: Boolean(row.featured),
    view_count: Number(row.viewCount) || 0
  };
  const { data, error } = await supabase.from(TABLE).insert(payload).select("*").single();
  if (error) {
    throw error;
  }
  return mapRow(data);
}

/**
 * Partial update; caller must verify ownership (same userId as stored row).
 * @param {string} id
 * @param {object} patch — camelCase fields to merge
 * @param {string} requestUserId — must match row user_id
 */
async function updateListing(id, patch, requestUserId) {
  const supabase = getSupabaseAdmin();
  const existing = await getById(id);
  if (!existing) {
    return { ok: false, status: 404, body: { error: "Listing not found" } };
  }
  if (String(existing.userId) !== String(requestUserId || "")) {
    return { ok: false, status: 403, body: { error: "Forbidden" } };
  }

  const updates = {};
  if (patch.title !== undefined) {
    updates.title = patch.title;
  }
  if (patch.description !== undefined) {
    updates.description = patch.description;
  }
  if (patch.categoryId !== undefined) {
    updates.category_id = patch.categoryId;
  }
  if (patch.price !== undefined) {
    updates.price = patch.price;
  }
  if (patch.currency !== undefined) {
    updates.currency = patch.currency;
  }
  if (patch.condition !== undefined) {
    updates.condition = patch.condition;
  }
  if (patch.location !== undefined) {
    updates.location = patch.location;
  }
  if (patch.images !== undefined) {
    updates.images = Array.isArray(patch.images) ? patch.images : [];
  }
  if (patch.categoryFields !== undefined) {
    updates.category_fields =
      patch.categoryFields && typeof patch.categoryFields === "object" ? patch.categoryFields : {};
  }
  if (patch.featured !== undefined) {
    updates.featured = Boolean(patch.featured);
  }
  if (patch.viewCount !== undefined) {
    updates.view_count = Number(patch.viewCount) || 0;
  }

  if (Object.keys(updates).length === 0) {
    return { ok: true, listing: existing };
  }

  const { data, error } = await supabase.from(TABLE).update(updates).eq("id", id).select("*").single();
  if (error) {
    throw error;
  }
  return { ok: true, listing: mapRow(data) };
}

module.exports = {
  listListings,
  getById,
  insertListing,
  updateListing,
  mapRow
};
