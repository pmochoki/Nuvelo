/** Donations marketplace — free giveaways only (categoryId: donations). */

export const DONATIONS_CATEGORY_ID = "donations";

export const DONATION_SUBCATEGORIES = [
  { key: "food", label: "🍎 Food & Groceries" },
  { key: "clothing", label: "👕 Clothing & Shoes" },
  { key: "bikes", label: "🚲 Bikes & Transport" },
  { key: "household", label: "🏠 Household Items" },
  { key: "books", label: "📚 Books & Education" },
  { key: "toys", label: "🧸 Toys & Kids Items" },
  { key: "furniture", label: "🛋️ Furniture" },
  { key: "garden", label: "🌱 Garden & Outdoor" },
  { key: "other", label: "🎲 Other Donations" }
];

/** Stored in categoryFields.donationCondition */
export const DONATION_CONDITIONS = [
  { key: "new", label: "New" },
  { key: "like_new", label: "Like New" },
  { key: "good", label: "Good" },
  { key: "worn", label: "Worn but usable" }
];

/** Stored in categoryFields.collectionMethod */
export const DONATION_COLLECTION_METHODS = [
  { key: "pickup", label: "Pickup only (donor's address or agreed meeting point)", short: "Pickup", icon: "📍" },
  {
    key: "local_delivery",
    label: "Can deliver locally (within distance)",
    short: "Local delivery",
    icon: "🚗"
  },
  { key: "post", label: "Post / courier (donor can ship)", short: "Post", icon: "📦" }
];

export function donationSubCategoryLabel(key) {
  const row = DONATION_SUBCATEGORIES.find((s) => s.key === key);
  return row ? row.label : key || "";
}

export function donationConditionLabel(key) {
  const row = DONATION_CONDITIONS.find((s) => s.key === key);
  return row ? row.label : key || "";
}

export function donationCollectionMeta(key) {
  return DONATION_COLLECTION_METHODS.find((m) => m.key === key) || DONATION_COLLECTION_METHODS[0];
}
