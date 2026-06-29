import { getLocale } from "../i18n/i18n.js";

/** @type {Map<string, string>} */
const clientCache = new Map();

/** Locales that auto-translate incoming inbox messages. */
export function inboxTranslationTarget() {
  const loc = getLocale();
  return loc === "hu" || loc === "de" ? loc : null;
}

/**
 * @param {string} text
 * @param {"hu"|"de"} target
 */
function cacheKey(text, target) {
  return `${target}:${text}`;
}

/**
 * @param {string[]} texts
 * @param {"hu"|"de"} target
 * @returns {Promise<string[]>}
 */
export async function translateMessageTexts(texts, target) {
  if (!target || target === "en" || !Array.isArray(texts) || texts.length === 0) {
    return texts;
  }

  const results = [...texts];
  const pending = [];

  texts.forEach((raw, index) => {
    const text = String(raw ?? "");
    const trimmed = text.trim();
    if (!trimmed) {
      results[index] = text;
      return;
    }
    const hit = clientCache.get(cacheKey(trimmed, target));
    if (hit) {
      results[index] = hit;
      return;
    }
    pending.push({ index, text: trimmed });
  });

  if (pending.length === 0) {
    return results;
  }

  try {
    const res = await fetch("/api/translate", {
      method: "POST",
      headers: { "Content-Type": "application/json", Accept: "application/json" },
      body: JSON.stringify({
        target,
        texts: pending.map((p) => p.text)
      })
    });
    if (!res.ok) {
      return texts;
    }
    const data = await res.json();
    const translated = Array.isArray(data.translations) ? data.translations : [];
    pending.forEach((item, i) => {
      const out = String(translated[i] ?? item.text);
      clientCache.set(cacheKey(item.text, target), out);
      results[item.index] = out;
    });
  } catch (err) {
    console.warn("[Nuvelo] message translate failed", err);
    return texts;
  }

  return results;
}

/**
 * Apply displayBody on incoming messages only (not sent by current user).
 * @param {Array<{ sender_id: string, body: string }>} messages
 * @param {string} currentUserId
 * @returns {Promise<Array<object>>}
 */
export async function withTranslatedIncomingMessages(messages, currentUserId) {
  const target = inboxTranslationTarget();
  if (!target || !messages?.length) {
    return messages;
  }

  const incoming = messages.filter((m) => m.sender_id !== currentUserId && m.body?.trim());
  if (incoming.length === 0) {
    return messages;
  }

  const translated = await translateMessageTexts(
    incoming.map((m) => m.body),
    target
  );
  const byBody = new Map(incoming.map((m, i) => [m, translated[i]]));
  return messages.map((m) => {
    if (m.sender_id === currentUserId || !m.body?.trim()) {
      return m;
    }
    const displayBody = byBody.get(m) ?? m.body;
    return displayBody !== m.body ? { ...m, displayBody } : m;
  });
}

/**
 * @param {string} preview
 * @returns {Promise<string>}
 */
export async function translateInboxPreview(preview) {
  const target = inboxTranslationTarget();
  if (!target || !preview?.trim()) {
    return preview;
  }
  const [out] = await translateMessageTexts([preview], target);
  return out ?? preview;
}
