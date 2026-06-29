const { applyCors } = require("./_cors");
const { readJsonBody } = require("./_readJsonBody");

/** In-memory cache for repeated phrases (per serverless instance). */
const cache = new Map();
const TARGETS = new Set(["hu", "de"]);
const MAX_TEXTS = 40;
const MAX_TEXT_LEN = 2000;

/**
 * POST /api/translate — translate user message text for inbox display.
 * Body: { target: "hu"|"de", texts: string[] }
 * Response: { translations: string[] }
 */
module.exports = async (req, res) => {
  applyCors(req, res);
  if (req.method === "OPTIONS") {
    res.statusCode = 204;
    return res.end();
  }
  if (req.method !== "POST") {
    res.statusCode = 405;
    res.setHeader("Content-Type", "application/json");
    return res.end(JSON.stringify({ error: "Method not allowed" }));
  }

  let body = {};
  try {
    body = (await readJsonBody(req)) || {};
  } catch {
    res.statusCode = 400;
    res.setHeader("Content-Type", "application/json");
    return res.end(JSON.stringify({ error: "Invalid JSON body" }));
  }

  const target = String(body.target || "").toLowerCase();
  const texts = Array.isArray(body.texts) ? body.texts : null;
  if (!TARGETS.has(target) || !texts) {
    res.statusCode = 400;
    res.setHeader("Content-Type", "application/json");
    return res.end(JSON.stringify({ error: "target must be hu or de; texts must be an array" }));
  }
  if (texts.length > MAX_TEXTS) {
    res.statusCode = 400;
    res.setHeader("Content-Type", "application/json");
    return res.end(JSON.stringify({ error: `At most ${MAX_TEXTS} texts per request` }));
  }

  try {
    const translations = await Promise.all(
      texts.map((raw) => translateText(String(raw ?? ""), target))
    );
    res.statusCode = 200;
    res.setHeader("Content-Type", "application/json");
    return res.end(JSON.stringify({ translations }));
  } catch (err) {
    console.error("[Nuvelo] /api/translate", err);
    res.statusCode = 502;
    res.setHeader("Content-Type", "application/json");
    return res.end(JSON.stringify({ error: "Translation unavailable" }));
  }
};

/**
 * @param {string} text
 * @param {"hu"|"de"} target
 */
async function translateText(text, target) {
  const trimmed = text.trim();
  if (!trimmed) {
    return text;
  }
  if (trimmed.length > MAX_TEXT_LEN) {
    return text;
  }

  const cacheKey = `${target}\0${trimmed}`;
  if (cache.has(cacheKey)) {
    return cache.get(cacheKey);
  }

  const q = encodeURIComponent(trimmed.slice(0, 500));
  const url = `https://api.mymemory.translated.net/get?q=${q}&langpair=|${target}`;
  const response = await fetch(url, {
    headers: { Accept: "application/json" }
  });
  if (!response.ok) {
    throw new Error(`upstream ${response.status}`);
  }
  const data = await response.json();
  const translated = String(data?.responseData?.translatedText || trimmed).trim();
  const out = translated && translated.toUpperCase() !== trimmed.toUpperCase() ? translated : trimmed;
  cache.set(cacheKey, out);
  return out;
}
