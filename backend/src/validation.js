const bannedWords = ["scam", "fake", "fraud"];
const MIN_TITLE_LENGTH = 5;
const MIN_DESCRIPTION_LENGTH = 20;
const MAX_IMAGE_COUNT = 8;

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
  if (!listing.title || listing.title.length < MIN_TITLE_LENGTH) {
    errors.push(`Title must be at least ${MIN_TITLE_LENGTH} characters.`);
  }
  if (!listing.description || listing.description.length < MIN_DESCRIPTION_LENGTH) {
    errors.push(
      `Description must be at least ${MIN_DESCRIPTION_LENGTH} characters.`
    );
  }
  if (!listing.categoryId) {
    errors.push("Category is required.");
  }
  if (!Array.isArray(listing.images) || listing.images.length === 0) {
    errors.push("At least one image is required.");
  } else if (listing.images.length > MAX_IMAGE_COUNT) {
    errors.push(`Maximum ${MAX_IMAGE_COUNT} images allowed.`);
  } else if (
    listing.images.some((image) => typeof image !== "string" || image === "")
  ) {
    errors.push("Images must be non-empty strings.");
  }
  if (hasBannedWords(listing.title) || hasBannedWords(listing.description)) {
    errors.push("Listing contains banned words.");
  }
  const p = listing.price;
  if (p != null && p !== "") {
    const n = Number(p);
    if (!Number.isFinite(n) || n < 0) {
      errors.push("Price must be empty or a non-negative number.");
    }
  }
  errors.push(
    ...validateCategoryFields(listing.categoryId, listing.categoryFields)
  );
  return errors;
};

const validateMessage = (text) => {
  const errors = [];
  if (!text || text.trim().length === 0) {
    errors.push("Message text is required.");
  }
  if (hasBannedWords(text)) {
    errors.push("Message contains banned words.");
  }
  return errors;
};

module.exports = { validateListing, validateMessage, hasBannedWords };
