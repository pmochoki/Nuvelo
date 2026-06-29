import { getAuthRedirectUrl } from "./supabaseClient.js";

const APPLE_SCRIPT =
  "https://appleid.cdn-apple.com/appleauth/static/jsapi/appleid/1/en_US/appleid.auth.js";
const DEFAULT_CLIENT_ID = "one.nuvelo.web";
export const APPLE_NONCE_KEY = "nuvelo_apple_nonce";
export const APPLE_PENDING_KEY = "nuvelo_apple_pending";

let scriptLoadPromise = null;
let callbackRegistered = false;

function loadAppleScript() {
  if (typeof window !== "undefined" && window.AppleID?.auth) {
    return Promise.resolve();
  }
  if (scriptLoadPromise) {
    return scriptLoadPromise;
  }
  scriptLoadPromise = new Promise((resolve, reject) => {
    const existing = document.querySelector(`script[src="${APPLE_SCRIPT}"]`);
    if (existing) {
      existing.addEventListener("load", () => resolve(), { once: true });
      existing.addEventListener("error", () => reject(new Error("Apple Sign In script failed to load")), {
        once: true
      });
      return;
    }
    const script = document.createElement("script");
    script.src = APPLE_SCRIPT;
    script.async = true;
    script.onload = () => resolve();
    script.onerror = () => reject(new Error("Apple Sign In script failed to load"));
    document.head.appendChild(script);
  });
  return scriptLoadPromise;
}

async function sha256Hex(value) {
  const data = new TextEncoder().encode(value);
  const hash = await crypto.subtle.digest("SHA-256", data);
  return Array.from(new Uint8Array(hash), (byte) => byte.toString(16).padStart(2, "0")).join("");
}

function randomNonce() {
  const bytes = new Uint8Array(16);
  crypto.getRandomValues(bytes);
  return Array.from(bytes, (byte) => byte.toString(16).padStart(2, "0")).join("");
}

function getAppleClientId() {
  const fromEnv = import.meta.env.VITE_APPLE_CLIENT_ID;
  return typeof fromEnv === "string" && fromEnv.trim() ? fromEnv.trim() : DEFAULT_CLIENT_ID;
}

function getSiteOrigin() {
  return (getAuthRedirectUrl() || (typeof window !== "undefined" ? window.location.origin : "")).replace(
    /\/$/,
    ""
  );
}

/** Popup / SDK flow — Apple posts back to the site root. */
function getApplePopupRedirectUri() {
  return getSiteOrigin();
}

/**
 * Mobile redirect — Apple requires form_post when scope includes name/email.
 * POST lands on our API route, which forwards id_token to the SPA via hash.
 */
export function getAppleFormPostRedirectUri() {
  return `${getSiteOrigin()}/api/auth/apple-callback`;
}

/** Mobile Safari and other touch browsers block OAuth popups — use full-page redirect instead. */
export function preferAppleRedirect() {
  if (typeof window === "undefined") {
    return false;
  }
  const ua = navigator.userAgent || "";
  const isIOS =
    /iPad|iPhone|iPod/.test(ua) || (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1);
  if (isIOS) {
    return true;
  }
  if (/Android/i.test(ua)) {
    return true;
  }
  if (window.matchMedia?.("(max-width: 767px)")?.matches) {
    return true;
  }
  if (navigator.maxTouchPoints > 0 && !window.matchMedia?.("(pointer: fine)")?.matches) {
    return true;
  }
  return false;
}

function clearApplePendingStorage() {
  try {
    localStorage.removeItem(APPLE_PENDING_KEY);
    localStorage.removeItem(APPLE_NONCE_KEY);
  } catch {
    /* ignore */
  }
}

function storeApplePendingNonce(rawNonce) {
  try {
    localStorage.setItem(APPLE_NONCE_KEY, rawNonce);
    localStorage.setItem(APPLE_PENDING_KEY, "1");
  } catch {
    /* ignore */
  }
}

function buildAppleAuthorizeUrl(hashedNonce, redirectUri) {
  const params = new URLSearchParams({
    client_id: getAppleClientId(),
    redirect_uri: redirectUri,
    response_type: "code id_token",
    response_mode: "form_post",
    scope: "name email",
    state: "nuvelo-web",
    nonce: hashedNonce
  });
  return `https://appleid.apple.com/auth/authorize?${params.toString()}`;
}

/**
 * Parse Apple mobile redirect after /api/auth/apple-callback forwards id_token in the hash.
 * @returns {{ idToken: string, nonce: string } | { error: string, errorDescription?: string } | null}
 */
