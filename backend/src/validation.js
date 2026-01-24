const bannedWords = ["scam", "fake", "fraud"];

const hasBannedWords = (text) => {
  if (!text) {
    return false;
  }
  const lowered = text.toLowerCase();
  return bannedWords.some((word) => lowered.includes(word));
};

const validateCategoryFields = (categoryId, fields = {}) => {
  const errors = [];
  if (!categoryId) {
    return errors;
  }
  if (categoryId === "vehicles") {
    if (!fields.make || !fields.model || !fields.year) {
      errors.push("Vehicles require make, model, and year.");
    }
  }
  if (categoryId === "real-estate" || categoryId === "rentals") {
    if (!fields.type || !fields.bedrooms || !fields.bathrooms || !fields.area) {
      errors.push("Real estate requires type, bedrooms, bathrooms, and area.");
    }
  }
  if (categoryId === "electronics") {
    if (!fields.brand || !fields.model) {
      errors.push("Electronics require brand and model.");
    }
  }
  if (categoryId === "jobs") {
    if (!fields.role || !fields.contractType) {
      errors.push("Jobs require role and contract type.");
    }
  }
  if (categoryId === "services") {
    if (!fields.serviceType) {
      errors.push("Services require service type.");
    }
  }
  return errors;
};

const validateListing = (listing) => {
  const errors = [];
  if (!listing.title || listing.title.length < 5) {
    errors.push("Title must be at least 5 characters.");
  }
  if (!listing.description || listing.description.length < 20) {
    errors.push("Description must be at least 20 characters.");
  }
  if (!listing.categoryId) {
    errors.push("Category is required.");
  }
  if (Array.isArray(listing.images) && listing.images.length > 8) {
    errors.push("Maximum 8 images allowed.");
  }
  if (hasBannedWords(listing.title) || hasBannedWords(listing.description)) {
    errors.push("Listing contains banned words.");
  }
  errors.push(
    ...validateCategoryFields(listing.categoryId, listing.categoryFields)
  );
  return errors;
};

module.exports = { validateListing, hasBannedWords };
