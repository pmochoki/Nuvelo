/** Contact fields stored in listing.categoryFields and mirrored on normalized rows. */

export const CONTACT_PREFS = {
  message: "message via app",
  email: "show email",
  phone: "show phone"
};

export function normalizeContactPhone(raw) {
  const s = String(raw || "").trim();
  if (!s) {
    return "";
  }
  const digits = s.replace(/[^\d+]/g, "");
  if (!digits) {
    return "";
  }
  return digits.startsWith("+") ? digits : `+${digits.replace(/^\+/, "")}`;
}

export function phoneTelHref(phone) {
  const n = normalizeContactPhone(phone);
  return n ? `tel:${n}` : "";
}

export function buildContactFieldsFromForm(fd, user = {}) {
  const contactName = String(fd.get("contactName") || user?.name || "").trim();
  const contactPhone = normalizeContactPhone(fd.get("contactPhone") || user?.phone || "");
  const contactEmail = String(fd.get("contactEmail") || user?.email || "").trim();
  const contactPreference = String(
    fd.get("listingContact") || fd.get("donationContact") || fd.get("eventContact") || CONTACT_PREFS.message
  ).trim();
  const out = { contactPreference };
  if (contactName) {
    out.contactName = contactName;
  }
  if (contactPhone) {
    out.contactPhone = contactPhone;
  }
  if (contactEmail) {
    out.contactEmail = contactEmail;
  }
  return out;
}

export function extractListingContact(listing) {
  const cf = listing?.categoryFields && typeof listing.categoryFields === "object" ? listing.categoryFields : {};
  const contactName =
    String(listing?.sellerName || cf.contactName || "").trim() || "Seller";
  const contactPhone = normalizeContactPhone(
    listing?.sellerPhone || cf.contactPhone || cf.phone || ""
  );
  const contactEmail = String(listing?.sellerEmail || cf.contactEmail || cf.email || "").trim();
  const contactPreference = String(
    listing?.contactPreference || cf.contactPreference || CONTACT_PREFS.message
  ).trim();
  return { contactName, contactPhone, contactEmail, contactPreference };
}

export function contactVisibleForPreference(pref, kind) {
  const p = String(pref || CONTACT_PREFS.message).toLowerCase();
  if (kind === "phone") {
    return p.includes("phone");
  }
  if (kind === "email") {
    return p.includes("email");
  }
  return true;
}

export function enrichListingContact(listing) {
  if (!listing) {
    return listing;
  }
  const c = extractListingContact(listing);
  return {
    ...listing,
    sellerName: c.contactName || listing.sellerName || "Seller",
    sellerPhone: c.contactPhone || undefined,
    sellerEmail: c.contactEmail || undefined,
    contactPreference: c.contactPreference
  };
}
