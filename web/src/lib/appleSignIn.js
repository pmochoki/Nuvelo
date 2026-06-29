import { getAuthRedirectUrl } from "./supabaseClient.js";

const APPLE_SCRIPT =
  "https://appleid.cdn-apple.com/appleauth/static/jsapi/appleid/1/en_US/appleid.auth.js";
const DEFAULT_CLIENT_ID = "one.nuvelo.web";
export const APPLE_NONCE_KEY = "nuvelo_apple_nonce";

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

function getAppleRedirectUri() {
  return getAuthRedirectUrl() || (typeof window !== "undefined" ? window.location.origin : "");
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

function isPopupBlockedError(err) {
  const code = String(err?.error || err?.message || err || "");
  return /popup|blocked/i.test(code);
}

function isUserCancelledError(err) {
  const code = String(err?.error || err?.message || err || "");
  return /cancel|popup_closed|user_cancel/i.test(code);
}

async function initAppleAuth({ usePopup, rawNonce, hashedNonce }) {
  await loadAppleScript();
  if (!window.AppleID?.auth) {
    throw new Error("Apple Sign In is unavailable in this browser.");
  }

  window.AppleID.auth.init({
    clientId: getAppleClientId(),
    scope: "name email",
    redirectURI: getAppleRedirectUri(),
    state: "nuvelo-web",
    usePopup,
    nonce: hashedNonce
  });

  return { rawNonce };
}

/**
 * Register redirect callback handlers (call once on app bootstrap).
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

  window.AppleID.auth.init({
    clientId: getAppleClientId(),
    scope: "name email",
    redirectURI: getAppleRedirectUri(),
    state: "nuvelo-web",
    usePopup: false
  });

  document.addEventListener("AppleIDSignInOnSuccess", (event) => {
    const idToken = event?.detail?.authorization?.id_token;
    if (!idToken) {
      return;
    }
    let rawNonce = null;
    try {
      rawNonce = sessionStorage.getItem(APPLE_NONCE_KEY);
      if (!rawNonce) {
        return;
      }
      sessionStorage.removeItem(APPLE_NONCE_KEY);
    } catch {
      return;
    }
    void Promise.resolve(onTokens({ idToken, nonce: rawNonce })).catch((err) => {
      console.error(err);
    });
  });

  document.addEventListener("AppleIDSignInOnFailure", (event) => {
    try {
      sessionStorage.removeItem(APPLE_NONCE_KEY);
    } catch {
      /* ignore */
    }
    const msg = String(event?.detail?.error || "Apple sign-in failed.");
    if (onFailure && !/cancel|popup_closed|user_cancel/i.test(msg)) {
      onFailure(msg);
    }
  });
}

async function signInWithApplePopupFlow() {
  const rawNonce = randomNonce();
  const hashedNonce = await sha256Hex(rawNonce);
  await initAppleAuth({ usePopup: true, rawNonce, hashedNonce });

  let response;
  try {
    response = await window.AppleID.auth.signIn();
  } catch (err) {
    if (isUserCancelledError(err)) {
      const cancelled = new Error("cancelled");
      cancelled.code = "cancelled";
      throw cancelled;
    }
    throw err;
  }

  const idToken = response?.authorization?.id_token;
  if (!idToken) {
    throw new Error("Apple did not return an identity token.");
  }

  return { idToken, nonce: rawNonce };
}

async function signInWithAppleRedirectFlow() {
  const rawNonce = randomNonce();
  const hashedNonce = await sha256Hex(rawNonce);
  await initAppleAuth({ usePopup: false, rawNonce, hashedNonce });

  try {
    sessionStorage.setItem(APPLE_NONCE_KEY, rawNonce);
  } catch {
    /* ignore */
  }

  window.AppleID.auth.signIn();
  return { redirected: true };
}

/**
 * Apple Sign In JS → identity token for Supabase signInWithIdToken.
 * Uses redirect on mobile; popup on desktop. Falls back to redirect if popup is blocked.
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
