import { getAuthRedirectUrl } from "./supabaseClient.js";

const APPLE_SCRIPT =
  "https://appleid.cdn-apple.com/appleauth/static/jsapi/appleid/1/en_US/appleid.auth.js";
const DEFAULT_CLIENT_ID = "one.nuvelo.web";

let scriptLoadPromise = null;

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

/**
 * Apple Sign In JS (popup) → identity token for Supabase signInWithIdToken.
 * Bypasses Supabase OAuth client_secret / JWT paste issues on web.
 */
export async function signInWithApplePopup() {
  await loadAppleScript();
  if (!window.AppleID?.auth) {
    throw new Error("Apple Sign In is unavailable in this browser.");
  }

  const clientId = getAppleClientId();
  const redirectURI = getAuthRedirectUrl() || window.location.origin;
  const rawNonce = randomNonce();
  const hashedNonce = await sha256Hex(rawNonce);

  window.AppleID.auth.init({
    clientId,
    scope: "name email",
    redirectURI,
    state: "nuvelo-web",
    usePopup: true,
    nonce: hashedNonce
  });

  let response;
  try {
    response = await window.AppleID.auth.signIn();
  } catch (err) {
    const code = String(err?.error || err?.message || err || "");
    if (/cancel|popup_closed|user_cancel/i.test(code)) {
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
