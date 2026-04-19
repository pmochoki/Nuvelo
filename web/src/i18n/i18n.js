import { translations } from "./translations.js";

export const LOCALE_STORAGE_KEY = "nuvelo_locale";

const SUPPORTED = new Set(["en", "hu"]);

/**
 * @returns {"en" | "hu"}
 */
export function getLocale() {
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
 * @param {"en" | "hu"} locale
 */
export function setLocale(locale) {
  const loc = SUPPORTED.has(locale) ? locale : "en";
  try {
    localStorage.setItem(LOCALE_STORAGE_KEY, loc);
  } catch {
    /* ignore */
  }
  if (typeof document !== "undefined") {
    document.documentElement.lang = loc;
    applyDomTranslations(document);
    document.querySelectorAll("[data-locale-select]").forEach((el) => {
      if (el instanceof HTMLSelectElement) {
        el.value = loc;
      }
    });
    syncLangToggleButtons();
    window.dispatchEvent(new CustomEvent("nuvelo:locale", { detail: { locale: loc } }));
  }
}

/** Highlight EN/HU toggle buttons to match stored locale (see [data-lang-toggle]). */
export function syncLangToggleButtons() {
  if (typeof document === "undefined") {
    return;
  }
  const loc = getLocale();
  document.querySelectorAll("[data-lang-toggle]").forEach((btn) => {
    const v = btn.getAttribute("data-lang-toggle");
    const active = v === loc;
    btn.classList.toggle("is-active", active);
    btn.setAttribute("aria-pressed", active ? "true" : "false");
  });
}

function bindLangToggleButtons() {
  document.querySelectorAll("[data-lang-toggle]").forEach((btn) => {
    if (btn.dataset.langToggleBound === "1") {
      return;
    }
    btn.dataset.langToggleBound = "1";
    btn.addEventListener("click", () => {
      const v = btn.getAttribute("data-lang-toggle");
      setLocale(v === "hu" ? "hu" : "en");
    });
  });
}

/**
 * @param {string} key
 * @returns {string}
 */
export function t(key) {
  const loc = getLocale();
  const bucket = translations[loc] || translations.en;
  const fb = translations.en;
  if (bucket && Object.prototype.hasOwnProperty.call(bucket, key)) {
    return bucket[key];
  }
  if (fb && Object.prototype.hasOwnProperty.call(fb, key)) {
    return fb[key];
  }
  return key;
}

/**
 * Replace `{name}` placeholders in a translated string.
 * @param {string} key
 * @param {Record<string, string | number>} [vars]
 */
export function tf(key, vars = {}) {
  let s = t(key);
  for (const [k, v] of Object.entries(vars)) {
    s = s.replaceAll(`{${k}}`, String(v));
  }
  return s;
}

/**
 * Apply data-i18n*, data-locale-option (theme) to the DOM tree.
 * @param {ParentNode} [root]
 */
export function applyDomTranslations(root = document) {
  root.querySelectorAll("[data-i18n]").forEach((el) => {
    const key = el.getAttribute("data-i18n");
    if (!key) {
      return;
    }
    const attrName = el.getAttribute("data-i18n-attr");
    if (attrName) {
      el.setAttribute(attrName, t(key));
    } else {
      el.textContent = t(key);
    }
  });
  root.querySelectorAll("[data-i18n-placeholder]").forEach((el) => {
    const key = el.getAttribute("data-i18n-placeholder");
    if (key && "placeholder" in el) {
      el.placeholder = t(key);
    }
  });
  root.querySelectorAll("[data-i18n-aria-label]").forEach((el) => {
    const key = el.getAttribute("data-i18n-aria-label");
    if (key) {
      el.setAttribute("aria-label", t(key));
    }
  });
  root.querySelectorAll("[data-i18n-title]").forEach((el) => {
    const key = el.getAttribute("data-i18n-title");
    if (key) {
      el.setAttribute("title", t(key));
    }
  });
  root.querySelectorAll("option[data-i18n]").forEach((el) => {
    const key = el.getAttribute("data-i18n");
    if (key) {
      el.textContent = t(key);
    }
  });
}

/**
 * Sync html[lang], translate static DOM, bind locale &lt;select&gt;s.
 */
export function initI18n() {
  const loc = getLocale();
  document.documentElement.lang = loc;
  applyDomTranslations(document);
  bindLangToggleButtons();
  syncLangToggleButtons();
  document.querySelectorAll("[data-locale-select]").forEach((sel) => {
    if (!(sel instanceof HTMLSelectElement)) {
      return;
    }
    sel.value = loc;
    if (sel.dataset.localeBound === "1") {
      return;
    }
    sel.dataset.localeBound = "1";
    sel.addEventListener("change", () => {
      const v = sel.value === "hu" ? "hu" : "en";
      setLocale(v);
    });
  });
  if (typeof window !== "undefined") {
    window.getLang = () => getLocale();
    window.setLang = (/** @type {string} */ lang) => setLocale(lang === "hu" ? "hu" : "en");
  }
}
