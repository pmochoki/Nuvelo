import { getLocale, tf } from "./i18n.js";

/**
 * integers with grouping: EN → 100,000 · HU → 100 000
 * @param {number|string} n
 */
export function formatInteger(n) {
  const num = Number(n);
  if (!Number.isFinite(num)) {
    return String(n);
  }
  const rounded = Math.round(num);
  const loc = getLocale();
  if (loc === "hu") {
    return new Intl.NumberFormat("hu-HU", { maximumFractionDigits: 0 }).format(rounded);
  }
  return new Intl.NumberFormat("en-US", { maximumFractionDigits: 0 }).format(rounded);
}

/**
 * Marketplace HUF line: EN → "100,000 HUF" · HU → "100 000 Ft"
 * @param {number|string} amount
 */
export function formatHufPrice(amount) {
  const num = Number(amount);
  if (!Number.isFinite(num) || num < 0) {
    return String(amount);
  }
  const rounded = Math.round(num);
  const loc = getLocale();
  const grouped = formatInteger(rounded);
  if (loc === "hu") {
    return `${grouped} Ft`;
  }
  return `${grouped} HUF`;
}

/**
 * Price when listing.currency may differ (defaults to HUF formatting).
 */
export function formatMoneyAmount(amount, currency = "HUF") {
  const u = String(currency || "HUF").trim().toUpperCase();
  if (u === "HUF") {
    return formatHufPrice(amount);
  }
  const num = Number(amount);
  if (!Number.isFinite(num)) {
    return String(amount);
  }
  return `${formatInteger(Math.round(num))} ${u}`;
}

/**
 * Like tf() but formats numeric `{n}` (and optional extra vars) with formatInteger.
 * @param {string} key
 * @param {number|string} numVal — value for `{n}`
 * @param {Record<string, string | number>} [extra]
 */
export function tfn(key, numVal, extra = {}) {
  const num = Number(numVal);
  const n =
    numVal !== null &&
    numVal !== undefined &&
    numVal !== "" &&
    Number.isFinite(num)
      ? formatInteger(Math.round(num))
      : String(numVal ?? "");
  return tf(key, { ...extra, n });
}
