/** @typedef {"light" | "dark" | "system"} ThemePreference */

export const THEME_STORAGE_KEY = "nuvelo_theme";

/** @returns {ThemePreference} */
export function getStoredThemePreference() {
  try {
    const v = localStorage.getItem(THEME_STORAGE_KEY);
    if (v === "light" || v === "dark" || v === "system") {
      return v;
    }
  } catch {
    /* ignore */
  }
  return "system";
}

/** @returns {"light" | "dark"} */
export function getResolvedColorScheme() {
  const pref = getStoredThemePreference();
  if (pref === "dark") {
    return "dark";
  }
  if (pref === "light") {
    return "light";
  }
  return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
}

function setMetaThemeColor(scheme) {
  const meta = document.querySelector('meta[name="theme-color"]');
  if (!meta) {
    return;
  }
  meta.setAttribute("content", scheme === "dark" ? "#0d0a1e" : "#f3f0fa");
}

function syncThemeSelects(pref) {
  document.querySelectorAll("[data-theme-select]").forEach((el) => {
    if (el instanceof HTMLSelectElement) {
      el.value = pref;
    }
  });
}

/** Apply preference and persist. Updates `data-theme-pref` + `data-color-scheme` on `<html>`. */
export function applyTheme(preference) {
  const pref =
    preference === "light" || preference === "dark" || preference === "system" ? preference : "system";
  try {
    localStorage.setItem(THEME_STORAGE_KEY, pref);
  } catch {
    /* ignore */
  }
  document.documentElement.setAttribute("data-theme-pref", pref);
  const resolved =
    pref === "dark"
      ? "dark"
      : pref === "light"
        ? "light"
        : window.matchMedia("(prefers-color-scheme: dark)").matches
          ? "dark"
          : "light";
  document.documentElement.setAttribute("data-color-scheme", resolved);
  setMetaThemeColor(resolved);
  syncThemeSelects(pref);
}

let mediaMql = null;
/** @param {() => void} handler */
function onSystemSchemeChange(handler) {
  if (mediaMql) {
    mediaMql.removeEventListener("change", handler);
  }
  mediaMql = window.matchMedia("(prefers-color-scheme: dark)");
  mediaMql.addEventListener("change", handler);
}

/** Wire selects + system preference changes. Safe to call once on load. */
export function initTheme() {
  if (typeof document === "undefined") {
    return;
  }
  if (document.documentElement.dataset.nuveloThemeInit === "1") {
    return;
  }
  document.documentElement.dataset.nuveloThemeInit = "1";

  const pref = getStoredThemePreference();
  applyTheme(pref);

  document.querySelectorAll("[data-theme-select]").forEach((el) => {
    if (!(el instanceof HTMLSelectElement)) {
      return;
    }
    el.value = pref;
    el.addEventListener("change", () => {
      applyTheme(el.value);
    });
  });

  const reloadIfSystem = () => {
    if (getStoredThemePreference() === "system") {
      applyTheme("system");
    }
  };
  onSystemSchemeChange(reloadIfSystem);
}