export function parseAppleRedirectFromUrl() {
  if (typeof window === "undefined") {
    return null;
  }

  const query = new URLSearchParams(window.location.search || "");
  const appleError = query.get("apple_error");
  if (appleError) {
    const errorDescription = query.get("apple_error_description") || "";
    clearApplePendingStorage();
    window.history.replaceState(null, "", window.location.pathname);
    return { error: appleError, errorDescription };
  }

  const hash = new URLSearchParams((window.location.hash || "").replace(/^#/, ""));
  const idToken = hash.get("id_token");
  if (!idToken || hash.get("state") !== "nuvelo-web") {
    return null;
  }

  let rawNonce = null;
  try {
    if (localStorage.getItem(APPLE_PENDING_KEY) !== "1") {
      return null;
    }
    rawNonce = localStorage.getItem(APPLE_NONCE_KEY);
    clearApplePendingStorage();
  } catch {
    return null;
  }

  window.history.replaceState(null, "", window.location.pathname);
  return { idToken, nonce: rawNonce };
}

function isPopupBlockedError(err) {
  const code = String(err?.error || err?.message || err || "");
  return /popup|blocked/i.test(code);
}

function isUserCancelledError(err) {
  const code = String(err?.error || err?.message || err || "");
  return /cancel|popup_closed|user_cancel/i.test(code);
}

async function initAppleAuth({ usePopup, hashedNonce, redirectUri }) {
  await loadAppleScript();
  if (!window.AppleID?.auth) {
    throw new Error("Apple Sign In is unavailable in this browser.");
  }

  window.AppleID.auth.init({
    clientId: getAppleClientId(),
    scope: "name email",
    redirectURI: redirectUri,
    state: "nuvelo-web",
    usePopup,
    nonce: hashedNonce
  });
}

/**
 * Register SDK redirect handlers for desktop popup fallback (call once on app bootstrap).
 * @param {(tokens: { idToken: string, nonce: string | null }) => void | Promise<void>} onTokens
 * @param {(message: string) => void} [onFailure]
 */
export async function initAppleSignInCallback(onTokens, onFailure) {
  if (typeof window === "undefined" || callbackRegistered) {
    return;
  }
  callbackRegistered = true;

  await loadAppleScript();
  if (!window.AppleID?.auth) {
    return;
  }

  document.addEventListener("AppleIDSignInOnSuccess", (event) => {
    const idToken = event?.detail?.authorization?.id_token;
    if (!idToken) {
      return;
    }
    let rawNonce = null;
    try {
      rawNonce = localStorage.getItem(APPLE_NONCE_KEY);
      if (!rawNonce) {
        return;
      }
      clearApplePendingStorage();
    } catch {
      return;
    }
    void Promise.resolve(onTokens({ idToken, nonce: rawNonce })).catch((err) => {
      console.error(err);
    });
  });

  document.addEventListener("AppleIDSignInOnFailure", (event) => {
    clearApplePendingStorage();
    const msg = String(event?.detail?.error || "Apple sign-in failed.");
    if (onFailure && !/cancel|popup_closed|user_cancel/i.test(msg)) {
      onFailure(msg);
    }
  });

  window.AppleID.auth.init({
    clientId: getAppleClientId(),
    scope: "name email",
    redirectURI: getApplePopupRedirectUri(),
    state: "nuvelo-web",
    usePopup: false
  });
}

async function signInWithApplePopupFlow() {
  const rawNonce = randomNonce();
  const hashedNonce = await sha256Hex(rawNonce);
  storeApplePendingNonce(rawNonce);
  await initAppleAuth({
    usePopup: true,
    hashedNonce,
    redirectUri: getApplePopupRedirectUri()
  });

  let response;
  try {
    response = await window.AppleID.auth.signIn();
  } catch (err) {
    clearApplePendingStorage();
    if (isUserCancelledError(err)) {
      const cancelled = new Error("cancelled");
      cancelled.code = "cancelled";
      throw cancelled;
    }
    throw err;
  }

  clearApplePendingStorage();
  const idToken = response?.authorization?.id_token;
  if (!idToken) {
    throw new Error("Apple did not return an identity token.");
  }

  return { idToken, nonce: rawNonce };
}

async function signInWithAppleRedirectFlow() {
  const rawNonce = randomNonce();
  const hashedNonce = await sha256Hex(rawNonce);
  storeApplePendingNonce(rawNonce);
  window.location.assign(buildAppleAuthorizeUrl(hashedNonce, getAppleFormPostRedirectUri()));
  return { redirected: true };
}

/**
 * Apple Sign In → identity token for Supabase signInWithIdToken.
 * Mobile: authorize URL + form_post API callback. Desktop: JS popup.
 */
export async function signInWithApple() {
  if (preferAppleRedirect()) {
    return signInWithAppleRedirectFlow();
  }

  try {
    return await signInWithApplePopupFlow();
  } catch (err) {
    if (isUserCancelledError(err)) {
      throw err;
    }
    if (isPopupBlockedError(err)) {
      return signInWithAppleRedirectFlow();
    }
    throw err;
  }
}

/** @deprecated Use signInWithApple() */
export async function signInWithApplePopup() {
  return signInWithApplePopupFlow();
}
