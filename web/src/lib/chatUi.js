import { DONATIONS_CATEGORY_ID } from "../data/donationConstants.js";
import { phoneTelHref } from "./listingContact.js";
import { formatPrice } from "../utils/format.js";

/** @param {string} iso */
export function formatInboxDateLabel(iso) {
  if (!iso) {
    return "—";
  }
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) {
    return "—";
  }
  const now = new Date();
  const opts = { month: "short", day: "numeric" };
  if (d.getFullYear() !== now.getFullYear()) {
    opts.year = "numeric";
  }
  return d.toLocaleDateString(undefined, opts);
}

/** @param {string} iso */
export function formatChatDateSeparator(iso) {
  if (!iso) {
    return "";
  }
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) {
    return "";
  }
  const label = d.toLocaleDateString(undefined, {
    month: "long",
    day: "numeric",
    year: "numeric"
  });
  return label;
}

/** @param {string} iso */
function dateKey(iso) {
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) {
    return "";
  }
  return `${d.getFullYear()}-${d.getMonth()}-${d.getDate()}`;
}

const esc = (s) => {
  const d = document.createElement("div");
  d.textContent = s ?? "";
  return d.innerHTML;
};

const IMAGE_BODY_RE = /^\[\[image:(https?:\/\/[^\]]+)\]\](?:\n?([\s\S]*))?$/;

/**
 * @param {string} escapedHtml — already HTML-escaped plain text
 */
export function linkifyPhonesInEscapedHtml(escapedHtml) {
  return String(escapedHtml || "").replace(/(\+?\d[\d\s().\-]{6,}\d)/g, (match) => {
    const href = phoneTelHref(match);
    if (!href) {
      return match;
    }
    return `<a href="${esc(href)}" class="chat-bubble__phone" data-chat-phone>${match}</a>`;
  });
}

/**
 * @param {string} raw
 */
export function formatMessageBodyHtml(raw) {
  const text = String(raw || "");
  const imgMatch = text.match(IMAGE_BODY_RE);
  if (imgMatch) {
    const url = imgMatch[1];
    const rest = imgMatch[2]?.trim();
    let html = `<img class="chat-bubble__img" src="${esc(url)}" alt="" loading="lazy" width="220" height="220" />`;
    if (rest) {
      html += `<p class="chat-bubble__text">${linkifyPhonesInEscapedHtml(esc(rest))}</p>`;
    }
    return html;
  }
  return `<p class="chat-bubble__text">${linkifyPhonesInEscapedHtml(esc(text))}</p>`;
}

/** @param {object} listing */
export function isListingClosedForChat(listing) {
  if (!listing) {
    return false;
  }
  const status = String(listing.status || "approved").toLowerCase();
  if (status !== "approved") {
    return true;
  }
  if (listing.expiresAt) {
    const exp = new Date(listing.expiresAt);
    if (!Number.isNaN(exp.getTime()) && exp < new Date()) {
      return true;
    }
  }
  return false;
}

/** @param {object} listing */
export function formatListingPriceLabel(listing, contactPriceLabel) {
  if (!listing) {
    return contactPriceLabel;
  }
  if (listing.categoryId === DONATIONS_CATEGORY_ID) {
    return "Free";
  }
  const p = listing.price;
  if (p == null) {
    return contactPriceLabel;
  }
  const n = Number(p);
  if (!Number.isFinite(n) || n < 0) {
    return contactPriceLabel;
  }
  return formatPrice(n);
}

/**
 * @param {Array<{ created_at?: string }>} messages
 * @param {(m: object) => string} bubbleHtmlFn
 */
export function interleaveChatDateSeparators(messages, bubbleHtmlFn) {
  let lastKey = "";
  let html = "";
  for (const m of messages || []) {
    const key = dateKey(m.created_at);
    if (key && key !== lastKey) {
      const label = formatChatDateSeparator(m.created_at);
      if (label) {
        html += `<div class="chat-date-sep" role="separator"><span>${esc(label)}</span></div>`;
      }
      lastKey = key;
    }
    html += bubbleHtmlFn(m);
  }
  return html;
}

export const CHAT_IMAGE_PREFIX = "[[image:";
export const CHAT_IMAGE_SUFFIX = "]]";

/** @param {string} imageUrl @param {string} [caption] */
export function buildImageMessageBody(imageUrl, caption = "") {
  const cap = String(caption || "").trim();
  if (cap) {
    return `${CHAT_IMAGE_PREFIX}${imageUrl}${CHAT_IMAGE_SUFFIX}\n${cap}`;
  }
  return `${CHAT_IMAGE_PREFIX}${imageUrl}${CHAT_IMAGE_SUFFIX}`;
}

export const QUICK_REPLY_KEYS = [
  "chat.quick.last_price",
  "chat.quick.available",
  "chat.quick.location",
  "chat.quick.offer"
];

export const CHAT_EMOJIS = ["😀", "😊", "👍", "🙏", "📍", "💰", "✅", "❓", "📞", "🚗", "🏠", "📦"];
