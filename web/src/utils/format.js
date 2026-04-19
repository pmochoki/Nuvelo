import { LOCALE_STORAGE_KEY } from "../i18n/constants.js";

/**
 * @returns {"en" | "hu"}
 */
export function getLang() {
  try {
    const s = localStorage.getItem(LOCALE_STORAGE_KEY);
    if (s === "hu" || s === "en") {
      return s;
    }
  } catch {
    /* ignore */
  }
  return "en";
}

/**
 * Format a number with thousands separators
 * EN: 1,000,000
 * HU: 1 000 000
 * @param {number|string|null|undefined} value
 */
export function formatNumber(value) {
  if (value === null || value === undefined || value === "") {
    return "";
  }
  const num = Number(value);
  if (Number.isNaN(num)) {
    return String(value);
  }
  const lang = getLang();
  if (lang === "hu") {
    return new Intl.NumberFormat("hu-HU", { maximumFractionDigits: 0 }).format(num);
  }
  return new Intl.NumberFormat("en-US", { maximumFractionDigits: 0 }).format(num);
}

/**
 * Format a price with currency
 * EN: 100,000 HUF
 * HU: 100 000 Ft
 * @param {number|string|null|undefined} value
 * @param {string} [currency]
 */
export function formatPrice(value, currency = "HUF") {
  if (value === null || value === undefined || value === "") {
    return "";
  }
  const num = Number(value);
  if (Number.isNaN(num)) {
    return String(value);
  }
  const lang = getLang();
  if (String(currency || "HUF").trim().toUpperCase() !== "HUF") {
    return `${formatNumber(num)} ${String(currency).trim().toUpperCase()}`;
  }
  if (lang === "hu") {
    return new Intl.NumberFormat("hu-HU", {
      style: "currency",
      currency: "HUF",
      maximumFractionDigits: 0
    }).format(num);
  }
  return `${new Intl.NumberFormat("en-US", { maximumFractionDigits: 0 }).format(num)} HUF`;
}

/**
 * @param {number|string|null|undefined} amount
 * @param {string} [currency]
 */
export function formatMoneyAmount(amount, currency = "HUF") {
  const u = String(currency || "HUF").trim().toUpperCase();
  if (u === "HUF") {
    return formatPrice(amount, "HUF");
  }
  if (amount === null || amount === undefined || amount === "") {
    return "";
  }
  const num = Number(amount);
  if (!Number.isFinite(num)) {
    return String(amount);
  }
  return `${formatNumber(Math.round(num))} ${u}`;
}

/**
 * Format a compact number for stats
 * 1500 → "1.5K"   142000 → "142K"   1200000 → "1.2M"
 * @param {number|string} value
 */
export function formatCompact(value) {
  if (value === null || value === undefined || value === "" || value === 0) {
    return "0";
  }
  const num = Number(value);
  if (Number.isNaN(num)) {
    return String(value);
  }
  if (num >= 1_000_000) {
    return (num / 1_000_000).toFixed(1) + "M";
  }
  if (num >= 1_000) {
    return (num / 1_000).toFixed(1) + "K";
  }
  return String(num);
}

/**
 * After locale switch: update every `[data-price]` node (raw amount in attribute).
 * Optional `data-currency` (default HUF) — uses {@link formatMoneyAmount}.
 */
export function refreshPriceElements(root = document) {
  root.querySelectorAll("[data-price]").forEach((el) => {
    const raw = el.getAttribute("data-price");
    if (raw === null || raw === "") {
      return;
    }
    const currency = el.getAttribute("data-currency") || "HUF";
    const formatted = formatMoneyAmount(raw, currency);
    if (formatted !== "") {
      el.textContent = formatted;
    }
  });
}
