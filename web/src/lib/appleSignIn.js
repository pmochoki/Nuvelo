import { getAuthRedirectUrl } from "./supabaseClient.js";

const APPLE_SCRIPT =
  "https://appleid.cdn-apple.com/appleauth/static/jsapi/appleid/1/en_US/appleid.auth.js";
const DEFAULT_CLIENT_ID = "one.nuvelo.web";
export const APPLE_RETURN_KEY = "nuvelo_apple_return";

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

function getApplePopupRedirectUri() {
  return getSiteOrigin();
}

export function getAppleFormPostRedirectUri() {
  return `${getSiteOrigin()}/api/auth/apple-callback`;
}

/** Phones, tablets, and narrow viewports — avoid OAuth popups. */
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

function buildAppleState(rawNonce) {
  return `nuvelo-web:${rawNonce}`;
}

function buildAppleAuthorizeUrl(hashedNonce, rawNonce, redirectUri) {
  const params = new URLSearchParams({
    client_id: getAppleClientId(),
    redirect_uri: redirectUri,
    response_type: "code id_token",
    response_mode: "form_post",
    scope: "name email",
    state: buildAppleState(rawNonce),
    nonce: hashedNonce
  });
  return `https://appleid.apple.com/auth/authorize?${params.toString()}`;
}

function decodeAppleReturnPayload(b64) {
  if (!b64) {
    return null;
  }
  try {
    const json = atob(b64.replace(/-/g, "+").replace(/_/g, "/"));
    const data = JSON.parse(json);
    if (data?.idToken) {
      return { idToken: data.idToken, nonce: data.nonce || null };
    }
  } catch {
    /* ignore */
  }
  return null;
}

/**
 * Parse Apple return after /api/auth/apple-callback forwards tokens via sessionStorage.
 * @returns {{ idToken: string, nonce: string | null } | { error: string, errorDescription?: string } | null}
 */
export function parseAppleRedirectFromUrl() {
  if (typeof window === "undefined") {
    return null;
  }

  const query = new URLSearchParams(window.location.search || "");
  const appleError = query.get("apple_error");
  if (appleError) {
    const errorDescription = query.get("apple_error_description") || "";
    window.history.replaceState(null, "", window.location.pathname);
    return { error: appleError, errorDescription };
  }

  if (query.get("apple_return") === "1") {
    let payload = null;
    try {
      payload = sessionStorage.getItem(APPLE_RETURN_KEY);
      sessionStorage.removeItem(APPLE_RETURN_KEY);
    } catch {
      /* ignore */
    }
    window.history.replaceState(null, "", window.location.pathname);
    const parsed = decodeAppleReturnPayload(payload);
    if (parsed) {
      return parsed;
    }
    return { error: "apple_return_missing", errorDescription: "Apple sign-in data was lost. Please try again." };
  }

  const hash = new URLSearchParams((window.location.hash || "").replace(/^#/, ""));
  const idToken = hash.get("id_token");
  if (idToken && hash.get("state")?.startsWith("nuvelo-web")) {
    const nonceFromState = hash.get("state")?.split(":").slice(1).join(":") || hash.get("apple_nonce") || null;
    window.history.replaceState(null, "", window.location.pathname);
    return { idToken, nonce: nonceFromState || null };
  }

  return null;
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
    void Promise.resolve(onTokens({ idToken, nonce: null })).catch((err) => {
      console.error(err);
    });
  });

  document.addEventListener("AppleIDSignInOnFailure", (event) => {
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
  await initAppleAuth({
    usePopup: true,
    hashedNonce,
    redirectUri: getApplePopupRedirectUri()
  });

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

/** Full-page Apple authorize URL (form_post → /api/auth/apple-callback). */
export async function signInWithAppleFormPostRedirect() {
  const rawNonce = randomNonce();
  const hashedNonce = await sha256Hex(rawNonce);
  window.location.assign(buildAppleAuthorizeUrl(hashedNonce, rawNonce, getAppleFormPostRedirectUri()));
  return { redirected: true };
}

/** Desktop: Apple JS popup → id_token. */
export async function signInWithApple() {
  try {
    return await signInWithApplePopupFlow();
  } catch (err) {
    if (isUserCancelledError(err)) {
      throw err;
    }
    if (isPopupBlockedError(err)) {
      return signInWithAppleFormPostRedirect();
    }
    throw err;
  }
}

/** @deprecated */
export async function signInWithApplePopup() {
  return signInWithApplePopupFlow();
}
