/**
 * Fill missing or English-identical German strings from translations.en via MyMemory.
 * Run: node scripts/patch-de-locale.mjs
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { translations } from "../web/src/i18n/translations.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const dePath = path.join(__dirname, "../web/src/i18n/de.js");
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

function shouldSkipTranslation(value) {
  if (!value || typeof value !== "string") return true;
  if (/^https?:\/\//.test(value)) return true;
  if (/^[A-Z0-9_]+$/.test(value)) return true;
  if (!/[a-zA-Z]/.test(value)) return true;
  return false;
}

async function translateEnToDe(text) {
  const q = encodeURIComponent(String(text).slice(0, 500));
  const url = `https://api.mymemory.translated.net/get?q=${q}&langpair=en|de`;
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  const data = await res.json();
  return String(data?.responseData?.translatedText || text).trim() || text;
}

const en = translations.en;
const deModule = await import(`../web/src/i18n/de.js?t=${Date.now()}`);
const de = { ...deModule.de };

/** Manual overrides where MT returns English cognates. */
const OVERRIDES = {
  "nav.home": "Startseite",
  "nav.messages": "Nachrichten",
  "auth.email": "E-Mail",
  "profile.messages": "Nachrichten",
  "profile.feedback": "Bewertungen",
  "messages.spam": "Spam",
  "settings.email": "E-Mail",
  "footer.support": "Support",
  "theme.system": "System",
  "header.close": "Schließen",
  "drawer.theme_hint": "Design",
  "mobile.tab.messages": "Nachrichten",
  "breadcrumb.label": "Brotkrumen-Navigation",
  "listing.verified_badge": "Verifiziert",
  "home.pill.trending": "Trends",
  "perf.metric.chats": "Chats",
  "messages.spam_count": "Spam ({n})",
  "messages.visually_hidden": "Nachrichten",
  "feedback.title": "Bewertungen",
  "profile.hub_feedback": "Bewertungen",
  "profile.tab.home": "Startseite",
  "breadcrumb.detail_label": "Brotkrumen-Navigation",
  "detail.field.collection": "Abholung / Lieferung",
  "detail.details_title": "Details",
  "locale.de": "Deutsch",
  "nav.sell": "VERKAUFEN",
  "nav.signout": "Abmelden",
  "nav.register": "Registrieren",
  "listing.free": "KOSTENLOS",
  "listing.enterprise": "UNTERNEHMEN",
  "listing.pill_featured": "EMPFOHLEN",
  "listing.pill_urgent": "DRINGEND",
  "listing.pill_popular": "BELIEBT",
  "loc.modal.popular": "BELIEBT"
};

const entries = Object.entries(en);
let patched = 0;

for (let i = 0; i < entries.length; i++) {
  const [key, value] = entries[i];
  if (OVERRIDES[key]) {
    if (de[key] !== OVERRIDES[key]) {
      de[key] = OVERRIDES[key];
      patched++;
    }
    continue;
  }
  const needs =
    de[key] == null || (de[key] === value && !shouldSkipTranslation(value));
  if (!needs) continue;
  if (shouldSkipTranslation(value)) {
    de[key] = value;
    continue;
  }
  try {
    de[key] = await translateEnToDe(value);
    patched++;
  } catch (err) {
    console.warn("fallback", key, err.message);
    de[key] = value;
  }
  await sleep(220);
  if (i % 20 === 0) console.log(`${i + 1}/${entries.length}`);
}

const header = `/** German UI strings — synced from English (MyMemory + manual overrides). */\nexport const de = `;
fs.writeFileSync(dePath, `${header}${JSON.stringify(de, null, 2)};\n`, "utf8");
console.log("Patched", patched, "keys. Total", Object.keys(de).length);
