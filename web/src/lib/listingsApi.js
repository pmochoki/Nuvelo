import { supabase } from "./supabase.js";

/** Escape % and _ for PostgREST ilike patterns */
function escapeIlike(s) {
  return String(s).replace(/\\/g, "\\\\").replace(/%/g, "\\%").replace(/_/g, "\\_");
}

export function normalizeListingRow(row) {
  if (!row) {
    return null;
  }
  const prof = row.profiles || {};
  return {
    id: row.id,
    userId: row.user_id,
    categoryId: row.category,
    title: row.title,
    description: row.description,
    price: row.price != null ? Number(row.price) : null,
    currency: row.currency || "HUF",
    condition: row.condition,
    location: row.location,
    images: Array.isArray(row.images) ? row.images : [],
    categoryFields: row.category_fields && typeof row.category_fields === "object" ? row.category_fields : {},
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    featured: Boolean(row.is_featured),
    isFeatured: Boolean(row.is_featured),
    viewCount: Number(row.view_count) || 0,
    views: Number(row.view_count) || 0,
    sellerName: prof.display_name || "Seller",
    sellerVerified: false,
    enterprise: false
  };
}

export async function fetchListingsFromSupabase(params = {}) {
  let query = supabase
    .from("listings")
    .select(
      `
        *,
        profiles (display_name, avatar_url, role, phone)
      `
    )
    .eq("is_active", true)
    .order("created_at", { ascending: false });

  const { query: keyword, categoryId, location, minPrice, maxPrice } = params;

  if (categoryId) {
    query = query.eq("category", categoryId);
  }
  const loc = String(location || "").trim();
  if (loc) {
    query = query.ilike("location", `%${escapeIlike(loc)}%`);
  }
  const kw = String(keyword || "").trim();
  if (kw) {
    const k = escapeIlike(kw);
    query = query.or(`title.ilike.%${k}%,description.ilike.%${k}%`);
  }
  if (minPrice != null && minPrice !== "" && !Number.isNaN(Number(minPrice))) {
    query = query.gte("price", Number(minPrice));
  }
  if (maxPrice != null && maxPrice !== "" && !Number.isNaN(Number(maxPrice))) {
    query = query.lte("price", Number(maxPrice));
  }

  const { data, error } = await query;
  if (error) {
    throw error;
  }
  return (data || []).map(normalizeListingRow);
}

export async function fetchListingFromSupabase(id) {
  const { data, error } = await supabase
    .from("listings")
    .select(
      `
        *,
        profiles (display_name, avatar_url, role, phone)
      `
    )
    .eq("id", id)
    .eq("is_active", true)
    .maybeSingle();

  if (error) {
    throw error;
  }
  if (!data) {
    return null;
  }
  return normalizeListingRow(data);
}

export async function createListingInSupabase(formPayload, userId) {
  const rawCond = String(formPayload.condition || "other");
  const cond =
    rawCond === "new" ? "new" : rawCond === "used" ? "used" : rawCond === "good" ? "other" : "other";
  const images = (formPayload.images || []).filter((u) => typeof u === "string" && /^https?:\/\//i.test(u));
  const row = {
    user_id: userId,
    title: formPayload.title,
    description: formPayload.description,
    category: formPayload.categoryId,
    price: formPayload.price,
    currency: formPayload.currency || "HUF",
    condition: cond,
    location: formPayload.location,
    images,
    category_fields: formPayload.categoryFields || {},
    is_active: true,
    is_featured: false
  };
  const { data, error } = await supabase.from("listings").insert(row).select().single();
  if (error) {
    throw error;
  }
  return normalizeListingRow(data);
}
