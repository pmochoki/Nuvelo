/**
 * One-off: generate web/src/i18n/de.js from English UI strings via MyMemory.
 * Run: node scripts/generate-de-locale.mjs
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { translations } from "../web/src/i18n/translations.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const outPath = path.join(__dirname, "../web/src/i18n/de.js");
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

/** Preserve placeholders like {n}, {name}, HTML entities in URLs. */
function shouldSkipTranslation(value) {
  if (!value || typeof value !== "string") {
    return true;
  }
  if (/^https?:\/\//.test(value)) {
    return true;
  }
  if (/^[A-Z0-9_]+$/.test(value)) {
    return true;
  }
  return false;
}

async function translateEnToDe(text) {
  const q = encodeURIComponent(String(text).slice(0, 500));
  const url = `https://api.mymemory.translated.net/get?q=${q}&langpair=en|de`;
  const res = await fetch(url);
  if (!res.ok) {
    throw new Error(`HTTP ${res.status}`);
  }
  const data = await res.json();
  return String(data?.responseData?.translatedText || text).trim() || text;
}

const en = translations.en;
const de = {};
const entries = Object.entries(en);

for (let i = 0; i < entries.length; i++) {
  const [key, value] = entries[i];
  if (shouldSkipTranslation(value) || !/[a-zA-Z]/.test(value)) {
    de[key] = value;
  } else {
    try {
      de[key] = await translateEnToDe(value);
    } catch (err) {
      console.warn("fallback", key, err.message);
      de[key] = value;
    }
    await sleep(250);
  }
  if (i % 25 === 0) {
    console.log(`${i + 1}/${entries.length} ${key}`);
  }
}

const header = `/** German UI strings — generated from English (MyMemory). */\nexport const de = `;
fs.writeFileSync(outPath, `${header}${JSON.stringify(de, null, 2)};\n`, "utf8");
console.log("Wrote", outPath, Object.keys(de).length, "keys");
