import { CATEGORIES } from "./data/categories.js";
import { HUNGARIAN_LOCATIONS } from "./data/hungarianLocations.js";
import { DEMO_EVENTS, EVENT_SUBCATEGORIES } from "./data/demoEvents.js";
import "../styles.css";
import {
  fetchListings as apiFetchListings,
  fetchListing as apiFetchListing,
  createListing,
  loginUser,
  setDonationClaimed
} from "./lib/listingsApi.js";
import { supabase, isSupabaseConfigured, getAuthRedirectUrl } from "./lib/supabaseClient.js";
import {
  DONATIONS_CATEGORY_ID,
  DONATION_SUBCATEGORIES,
  DONATION_CONDITIONS,
  DONATION_COLLECTION_METHODS,
  donationSubCategoryLabel,
  donationConditionLabel,
  donationCollectionMeta
} from "./data/donationConstants.js";

if (!import.meta.env.VITE_API_URL) {
  console.error("[Nuvelo] VITE_API_URL is not set! Auth and API calls will fail.");
}

/** Maps browser network failures (e.g. TypeError: Failed to fetch) to a clear message. */
const friendlyNetworkError = (err) => {
  const name = err && err.name;
  const msg = String((err && err.message) || "");
  if (
    name === "TypeError" ||
    /failed to fetch/i.test(msg) ||
    /networkerror/i.test(msg) ||
    /load failed/i.test(msg)
  ) {
    return "Could not reach the sign-in service. Check your connection. If you’re not using email magic links (Supabase), the demo server may need up to a minute to wake up — try again shortly.";
  }
  return msg || "Something went wrong. Please try again.";
};

/** OAuth needs Supabase env vars baked in at build time (Vercel → Production env → redeploy). */
const showOAuthUnavailable = (providerLabel) => {
  console.warn(
    "[Nuvelo] Supabase not configured: set VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY for the production build (e.g. Vercel project env), then redeploy."
  );
  showLoginError(
    import.meta.env.DEV
      ? `Configure VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY to enable ${providerLabel}.`
      : `${providerLabel} isn’t available right now. Try email or phone below, or try again after the site is updated.`
  );
};

/** Soft copy when listings are unavailable; never surface raw errors in the UI. */
const LISTINGS_UNAVAILABLE_MSG = "Listings are loading, please try again shortly.";
const USER_STORE_KEY = "nuvelo_user";
const EVENTS_STORE_KEY = "nuvelo_events_custom";
const EVENTS_RSVP_KEY = "nuvelo_events_rsvp";
const EVENTS_ANON_KEY = "nuvelo_events_anon";
const EVENTS_CATEGORY = "events";

let cachedUser = null;
/** Set after sending phone OTP until verified or modal reset. */
let phoneOtpPending = null;
const VIEW_MODE_KEY = "nuvelo_list_view";
const CATEGORY_SLUGS = {
  events: "events",
  donations: "donations",
  rentals: "rentals",
  jobs: "jobs",
  services: "services",
  goods: "clothes",
  vehicles: "vehicles",
  electronics: "electronics",
  furniture: "electronics",
  fashion: "clothes",
  "babies-kids": "clothes",
  other: "real-estate"
};

const ADS_CATEGORIES = CATEGORIES.filter((c) => c.slug !== EVENTS_CATEGORY);

const mainShell = () => document.getElementById("app");
const authBtn = document.getElementById("auth-btn");
const userChip = document.getElementById("user-chip");
const loginModal = document.getElementById("login-modal");
const loginForm = document.getElementById("login-form");

const getUser = () => cachedUser;

const readStoredUser = () => {
  try {
    const raw = localStorage.getItem(USER_STORE_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
};

const writeStoredUser = (user) => {
  try {
    if (user) {
      localStorage.setItem(USER_STORE_KEY, JSON.stringify(user));
    } else {
      localStorage.removeItem(USER_STORE_KEY);
    }
  } catch {
    /* ignore */
  }
};

function showLoginError(msg) {
  const errEl = document.getElementById("login-error");
  const okEl = document.getElementById("login-success");
  if (okEl) {
    okEl.hidden = true;
    okEl.textContent = "";
  }
  if (errEl) {
    if (!msg) {
      errEl.textContent = "";
      errEl.hidden = true;
    } else {
      errEl.textContent = msg;
      errEl.hidden = false;
    }
  }
}

function showLoginSuccess(msg) {
  const errEl = document.getElementById("login-error");
  const okEl = document.getElementById("login-success");
  if (errEl) {
    errEl.hidden = true;
    errEl.textContent = "";
  }
  if (okEl) {
    if (!msg) {
      okEl.textContent = "";
      okEl.hidden = true;
    } else {
      okEl.textContent = msg;
      okEl.hidden = false;
    }
  }
}

function resetAuthModalMessages() {
  showLoginError("");
  showLoginSuccess("");
  phoneOtpPending = null;
  const pv = document.getElementById("auth-phone-verify");
  if (pv) {
    pv.hidden = true;
  }
  const otp = document.getElementById("auth-phone-otp-input");
  if (otp) {
    otp.value = "";
  }
}

function applySupabaseSession(session) {
  if (!session?.user) {
    cachedUser = null;
    writeStoredUser(null);
    return;
  }
  const u = session.user;
  const meta = u.user_metadata || {};
  cachedUser = {
    id: u.id,
    name:
      meta.name ||
      meta.full_name ||
      meta.display_name ||
      (u.email && u.email.split("@")[0]) ||
      "Member",
    role: meta.role || "buyer",
    email: u.email || "",
    phone: u.phone || ""
  };
  writeStoredUser(cachedUser);
}

async function initAuth() {
  if (!isSupabaseConfigured || !supabase) {
    syncAuthFromStoredUser();
    return;
  }
  const {
    data: { session },
    error
  } = await supabase.auth.getSession();
  if (error) {
    console.error(error);
  }
  applySupabaseSession(session ?? null);
  updateAuthUi();

  supabase.auth.onAuthStateChange((event, session) => {
    applySupabaseSession(session ?? null);
    updateAuthUi();
    if (event === "SIGNED_IN") {
      resetAuthModalMessages();
      closeModal();
      void render().catch((e) => console.error(e));
    }
    if (event === "SIGNED_OUT") {
      cachedUser = null;
      writeStoredUser(null);
      void render().catch((e) => console.error(e));
    }
  });
}

const syncAuthFromStoredUser = () => {
  cachedUser = readStoredUser();
  updateAuthUi();
};

const updateAuthUi = () => {
  const user = getUser();
  const regBtn = document.getElementById("auth-register-btn");
  if (user) {
    authBtn.hidden = true;
    if (regBtn) {
      regBtn.hidden = true;
    }
    userChip.hidden = false;
    userChip.textContent = `${user.name} · ${user.role}`;
    userChip.title = "Click to sign out";
    userChip.style.cursor = "pointer";
  } else {
    authBtn.hidden = false;
    if (regBtn) {
      regBtn.hidden = false;
    }
    userChip.hidden = true;
    userChip.removeAttribute("title");
    userChip.style.cursor = "";
  }
};

userChip?.addEventListener("click", async () => {
  if (!getUser()) {
    return;
  }
  try {
    if (supabase) {
      await supabase.auth.signOut();
      return;
    }
  } catch (e) {
    console.error(e);
  }
  cachedUser = null;
  writeStoredUser(null);
  updateAuthUi();
  await render().catch((e) => console.error(e));
});

let authModalMode = "login";

const syncAuthBackendHint = () => {
  const el = document.getElementById("auth-backend-hint");
  if (!el) {
    return;
  }
  el.hidden = isSupabaseConfigured;
};

const openModal = (mode = "login") => {
  resetAuthModalMessages();
  authModalMode = mode;
  const titleEl = document.getElementById("login-title");
  const subEl = document.getElementById("login-subtitle");
  const errEl = document.getElementById("login-error");
  const formEl = document.getElementById("login-form");
  const socialEl = document.getElementById("login-social-block");
  const switchBtn = document.getElementById("auth-switch-mode");
  if (titleEl) {
    titleEl.textContent = mode === "signup" ? "Register" : "Sign in";
  }
  if (subEl) {
    subEl.textContent =
      mode === "signup"
        ? "Create your Nuvelo profile to post listings and message sellers."
        : "Use the same name and email as before to reconnect to your listings.";
  }
  if (errEl) {
    errEl.textContent = "";
    errEl.hidden = true;
  }
  if (socialEl) {
    socialEl.hidden = false;
  }
  const emailToggle = document.getElementById("auth-show-email-form");
  if (emailToggle) {
    emailToggle.hidden = mode === "signup";
    if (!emailToggle.hidden) {
      emailToggle.textContent = "Sign in with email or phone";
    }
  }
  if (formEl) {
    /* Login: start with OAuth only; signup: show name/role/email form immediately */
    formEl.hidden = mode === "login";
    loginModal.querySelectorAll(".auth-field--signup").forEach((el) => {
      el.hidden = mode === "login";
    });
    const nameInput = formEl.querySelector("input[name='name']");
    const roleSelect = formEl.querySelector("select[name='role']");
    if (nameInput) {
      nameInput.required = mode === "signup";
    }
    if (roleSelect) {
      roleSelect.required = mode === "signup";
    }
  }
  if (switchBtn) {
    switchBtn.textContent =
      mode === "signup" ? "Already have an account? Sign in" : "New here? Register";
  }
  loginModal.hidden = false;
  syncAuthBackendHint();
  if (mode === "signup" && formEl && !formEl.hidden) {
    loginModal.querySelector("input[name='name']")?.focus();
  }
};

const closeModal = () => {
  loginModal.hidden = true;
  resetAuthModalMessages();
};

loginModal?.addEventListener("click", (e) => {
  if (e.target?.dataset?.closeModal !== undefined) {
    closeModal();
  }
});

authBtn?.addEventListener("click", () => {
  openModal("login");
});

document.getElementById("auth-register-btn")?.addEventListener("click", () => {
  openModal("signup");
});

document.getElementById("drawer-register")?.addEventListener("click", () => {
  setNavDrawerOpen(false);
  openModal("signup");
});

document.getElementById("auth-google-stub")?.addEventListener("click", async () => {
  if (!supabase) {
    showOAuthUnavailable("Google sign-in");
    return;
  }
  showLoginError("");
  showLoginSuccess("");
  const redirectTo = getAuthRedirectUrl();
  const { error } = await supabase.auth.signInWithOAuth({
    provider: "google",
    options: { redirectTo }
  });
  if (error) {
    showLoginError(error.message || "Google sign-in failed.");
  }
});

document.getElementById("auth-fb-stub")?.addEventListener("click", async () => {
  if (!supabase) {
    showOAuthUnavailable("Facebook sign-in");
    return;
  }
  showLoginError("");
  showLoginSuccess("");
  const redirectTo = getAuthRedirectUrl();
  const { error } = await supabase.auth.signInWithOAuth({
    provider: "facebook",
    options: { redirectTo }
  });
  if (error) {
    showLoginError(error.message || "Facebook sign-in failed.");
  }
});

document.getElementById("auth-show-email-form")?.addEventListener("click", () => {
  const formEl = document.getElementById("login-form");
  if (formEl) {
    formEl.hidden = false;
    if (authModalMode === "login") {
      formEl.querySelector("input[name='email']")?.focus();
    } else {
      formEl.querySelector("input[name='name']")?.focus();
    }
  }
});

document.getElementById("auth-switch-mode")?.addEventListener("click", () => {
  const next = authModalMode === "signup" ? "login" : "signup";
  openModal(next);
});

document.body.addEventListener("click", (e) => {
  const pill = e.target.closest("[data-home-pill]");
  if (!pill) {
    return;
  }
  const kind = pill.getAttribute("data-home-pill");
  if (kind === "post") {
    setHash("/post");
    return;
  }
  if (kind === "trending") {
    document.querySelector(".jiji-trending")?.scrollIntoView({ behavior: "smooth" });
    document.querySelectorAll("#home-pills .jiji-pill").forEach((p) => p.classList.remove("jiji-pill--active"));
    pill.classList.add("jiji-pill--active");
    return;
  }
  if (kind === "cat") {
    const catId = pill.getAttribute("data-cat") || "";
    const next = new URLSearchParams();
    if (catId) {
      next.set("cat", catId);
    }
    const qs = next.toString();
    window.history.replaceState(
      null,
      "",
      `${window.location.pathname}${qs ? `?${qs}` : ""}#/browse`
    );
    render();
  }
});

/** Enter in text fields should submit; native behavior is unreliable inside dialogs. */
loginForm?.addEventListener("keydown", (e) => {
  if (e.key !== "Enter") {
    return;
  }
  if (e.isComposing || e.repeat) {
    return;
  }
  const t = e.target;
  if (!t || t.tagName !== "INPUT") {
    return;
  }
  e.preventDefault();
  e.stopPropagation();
  if (typeof loginForm.requestSubmit === "function") {
    loginForm.requestSubmit();
  } else {
    loginForm.querySelector("button[type='submit']")?.click();
  }
});

loginForm?.addEventListener("submit", async (e) => {
  e.preventDefault();
  const submitBtn = document.getElementById("login-form-submit") || loginForm.querySelector("button[type='submit']");
  showLoginError("");
  showLoginSuccess("");
  const fd = new FormData(loginForm);
  const name = String(fd.get("name") || "").trim();
  const role = String(fd.get("role") || "").trim();
  const email = String(fd.get("email") || "").trim() || "";
  const phone = String(fd.get("phone") || "").trim() || "";

  if (!email && !phone) {
    showLoginError("Enter an email (magic link) or phone (SMS code) to continue.");
    return;
  }

  /* Email branch runs first; both filled would skip SMS and leave phoneOtpPending unset */
  if (email && phone) {
    showLoginError(
      "Use email or phone — not both at once. For SMS: clear the email field, enter phone (+36…), then tap Continue."
    );
    return;
  }

  if (authModalMode === "signup" && (!name || name.length < 2)) {
    showLoginError("Enter your display name (at least 2 characters).");
    return;
  }

  if (supabase) {
    if (submitBtn) {
      submitBtn.disabled = true;
    }
    try {
      const redirectTo = getAuthRedirectUrl();
      const metaName = name || (email ? email.split("@")[0] : "") || "Member";
      const metaRole = role || "buyer";
      const meta = {
        name: metaName,
        role: metaRole,
        full_name: metaName,
        display_name: metaName
      };

      if (email) {
        const { error } = await supabase.auth.signInWithOtp({
          email,
          options: {
            emailRedirectTo: redirectTo,
            data: meta
          }
        });
        if (error) {
          showLoginError(error.message || "Could not send email link.");
          return;
        }
        showLoginSuccess("Check your email — we sent you a sign-in link.");
        return;
      }

      const { error } = await supabase.auth.signInWithOtp({
        phone,
        options: { data: meta }
      });
      if (error) {
        showLoginError(error.message || "Could not send SMS.");
        return;
      }
      phoneOtpPending = phone;
      const pv = document.getElementById("auth-phone-verify");
      if (pv) {
        pv.hidden = false;
        requestAnimationFrame(() => {
          pv.scrollIntoView({ block: "nearest", behavior: "smooth" });
        });
      }
      showLoginSuccess("Enter the code we sent to your phone.");
    } catch (err) {
      console.error(err);
      showLoginError(friendlyNetworkError(err));
    } finally {
      if (submitBtn) {
        submitBtn.disabled = false;
      }
    }
    return;
  }

  if (submitBtn) {
    submitBtn.disabled = true;
  }
  try {
    const user = await loginUser({
      name: name || "Member",
      role: role || "buyer",
      email,
      phone
    });
    cachedUser = user;
    writeStoredUser(user);
    updateAuthUi();
    closeModal();
    await render().catch((e) => console.error(e));
  } catch (err) {
    console.error(err);
    showLoginError(friendlyNetworkError(err));
  } finally {
    if (submitBtn) {
      submitBtn.disabled = false;
    }
  }
});

document.getElementById("auth-phone-verify-btn")?.addEventListener("click", async () => {
  if (!supabase || !phoneOtpPending) {
    showLoginError(
      supabase
        ? "No SMS was sent yet. Enter your phone (+36…), leave email empty, tap Continue, wait for the text, then enter the code here."
        : "SMS sign-in requires Supabase to be configured."
    );
    return;
  }
  const token = String(document.getElementById("auth-phone-otp-input")?.value || "").trim();
  if (!token) {
    showLoginError("Enter the code from your SMS.");
    return;
  }
  const btn = document.getElementById("auth-phone-verify-btn");
  if (btn) {
    btn.disabled = true;
  }
  try {
    const { error } = await supabase.auth.verifyOtp({
      phone: phoneOtpPending,
      token,
      type: "sms"
    });
    if (error) {
      showLoginError(error.message || "Invalid code.");
      return;
    }
    showLoginSuccess("Signed in successfully.");
  } finally {
    if (btn) {
      btn.disabled = false;
    }
  }
});

const esc = (s) => {
  const d = document.createElement("div");
  d.textContent = s ?? "";
  return d.innerHTML;
};

const readJsonStore = (key, fallback) => {
  try {
    const raw = localStorage.getItem(key);
    return raw ? JSON.parse(raw) : fallback;
  } catch {
    return fallback;
  }
};

const writeJsonStore = (key, value) => {
  try {
    localStorage.setItem(key, JSON.stringify(value));
  } catch {
    /* ignore */
  }
};

const ensureAnonEventUser = () => {
  const existing = localStorage.getItem(EVENTS_ANON_KEY);
  if (existing) {
    return existing;
  }
  const id = `anon-${Math.random().toString(36).slice(2, 10)}`;
  localStorage.setItem(EVENTS_ANON_KEY, id);
  return id;
};

const getAllEvents = () => {
  const custom = readJsonStore(EVENTS_STORE_KEY, []);
  return [...DEMO_EVENTS, ...custom].sort(
    (a, b) => new Date(a.dateTime).getTime() - new Date(b.dateTime).getTime()
  );
};

const findHungarianLocationRow = (stored) => {
  if (stored == null || String(stored).trim() === "") {
    return HUNGARIAN_LOCATIONS.find((r) => r.value === "all") || HUNGARIAN_LOCATIONS[0];
  }
  const t = String(stored).trim();
  const tl = t.toLowerCase();
  return (
    HUNGARIAN_LOCATIONS.find((r) => r.label.toLowerCase() === tl) ||
    HUNGARIAN_LOCATIONS.find((r) => r.value.toLowerCase() === tl) ||
    null
  );
};

const locationApiText = (stored) => {
  const row = findHungarianLocationRow(stored);
  if (row && row.value === "all") {
    return "";
  }
  if (row) {
    return row.label;
  }
  return String(stored || "").trim();
};

const locationButtonLabel = (stored) => {
  const row = findHungarianLocationRow(stored);
  if (!row || row.value === "all") {
    return "All Hungary";
  }
  if (row) {
    return row.label;
  }
  const t = String(stored || "").trim();
  return t || "All Hungary";
};

const locationRowsForMode = (mode) =>
  mode === "post"
    ? HUNGARIAN_LOCATIONS.filter((r) => r.value !== "all")
    : HUNGARIAN_LOCATIONS;

/** Shown first in the location modal (Jiji-style “POPULAR”). */
const HUNGARY_POPULAR_VALUES = new Set([
  "budapest",
  "debrecen",
  "szeged",
  "miskolc",
  "pecs",
  "gyor"
]);

const locModalRowHtml = (r) =>
  `<button type="button" class="loc-modal__row" role="option" data-loc-opt data-loc-value="${esc(r.value)}" data-loc-label="${esc(r.label)}">
    <span class="loc-modal__row-main">
      <span class="loc-modal__row-name">${esc(r.label)}</span>
      <span class="loc-modal__row-meta">• Ads</span>
    </span>
    <span class="loc-modal__row-chev" aria-hidden="true">›</span>
  </button>`;

const letterBucket = (label) => {
  const ch = String(label || "").trim().charAt(0);
  if (!ch) {
    return "#";
  }
  return ch.toLocaleUpperCase("hu");
};

const renderLocationModalContent = (root, searchQuery) => {
  const body = root.querySelector("[data-loc-body]");
  const titleEl = root.querySelector("[data-loc-modal-title]");
  const metaEl = root.querySelector("[data-loc-modal-meta]");
  if (!body) {
    return;
  }

  const mode = root.getAttribute("data-loc-mode") || "filter";
  const rows = locationRowsForMode(mode);
  const q = String(searchQuery || "").trim().toLowerCase();

  if (q) {
    const filtered = rows.filter(
      (r) =>
        r.label.toLowerCase().includes(q) || r.value.toLowerCase().includes(q)
    );
    if (titleEl) {
      titleEl.textContent = "Search results";
    }
    if (metaEl) {
      metaEl.textContent = `${filtered.length} match${filtered.length !== 1 ? "es" : ""}`;
    }
    body.innerHTML =
      filtered.length === 0
        ? `<p class="loc-modal__empty muted">No cities match your search.</p>`
        : `<div class="loc-modal__search-results">${filtered.map(locModalRowHtml).join("")}</div>`;
    return;
  }

  if (titleEl) {
    titleEl.textContent = mode === "post" ? "Choose city" : "All Hungary";
  }
  if (metaEl) {
    metaEl.textContent = "Select a city or town";
  }

  const parts = [];

  if (mode === "filter") {
    const allRow = HUNGARIAN_LOCATIONS.find((r) => r.value === "all");
    if (allRow) {
      parts.push(
        `<section class="loc-modal__group"><h3 class="loc-modal__group-h">Whole country</h3>${locModalRowHtml(allRow)}</section>`
      );
    }
  }

  const popular = rows.filter(
    (r) => r.value !== "all" && HUNGARY_POPULAR_VALUES.has(r.value)
  );
  if (popular.length) {
    const rail = `<span class="loc-modal__rail" aria-hidden="true">POPULAR</span>`;
    const inner = popular.map(locModalRowHtml).join("");
    parts.push(
      `<section class="loc-modal__group loc-modal__group--with-rail">${rail}<div class="loc-modal__group-rows">${inner}</div></section>`
    );
  }

  const rest = rows.filter(
    (r) => r.value !== "all" && !HUNGARY_POPULAR_VALUES.has(r.value)
  );
  rest.sort((a, b) => a.label.localeCompare(b.label, "hu"));
  const byLetter = new Map();
  for (const r of rest) {
    const L = letterBucket(r.label);
    if (!byLetter.has(L)) {
      byLetter.set(L, []);
    }
    byLetter.get(L).push(r);
  }
  const letters = [...byLetter.keys()].sort((a, b) => a.localeCompare(b, "hu"));
  for (const L of letters) {
    const list = byLetter.get(L);
    const rail = `<span class="loc-modal__rail" aria-hidden="true">${esc(L)}</span>`;
    const inner = list.map(locModalRowHtml).join("");
    parts.push(
      `<section class="loc-modal__group loc-modal__group--with-rail">${rail}<div class="loc-modal__group-rows">${inner}</div></section>`
    );
  }

  body.innerHTML = `<div class="loc-modal__multicolumn">${parts.join("")}</div>`;
};

const LOC_MODAL_CLOSE_MS = 280;

const closeLocationPanel = (root) => {
  if (!root) {
    return;
  }
  const modal = root.querySelector("[data-loc-modal]");
  const btn = root.querySelector("[data-loc-btn]");
  const search = root.querySelector("[data-loc-search]");
  root.classList.remove("is-open");
  document.body.classList.remove("loc-modal-open");
  if (btn) {
    btn.setAttribute("aria-expanded", "false");
  }
  if (modal) {
    modal.classList.remove("is-visible");
    clearTimeout(root._locModalCloseT);
    root._locModalCloseT = setTimeout(() => {
      modal.setAttribute("hidden", "");
      modal.setAttribute("aria-hidden", "true");
      modal.setAttribute("inert", "");
      if (search) {
        search.value = "";
      }
      renderLocationModalContent(root, "");
    }, LOC_MODAL_CLOSE_MS);
  } else if (search) {
    search.value = "";
  }
};

const openLocationPanel = (root) => {
  if (!root) {
    return;
  }
  document.querySelectorAll("[data-loc-combobox].is-open").forEach((el) => {
    if (el !== root) {
      closeLocationPanel(el);
    }
  });
  const modal = root.querySelector("[data-loc-modal]");
  const btn = root.querySelector("[data-loc-btn]");
  const search = root.querySelector("[data-loc-search]");
  root.classList.add("is-open");
  if (btn) {
    btn.setAttribute("aria-expanded", "true");
  }
  if (modal) {
    clearTimeout(root._locModalCloseT);
    modal.removeAttribute("hidden");
    modal.removeAttribute("inert");
    modal.setAttribute("aria-hidden", "false");
    if (search) {
      search.value = "";
    }
    renderLocationModalContent(root, "");
    document.body.classList.add("loc-modal-open");
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        modal.classList.add("is-visible");
        search?.focus();
      });
    });
  }
};

const syncLocationCombobox = (root, storedRaw) => {
  if (!root) {
    return;
  }
  const hidden = root.querySelector("[data-loc-hidden]");
  const btn = root.querySelector("[data-loc-btn]");
  const api = locationApiText(storedRaw);
  const label = locationButtonLabel(storedRaw);
  if (hidden) {
    hidden.value = api;
  }
  if (btn) {
    btn.textContent = label;
  }
  closeLocationPanel(root);
};

const applyLocationSelection = (root, value, label) => {
  const hidden = root.querySelector("[data-loc-hidden]");
  const btn = root.querySelector("[data-loc-btn]");
  if (value === "all") {
    if (hidden) {
      hidden.value = "";
    }
    if (btn) {
      btn.textContent = "All Hungary";
    }
  } else {
    if (hidden) {
      hidden.value = label;
    }
    if (btn) {
      btn.textContent = label;
    }
  }
  closeLocationPanel(root);
};

let hungarianLocGlobalHandlersBound = false;

const bindHungarianLocationGlobalHandlers = () => {
  if (hungarianLocGlobalHandlersBound) {
    return;
  }
  hungarianLocGlobalHandlersBound = true;
  document.addEventListener("click", () => {
    document.querySelectorAll("[data-loc-combobox].is-open").forEach((el) => {
      closeLocationPanel(el);
    });
  });
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") {
      document.querySelectorAll("[data-loc-combobox].is-open").forEach((el) => {
        closeLocationPanel(el);
      });
    }
  });
};

const initLocationCombobox = (root) => {
  if (!root || root.dataset.locInit) {
    return;
  }
  bindHungarianLocationGlobalHandlers();
  root.dataset.locInit = "1";
  const btn = root.querySelector("[data-loc-btn]");
  const search = root.querySelector("[data-loc-search]");
  const body = root.querySelector("[data-loc-body]");

  root.addEventListener("click", (e) => {
    e.stopPropagation();
  });

  root.querySelectorAll("[data-loc-close]").forEach((el) => {
    el.addEventListener("click", (e) => {
      e.preventDefault();
      e.stopPropagation();
      closeLocationPanel(root);
    });
  });

  btn?.addEventListener("click", (e) => {
    e.preventDefault();
    if (root.classList.contains("is-open")) {
      closeLocationPanel(root);
    } else {
      openLocationPanel(root);
    }
  });

  search?.addEventListener("input", () => {
    renderLocationModalContent(root, search.value);
  });

  body?.addEventListener("click", (e) => {
    const opt = e.target.closest("[data-loc-opt]");
    if (!opt) {
      return;
    }
    const value = opt.getAttribute("data-loc-value") || "";
    const label = opt.getAttribute("data-loc-label") || "";
    applyLocationSelection(root, value, label);
  });
};

const buildLocationComboboxHtml = ({
  fieldName,
  storedRaw,
  mode,
  wrapClass = "",
  btnClass = "loc-dd__btn"
}) => {
  const apiVal = locationApiText(storedRaw);
  const btnText = locationButtonLabel(storedRaw);
  const req = mode === "post" ? " required" : "";
  const wc = wrapClass ? `${wrapClass} ` : "";
  return `<div class="${wc}loc-dd" data-loc-combobox data-loc-mode="${esc(mode)}">
  <input type="hidden" name="${esc(fieldName)}" data-loc-hidden value="${esc(apiVal)}"${req} />
  <button type="button" class="${btnClass}" data-loc-btn aria-haspopup="dialog" aria-expanded="false">${esc(btnText)}</button>
  <div class="loc-modal" data-loc-modal hidden aria-hidden="true" inert>
    <div class="loc-modal__backdrop" data-loc-close tabindex="-1"></div>
    <div class="loc-modal__dialog" role="dialog" aria-modal="true" aria-label="Choose location">
      <div class="loc-modal__head">
        <div>
          <h2 class="loc-modal__title" data-loc-modal-title>All Hungary</h2>
          <p class="loc-modal__meta" data-loc-modal-meta>Select a city or town</p>
        </div>
        <button type="button" class="loc-modal__x" data-loc-close aria-label="Close">×</button>
      </div>
      <div class="loc-modal__search-row">
        <span class="loc-modal__search-icon" aria-hidden="true">⌕</span>
        <input type="search" class="loc-modal__search" data-loc-search placeholder="Find city or town…" autocomplete="off" aria-label="Search cities" />
      </div>
      <div class="loc-modal__body" data-loc-body></div>
    </div>
  </div>
</div>`;
};

const fetchListings = async (params) => {
  try {
    return await apiFetchListings(params);
  } catch (err) {
    console.error(err);
    throw new Error(err?.message || "Could not load listings. Check API configuration and try again.");
  }
};

const PAGE_SIZE = 12;

let browseListingsCache = { key: "", data: [] };

const parseBrowseParams = () => {
  const p = new URLSearchParams(window.location.search);
  const minp = p.get("minp");
  const maxp = p.get("maxp");
  const cond = p.get("cond") || "all";
  let conditionNew = p.get("cnew") === "1";
  let conditionUsed = p.get("cused") === "1";
  if (cond === "new") {
    conditionNew = true;
    conditionUsed = false;
  } else if (cond === "used") {
    conditionNew = false;
    conditionUsed = true;
  } else if (cond === "all") {
    conditionNew = false;
    conditionUsed = false;
  }
  return {
    query: p.get("q") || "",
    categoryId: p.get("cat") || "",
    location: p.get("loc") || "",
    minPrice: minp != null && minp !== "" ? Number(minp) : null,
    maxPrice: maxp != null && maxp !== "" ? Number(maxp) : null,
    conditionNew,
    conditionUsed,
    conditionMode: cond,
    priceBand: p.get("prb") || "",
    sellerFilter: p.get("sell") || "all",
    sort: p.get("sort") || "latest",
    timeFilter: p.get("t") || "any",
    page: Math.max(1, parseInt(p.get("page") || "1", 10) || 1)
  };
};

const activeFilterCount = (f) => {
  let n = 0;
  if (f.categoryId) n++;
  if (f.location) n++;
  if (f.minPrice != null) n++;
  if (f.maxPrice != null) n++;
  if (f.priceBand) n++;
  if (f.conditionMode && f.conditionMode !== "all") n++;
  if (f.sellerFilter && f.sellerFilter !== "all") n++;
  if (f.timeFilter && f.timeFilter !== "any") n++;
  return n;
};

const filterByCondition = (listings, cnew, cused) => {
  if (cnew && cused) {
    return listings;
  }
  if (!cnew && !cused) {
    return listings;
  }
  if (cnew) {
    return listings.filter((l) => String(l.condition || "").toLowerCase() === "new");
  }
  return listings.filter((l) => String(l.condition || "").toLowerCase() !== "new");
};

const sortListings = (listings, sortKey) => {
  const copy = [...listings];
  if (sortKey === "price_asc") {
    copy.sort((a, b) => (a.price ?? Infinity) - (b.price ?? Infinity));
  } else if (sortKey === "price_desc") {
    copy.sort((a, b) => (b.price ?? -Infinity) - (a.price ?? -Infinity));
  } else if (sortKey === "popular" || sortKey === "recommended") {
    copy.sort((a, b) => {
      const fb = b.isFeatured || b.featured ? 1 : 0;
      const fa = a.isFeatured || a.featured ? 1 : 0;
      if (fb !== fa) {
        return fb - fa;
      }
      return (
        (Number(b.viewCount) || Number(b.views) || 0) -
        (Number(a.viewCount) || Number(a.views) || 0)
      );
    });
  } else {
    copy.sort((a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0));
  }
  return copy;
};

const filterByPriceBand = (listings, band) => {
  if (!band) {
    return listings;
  }
  return listings.filter((l) => {
    const p = l.price;
    if (p == null) {
      return band === "over1m";
    }
    const n = Number(p);
    if (band === "under50k") {
      return n < 50000;
    }
    if (band === "50k200k") {
      return n >= 50000 && n <= 200000;
    }
    if (band === "200k1m") {
      return n > 200000 && n <= 1000000;
    }
    if (band === "over1m") {
      return n > 1000000;
    }
    return true;
  });
};

const filterBySellerPref = (listings, pref) => {
  if (pref !== "verified" && pref !== "unverified") {
    return listings;
  }
  return listings.filter((l) => {
    const v = Boolean(l.sellerVerified);
    return pref === "verified" ? v : !v;
  });
};

const filterByTimePref = (listings, t) => {
  if (!t || t === "any") {
    return listings;
  }
  const now = Date.now();
  const windowMs = t === "24h" ? 86400000 : 7 * 86400000;
  return listings.filter((l) => {
    const ts = new Date(l.createdAt || 0).getTime();
    return now - ts <= windowMs;
  });
};

/** Category / filter counts from live listing data — neutral label when empty. */
const formatListingCountLabel = (n) => {
  const x = Number(n) || 0;
  if (x <= 0) {
    return "Browse";
  }
  return `${new Intl.NumberFormat("en-US").format(x)} listings`;
};

const apiCategoryIdForSlug = (slug) => CATEGORY_SLUGS[slug] || slug;

const categoryDisplayName = (apiId) => {
  if (apiId == null || apiId === "") {
    return "";
  }
  const id = String(apiId);
  const row = CATEGORIES.find((c) => apiCategoryIdForSlug(c.slug) === id);
  return row ? row.label : id;
};

const formatStaticCategoryCount = (catRow, nFromListings) => {
  if (catRow.count != null) {
    return formatListingCountLabel(catRow.count);
  }
  return formatListingCountLabel(nFromListings);
};

const excerptOneLine = (text, max = 72) => {
  const t = String(text || "").replace(/\s+/g, " ").trim();
  return t.length > max ? `${t.slice(0, max)}…` : t;
};

const conditionLabel = (c) => {
  const x = String(c || "").toLowerCase();
  if (x === "new") {
    return "Brand New";
  }
  if (x === "used") {
    return "Local Used";
  }
  return "Used";
};

const getListViewMode = () => {
  try {
    const v = localStorage.getItem(VIEW_MODE_KEY);
    if (v === "list" || v === "grid") {
      return v;
    }
  } catch {
    /* ignore */
  }
  if (typeof window !== "undefined" && window.matchMedia("(max-width: 639px)").matches) {
    return "list";
  }
  return "grid";
};

const setListViewMode = (mode) => {
  try {
    localStorage.setItem(VIEW_MODE_KEY, mode === "list" ? "list" : "grid");
  } catch {
    /* ignore */
  }
};

const formatPostedTime = (iso) => {
  if (!iso) {
    return "";
  }
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) {
    return "";
  }
  const diff = Math.floor((Date.now() - d.getTime()) / 1000);
  if (diff < 60) {
    return "just now";
  }
  if (diff < 3600) {
    return `${Math.floor(diff / 60)}m ago`;
  }
  if (diff < 86400) {
    return `${Math.floor(diff / 3600)}h ago`;
  }
  if (diff < 604800) {
    return `${Math.floor(diff / 86400)}d ago`;
  }
  return d.toLocaleDateString();
};

const browseCacheKey = (f) =>
  JSON.stringify({
    q: f.query,
    cat: f.categoryId,
    loc: f.location,
    minp: f.minPrice,
    maxp: f.maxPrice
  });

const fetchListing = async (id) => {
  try {
    return await apiFetchListing(id);
  } catch (err) {
    console.error(err);
    throw new Error(err?.message || "Could not load listing.");
  }
};

const parseHash = () => {
  const raw = window.location.hash.replace(/^#\!?/, "") || "/";
  const parts = raw.split("/").filter(Boolean);
  if (parts[0] === "listing" && parts[1]) {
    return { view: "detail", id: parts[1] };
  }
  if (parts[0] === "post") {
    return { view: "post" };
  }
  if (parts[0] === "events") {
    return { view: "events" };
  }
  if (parts[0] === "event" && parts[1]) {
    return { view: "eventDetail", id: parts[1] };
  }
  if (parts[0] === "browse") {
    return { view: "list" };
  }
  if (parts[0] === "category" && parts[1]) {
    const slug = parts[1].toLowerCase();
    if (slug === EVENTS_CATEGORY) {
      return { view: "events" };
    }
    const catId = CATEGORY_SLUGS[slug] || slug;
    return { view: "list", categorySlug: catId };
  }
  if (
    ["terms", "privacy", "cookies", "faq", "safety", "about", "contact"].includes(
      parts[0]
    )
  ) {
    return { view: "static", page: parts[0] };
  }
  return { view: "landing" };
};

const setHash = (path) => {
  window.location.hash = path.startsWith("#") ? path : `#${path}`;
};

const listingImageUrl = (listing) => {
  const u = listing.images?.[0];
  if (typeof u === "string" && /^https?:\/\//i.test(u)) {
    return u;
  }
  return "";
};

const syncLandingHeaderScroll = () => {
  const header = document.querySelector(".site-header.jiji-header");
  if (!header) {
    return;
  }
  if (!document.body.classList.contains("is-landing")) {
    header.classList.remove("is-scrolled");
    return;
  }
  header.classList.toggle("is-scrolled", window.scrollY > 10);
};

const syncHeaderChrome = (route) => {
  const wrap = document.getElementById("header-search-wrap");
  if (wrap) {
    wrap.hidden = route.view === "landing";
    wrap.removeAttribute("aria-hidden");
    if (wrap.hidden) {
      wrap.setAttribute("aria-hidden", "true");
    }
  }
  syncLandingHeaderScroll();
};

const countByCategory = (listings) => {
  const m = {};
  listings.forEach((l) => {
    const id = l.categoryId || "";
    m[id] = (m[id] || 0) + 1;
  });
  return m;
};

/** Card/detail price line — never show negative HUF. */
const formatDisplayPrice = (listing) => {
  if (listing.categoryId === DONATIONS_CATEGORY_ID) {
    return null;
  }
  const p = listing.price;
  if (p == null) {
    return "Contact for price";
  }
  const n = Number(p);
  if (!Number.isFinite(n) || n < 0) {
    return "Contact for price";
  }
  if (n === 0) {
    return "Free";
  }
  return `${listing.currency || "HUF"} ${n}`;
};

const buildListingCardEl = (listing, opts = {}) => {
  const {
    viewMode = "grid",
    markPopular = false,
    idx = 0
  } = opts;
  const thumb = listingImageUrl(listing);
  const cf = listing.categoryFields || {};
  const isDonation = listing.categoryId === DONATIONS_CATEGORY_ID;
  const claimed = isDonation && Boolean(cf.claimed);
  const priceLine = formatDisplayPrice(listing) ?? "Contact for price";
  const tl = [];
  if (listing.featured || listing.isFeatured) {
    tl.push(`<span class="lc__pill lc__pill--feat">FEATURED</span>`);
  } else if (listing.urgent || listing.isUrgent) {
    tl.push(`<span class="lc__pill lc__pill--urg">URGENT</span>`);
  } else if (markPopular && idx < 6) {
    tl.push(`<span class="lc__pill lc__pill--pop">POPULAR</span>`);
  }
  const tr =
    listing.sellerVerified || listing.enterprise
      ? `<div class="lc__badges-tr"><span class="lc__pill lc__pill--ent">ENTERPRISE</span></div>`
      : "";
  const imgHtml = thumb
    ? `<img src="${esc(thumb)}" alt="" loading="lazy" decoding="async" />`
    : `<div class="lc__img-ph"></div>`;
  const excerpt = excerptOneLine(listing.description, 90);
  const posted = formatPostedTime(listing.createdAt);
  const loc = listing.location || "—";
  const sellerIco =
    listing.sellerVerified || listing.enterprise
      ? `<span class="lc__seller-ico" title="Verified">★</span>`
      : "";

  const condLine = isDonation
    ? `${donationConditionLabel(cf.donationCondition)} condition`
    : conditionLabel(listing.condition);
  const collMeta = isDonation ? donationCollectionMeta(cf.collectionMethod) : null;
  const collLine =
    isDonation && collMeta
      ? `<span class="lc__coll" title="${esc(collMeta.label)}">${collMeta.icon} ${esc(collMeta.short)}</span>`
      : "";

  const priceHtml = isDonation
    ? `<p class="lc__price lc__price--donation"><span class="lc__free">FREE</span></p>`
    : `<p class="lc__price">${esc(priceLine)}</p>`;

  const claimOverlay = claimed
    ? `<div class="lc__claimed-overlay" aria-hidden="true"><span>CLAIMED</span></div>`
    : "";

  const ctaRow = isDonation
    ? `<p class="lc__cta"><button type="button" class="lc__claim-btn" data-donation-cta>${claimed ? "View listing" : "I want this"}</button></p>`
    : "";

  const card = document.createElement("article");
  card.className = `lc lc--${viewMode === "list" ? "list" : "grid"}${isDonation ? " lc--donation" : ""}${claimed ? " lc--claimed" : ""}`;
  card.tabIndex = 0;
  card.setAttribute("role", "link");
  card.addEventListener("click", () => setHash(`/listing/${listing.id}`));
  card.addEventListener("keydown", (ev) => {
    if (ev.key === "Enter" || ev.key === " ") {
      ev.preventDefault();
      setHash(`/listing/${listing.id}`);
    }
  });

  card.innerHTML = `
    <div class="lc__media">
      <div class="lc__badges-tl">${tl.join("")}</div>
      ${tr}
      ${imgHtml}
      ${claimOverlay}
      ${sellerIco}
    </div>
    <div class="lc__body">
      ${priceHtml}
      <h3 class="lc__title">${esc(listing.title)}</h3>
      <p class="lc__excerpt">${esc(excerpt)}</p>
      <span class="lc__cond">${esc(condLine)}</span>
      ${
        isDonation
          ? `<div class="lc__donation-row"><span class="lc__loc">📍 ${esc(loc)}</span>${collLine}</div>
             <div class="lc__foot lc__foot--donation"><span class="lc__time">${esc(posted || "")}</span></div>${ctaRow}`
          : `<div class="lc__foot">
        <span class="lc__loc">📍 ${esc(loc)}</span>
        <span class="lc__time">${esc(posted || "")}</span>
      </div>`
      }
    </div>
  `;

  card.querySelector("[data-donation-cta]")?.addEventListener("click", (e) => {
    e.stopPropagation();
    setHash(`/listing/${listing.id}`);
  });

  return card;
};

const renderLanding = async () => {
  const appEl = mainShell();
  if (!appEl) {
    return;
  }
  let listings = [];
  try {
    listings = await fetchListings({});
  } catch (err) {
    console.error(err);
    listings = [];
  }
  const counts = countByCategory(listings);
  const viewMode = getListViewMode();
  const trending = sortListings([...listings], "popular").slice(0, 24);

  const catRows = [
    `<a class="jiji-cat-row" href="#/events">
      <span class="jiji-cat-row__thumb" aria-hidden="true">🎉</span>
      <span class="jiji-cat-row__mid">
        <span class="jiji-cat-row__name">Events</span>
        <span class="jiji-cat-row__count">Community board</span>
      </span>
      <span class="jiji-cat-row__chev" aria-hidden="true">›</span>
    </a>`,
    ...ADS_CATEGORIES.map((row) => {
    const catId = apiCategoryIdForSlug(row.slug);
    const n = counts[catId] ?? 0;
    const countLine = formatStaticCategoryCount(row, n);
    return `<a class="jiji-cat-row" href="#/category/${esc(row.slug)}">
      <span class="jiji-cat-row__thumb" aria-hidden="true">${row.icon}</span>
      <span class="jiji-cat-row__mid">
        <span class="jiji-cat-row__name">${esc(row.label)}</span>
        <span class="jiji-cat-row__count">${esc(countLine)}</span>
      </span>
      <span class="jiji-cat-row__chev" aria-hidden="true">›</span>
    </a>`;
    })
  ].join("");

  const pills = [
    `<button type="button" class="jiji-pill" data-home-pill="post">Post ad</button>`,
    `<a class="jiji-pill" href="#/events">🎉 Events</a>`,
    `<button type="button" class="jiji-pill jiji-pill--active" data-home-pill="trending">Trending</button>`,
    ...ADS_CATEGORIES.map((row) => {
      const catId = apiCategoryIdForSlug(row.slug);
      return `<button type="button" class="jiji-pill" data-home-pill="cat" data-cat="${esc(catId)}"><span aria-hidden="true">${row.icon}</span> ${esc(row.label)}</button>`;
    })
  ].join("");

  const urlLoc = new URLSearchParams(window.location.search).get("loc") || "";
  const heroLocCombobox = buildLocationComboboxHtml({
    fieldName: "loc",
    storedRaw: urlLoc,
    mode: "filter",
    wrapClass: "jiji-hero__loc-wrap loc-dd--hero",
    btnClass: "jiji-hero__loc-btn"
  });

  appEl.innerHTML = `
    <div class="jiji-home">
      <section class="jiji-hero" aria-label="Search">
        <div class="jiji-hero__inner">
          <h1 class="jiji-hero__title">What are you looking for?</h1>
          <form id="home-hero-form" class="jiji-hero__search">
            ${heroLocCombobox}
            <div class="jiji-hero__q-wrap">
              <input class="jiji-hero__q" name="q" type="search" placeholder="I am looking for…" />
            </div>
            <button type="submit" class="jiji-hero__submit" aria-label="Search">⌕</button>
          </form>
        </div>
      </section>
      <div class="jiji-home__cols">
        <aside class="jiji-home__sidebar" aria-label="Categories">
          <div class="jiji-cat-list">
            <h2 class="jiji-cat-list__title">Categories</h2>
            <div class="jiji-cat-list__scroll">${catRows}</div>
          </div>
        </aside>
        <div class="jiji-home__main">
          <div class="jiji-promo-strip" aria-label="Promotions">
            <a href="#/post" class="jiji-promo-card jiji-promo-card--a">Post your first ad</a>
            <a href="#/browse" class="jiji-promo-card jiji-promo-card--b">How to buy safely</a>
            <a href="#/about" class="jiji-promo-card jiji-promo-card--c">Verified sellers</a>
            <a href="#/faq" class="jiji-promo-card jiji-promo-card--d">How to sell</a>
            <a href="#/safety" class="jiji-promo-card jiji-promo-card--e">Safety tips</a>
          </div>
          <div class="jiji-pills" id="home-pills">${pills}</div>
          <section class="jiji-trending" aria-label="Trending ads">
            <div class="jiji-section-head">
              <h2>Trending ads</h2>
              <div class="jiji-view-toggle" role="group" aria-label="Listing view">
                <button type="button" id="home-view-grid" aria-pressed="${viewMode === "grid"}" aria-label="Grid view" title="Grid">⊞</button>
                <button type="button" id="home-view-list" aria-pressed="${viewMode === "list"}" aria-label="List view" title="List">☰</button>
              </div>
            </div>
            <div class="ad-grid--lc" id="home-listing-grid" data-view="${viewMode}"></div>
          </section>
        </div>
      </div>
    </div>
  `;

  const grid = document.getElementById("home-listing-grid");
  if (!listings.length) {
    grid.innerHTML = `<div class="listings-empty muted" role="status">No listings yet. Be the first to post!</div>`;
  } else {
    trending.forEach((listing, i) => {
      grid.appendChild(
        buildListingCardEl(listing, { viewMode, markPopular: true, idx: i })
      );
    });
  }

  const heroLocRoot = document.querySelector("#home-hero-form [data-loc-combobox]");
  initLocationCombobox(heroLocRoot);
  syncLocationCombobox(
    document.querySelector("#header-search-form [data-loc-combobox]"),
    urlLoc
  );

  document.getElementById("home-hero-form")?.addEventListener("submit", (e) => {
    e.preventDefault();
    const fd = new FormData(e.target);
    const q = String(fd.get("q") || "").trim();
    const loc = String(fd.get("loc") || "").trim();
    const next = new URLSearchParams();
    if (q) {
      next.set("q", q);
    }
    if (loc) {
      next.set("loc", loc);
    }
    const qs = next.toString();
    window.history.replaceState(
      null,
      "",
      `${window.location.pathname}${qs ? `?${qs}` : ""}#/browse`
    );
    render();
  });

  document.getElementById("home-view-grid")?.addEventListener("click", () => {
    setListViewMode("grid");
    render();
  });
  document.getElementById("home-view-list")?.addEventListener("click", () => {
    setListViewMode("list");
    render();
  });
};

const renderList = async () => {
  const appEl = mainShell();
  if (!appEl) {
    return;
  }
  const routeInfo = parseHash();
  const filters = parseBrowseParams();
  if (routeInfo.categorySlug) {
    filters.categoryId = routeInfo.categorySlug;
  }
  const fetchFilters = {
    query: filters.query,
    categoryId: filters.categoryId,
    location: filters.location,
    minPrice: filters.minPrice,
    maxPrice: filters.maxPrice
  };

  const hf = document.getElementById("header-search-form");
  if (hf?.elements?.q) {
    hf.elements.q.value = filters.query;
    syncLocationCombobox(hf.querySelector("[data-loc-combobox]"), filters.location);
    const catLabel = filters.categoryId ? categoryDisplayName(filters.categoryId) : "All ads";
    hf.elements.q.placeholder = `Search in ${catLabel}`;
  }

  const cacheKey = browseCacheKey(fetchFilters);
  let listings = [];
  let listingsLoadFailed = false;
  try {
    if (browseListingsCache.key === cacheKey) {
      listings = browseListingsCache.data;
    } else {
      listings = await fetchListings(fetchFilters);
      browseListingsCache = { key: cacheKey, data: listings };
    }
  } catch (e) {
    console.error(e);
    listingsLoadFailed = true;
    browseListingsCache = { key: "", data: [] };
  }
  if (!listingsLoadFailed) {
    listings = listings.filter((l) => l.categoryId !== EVENTS_CATEGORY);
  }

  let afterBand = listingsLoadFailed ? [] : filterByPriceBand(listings, filters.priceBand);
  afterBand = listingsLoadFailed ? [] : filterBySellerPref(afterBand, filters.sellerFilter);
  const afterCondition = listingsLoadFailed
    ? []
    : filterByCondition(afterBand, filters.conditionNew, filters.conditionUsed);
  const afterTime = listingsLoadFailed ? [] : filterByTimePref(afterCondition, filters.timeFilter);
  const sorted = listingsLoadFailed ? [] : sortListings(afterTime, filters.sort);
  const totalCount = sorted.length;
  const totalPages = Math.max(1, Math.ceil(totalCount / PAGE_SIZE));
  const curPage = Math.min(Math.max(1, filters.page), totalPages);
  const start = (curPage - 1) * PAGE_SIZE;
  const pageSlice = sorted.slice(start, start + PAGE_SIZE);
  const viewMode = getListViewMode();
  const subCount = totalCount;

  const catChips = [
    `<a href="#/events" class="cat-chip"><span class="cat-chip__emoji" aria-hidden="true">🎉</span><span class="cat-chip__label">Events</span></a>`,
    `<button type="button" class="cat-chip${!filters.categoryId ? " cat-chip--active" : ""}" data-cat=""><span class="cat-chip__emoji" aria-hidden="true">✨</span><span class="cat-chip__label">All</span></button>`,
    ...ADS_CATEGORIES.map((c) => {
      const apiId = apiCategoryIdForSlug(c.slug);
      const active = apiId === filters.categoryId ? " cat-chip--active" : "";
      return `<button type="button" class="cat-chip${active}" data-cat="${esc(apiId)}"><span class="cat-chip__emoji" aria-hidden="true">${c.icon}</span><span class="cat-chip__label">${esc(c.label)}</span></button>`;
    })
  ].join("");

  const locChip =
    filters.location ?
      `<div class="filter-chip-row"><span class="filter-chip">📍 ${esc(filters.location)} <button type="button" class="browse-loc-clear-btn" aria-label="Clear location">×</button></span></div>`
    : "";

  const feedTitle = filters.categoryId
    ? `${esc(categoryDisplayName(filters.categoryId))} in Hungary`
    : filters.location
      ? `Ads in ${esc(filters.location)}`
      : "All ads in Hungary";

  const catOptions = [
    `<option value=""${!filters.categoryId ? " selected" : ""}>All categories</option>`,
    ...ADS_CATEGORIES.map((c) => {
      const apiId = apiCategoryIdForSlug(c.slug);
      return `<option value="${esc(apiId)}"${apiId === filters.categoryId ? " selected" : ""}>${esc(c.label)}</option>`;
    })
  ].join("");

  const sortSel = filters.sort;
  const cond = filters.conditionMode;
  const prb = filters.priceBand;
  const sell = filters.sellerFilter;
  const timeSel = filters.timeFilter;
  const filterCount = activeFilterCount(filters);
  const filterBtnLabel = filterCount > 0 ? `Filters (${filterCount})` : "Filters";

  const filterFieldsHtml = `
    <div class="filter-panel filter-panel--jiji">
      <div class="filter-section">
        <h3>Categories</h3>
        <p class="muted small" style="margin:0 0 0.5rem"><strong>${filters.categoryId ? esc(categoryDisplayName(filters.categoryId)) : "All categories"}</strong></p>
        <a href="#/browse" class="small">All in category · ${esc(formatListingCountLabel(subCount))}</a>
      </div>
      <div class="filter-section">
        <h3>Location</h3>
        ${locChip}
        <label class="filter-panel__field">
          <span class="filter-panel__label">City / region</span>
          ${buildLocationComboboxHtml({
            fieldName: "loc",
            storedRaw: filters.location,
            mode: "filter",
            wrapClass: "",
            btnClass: "loc-dd__btn loc-dd__btn--field"
          })}
        </label>
      </div>
      <div class="filter-section">
        <h3>Price</h3>
        <div class="filter-panel__row">
          <label class="filter-panel__field filter-panel__field--half"><span class="filter-panel__label">Min</span><input name="minp" type="number" min="0" step="1" value="${filters.minPrice != null && !Number.isNaN(filters.minPrice) ? esc(String(filters.minPrice)) : ""}" /></label>
          <label class="filter-panel__field filter-panel__field--half"><span class="filter-panel__label">Max</span><input name="maxp" type="number" min="0" step="1" value="${filters.maxPrice != null && !Number.isNaN(filters.maxPrice) ? esc(String(filters.maxPrice)) : ""}" /></label>
        </div>
        <div class="filter-radio">
          <label><input type="radio" name="prb" value="" ${!prb ? "checked" : ""} /> Any price</label>
          <label><input type="radio" name="prb" value="under50k" ${prb === "under50k" ? "checked" : ""} /> Under 50,000 Ft · quick filter</label>
          <label><input type="radio" name="prb" value="50k200k" ${prb === "50k200k" ? "checked" : ""} /> 50K – 200K</label>
          <label><input type="radio" name="prb" value="200k1m" ${prb === "200k1m" ? "checked" : ""} /> 200K – 1M</label>
          <label><input type="radio" name="prb" value="over1m" ${prb === "over1m" ? "checked" : ""} /> Over 1M</label>
        </div>
      </div>
      <div class="filter-section">
        <h3>Condition</h3>
        <div class="filter-radio">
          <label><input type="radio" name="cond" value="all" ${cond === "all" ? "checked" : ""} /> Show all</label>
          <label><input type="radio" name="cond" value="new" ${cond === "new" ? "checked" : ""} /> Brand New</label>
          <label><input type="radio" name="cond" value="used" ${cond === "used" ? "checked" : ""} /> Used</label>
        </div>
      </div>
      <div class="filter-section">
        <h3>Seller type</h3>
        <div class="filter-radio">
          <label><input type="radio" name="sell" value="all" ${sell === "all" ? "checked" : ""} /> Show all</label>
          <label><input type="radio" name="sell" value="verified" ${sell === "verified" ? "checked" : ""} /> Verified sellers</label>
          <label><input type="radio" name="sell" value="unverified" ${sell === "unverified" ? "checked" : ""} /> Unverified sellers</label>
        </div>
      </div>
      <label class="filter-panel__field">
        <span class="filter-panel__label">Category</span>
        <select name="cat">${catOptions}</select>
      </label>
      <div class="filter-actions-row">
        <button type="button" class="btn btn--ghost browse-filter-clear-btn">Clear</button>
        <button type="submit" class="btn btn--primary">Save / Apply</button>
      </div>
    </div>
  `;

  const hashStr = window.location.hash || "#/browse";
  const pageHref = (p) => {
    const n = new URLSearchParams(window.location.search);
    if (p <= 1) {
      n.delete("page");
    } else {
      n.set("page", String(p));
    }
    const qs = n.toString();
    return `${window.location.pathname}${qs ? `?${qs}` : ""}${hashStr}`;
  };

  let pagHtml = "";
  if (totalPages > 1 && !listingsLoadFailed) {
    let start = Math.max(1, curPage - 2);
    let end = Math.min(totalPages, curPage + 2);
    if (curPage <= 3) {
      end = Math.min(totalPages, 5);
      start = 1;
    }
    if (curPage >= totalPages - 2) {
      start = Math.max(1, totalPages - 4);
      end = totalPages;
    }
    pagHtml = '<nav class="pagination-jiji" aria-label="Pages">';
    pagHtml += `<a class="pag-arr" href="${esc(pageHref(curPage - 1))}" aria-label="Previous" ${curPage <= 1 ? 'style="pointer-events:none;opacity:.4"' : ""}>←</a>`;
    for (let i = start; i <= end; i++) {
      pagHtml += `<a href="${esc(pageHref(i))}" class="${i === curPage ? "is-current" : ""}">${i}</a>`;
    }
    pagHtml += `<a class="pag-arr" href="${esc(pageHref(curPage + 1))}" aria-label="Next" ${curPage >= totalPages ? 'style="pointer-events:none;opacity:.4"' : ""}>→</a>`;
    pagHtml += "</nav>";
  }

  const bcCat = filters.categoryId ? ` › ${esc(categoryDisplayName(filters.categoryId))}` : "";

  appEl.innerHTML = `
    <div class="feed-layout feed-layout--browse">
      <nav class="breadcrumb-jiji" aria-label="Breadcrumb">
        <a href="#/browse">All ads</a>${bcCat}
      </nav>
      <div class="category-rail-wrap category-strip-wrap browse-cat-rail-mobile">
        <div class="category-strip" id="category-rail" role="tablist">${catChips}</div>
      </div>
      <button type="button" class="btn btn--outline browse-filter-btn-mobile" id="browse-filter-open">${filterBtnLabel}</button>
      ${
        listingsLoadFailed
          ? `<p class="browse-listings-soft-msg muted" role="status">${esc(LISTINGS_UNAVAILABLE_MSG)}</p>`
          : ""
      }
      <div class="browse-layout browse-layout--jiji">
        <aside class="browse-sidebar browse-sidebar--desktop" aria-label="Filters">
          <form id="sidebar-filter-form" class="browse-filter-form">${filterFieldsHtml}</form>
        </aside>
        <div class="browse-main">
          <div class="sort-bar sort-bar--jiji">
            <div>
              <h1 class="feed-head__title" style="margin:0;font-size:1.125rem">${feedTitle}</h1>
              <p class="muted" style="margin:0.15rem 0 0;font-size:0.875rem">${esc(String(totalCount))} results</p>
            </div>
            <div style="display:flex;flex-wrap:wrap;gap:0.5rem;align-items:center">
              <label class="sort-bar__sort">
                <span class="sort-bar__sort-label">Sort by:</span>
                <select id="browse-sort-select" class="sort-bar__select">
                  <option value="recommended" ${sortSel === "recommended" ? "selected" : ""}>Recommended</option>
                  <option value="latest" ${sortSel === "latest" ? "selected" : ""}>Newest first</option>
                  <option value="price_asc" ${sortSel === "price_asc" ? "selected" : ""}>Price ↑</option>
                  <option value="price_desc" ${sortSel === "price_desc" ? "selected" : ""}>Price ↓</option>
                  <option value="popular" ${sortSel === "popular" ? "selected" : ""}>Most popular</option>
                </select>
              </label>
              <label class="sort-bar__sort">
                <select id="browse-time-select" class="sort-bar__select">
                  <option value="any" ${timeSel === "any" ? "selected" : ""}>Any time</option>
                  <option value="24h" ${timeSel === "24h" ? "selected" : ""}>Last 24 hours</option>
                  <option value="7d" ${timeSel === "7d" ? "selected" : ""}>Last 7 days</option>
                </select>
              </label>
            </div>
          </div>
          <div class="browse-view-toolbar">
            <div class="jiji-view-toggle" role="group" aria-label="Listing view">
              <button type="button" id="browse-view-grid" aria-pressed="${viewMode === "grid"}" aria-label="Grid view" title="Grid">⊞</button>
              <button type="button" id="browse-view-list" aria-pressed="${viewMode === "list"}" aria-label="List view" title="List">☰</button>
            </div>
          </div>
          <div class="ad-grid--lc" id="listing-cards" data-view="${viewMode}"></div>
          <div id="browse-pagination">${pagHtml}</div>
        </div>
      </div>
    </div>
  `;

  const grid = document.getElementById("listing-cards");
  const sheet = document.getElementById("filter-sheet");
  const sheetBody = document.getElementById("filter-sheet-body");

  document.getElementById("browse-filter-open")?.addEventListener("click", () => {
    if (sheetBody) {
      sheetBody.innerHTML = `<form id="sidebar-filter-form-mobile" class="browse-filter-form">${filterFieldsHtml}</form>`;
      const mobForm = document.getElementById("sidebar-filter-form-mobile");
      wireBrowseFilterForm(mobForm);
      initLocationCombobox(mobForm?.querySelector("[data-loc-combobox]"));
    }
    if (sheet) {
      sheet.hidden = false;
      sheet.setAttribute("aria-hidden", "false");
    }
  });

  wireBrowseFilterForm(document.getElementById("sidebar-filter-form"));
  initLocationCombobox(document.querySelector("#sidebar-filter-form [data-loc-combobox]"));

  appEl.querySelectorAll(".browse-loc-clear-btn").forEach((btn) => {
    btn.addEventListener("click", () => {
      const n = new URLSearchParams(window.location.search);
      n.delete("loc");
      n.delete("page");
      window.history.replaceState(
        null,
        "",
        `${window.location.pathname}${n.toString() ? `?${n}` : ""}${window.location.hash}`
      );
      render();
    });
  });

  appEl.querySelectorAll(".browse-filter-clear-btn").forEach((btn) => {
    btn.addEventListener("click", (ev) => {
      ev.preventDefault();
      window.history.replaceState(null, "", `${window.location.pathname}#/browse`);
      browseListingsCache = { key: "", data: [] };
      render();
    });
  });

  document.getElementById("browse-view-grid")?.addEventListener("click", () => {
    setListViewMode("grid");
    render();
  });
  document.getElementById("browse-view-list")?.addEventListener("click", () => {
    setListViewMode("list");
    render();
  });

  if (!pageSlice.length && !listingsLoadFailed) {
    grid.innerHTML = `<div class="empty-state">No ads match your filters yet.</div>`;
    return;
  }

  if (listingsLoadFailed) {
    grid.innerHTML = "";
    return;
  }

  pageSlice.forEach((listing, i) => {
    grid.appendChild(buildListingCardEl(listing, { viewMode, markPopular: i < 4, idx: i }));
  });
};

function wireBrowseFilterForm(form) {
  if (!form) {
    return;
  }
  form.addEventListener("submit", (e) => {
    e.preventDefault();
    const fd = new FormData(form);
    const next = new URLSearchParams(window.location.search);
    const cat = String(fd.get("cat") || "").trim();
    const loc = String(fd.get("loc") || "").trim();
    const minp = String(fd.get("minp") || "").trim();
    const maxp = String(fd.get("maxp") || "").trim();
    const prb = String(fd.get("prb") || "").trim();
    const cond = String(fd.get("cond") || "all");
    const sell = String(fd.get("sell") || "all");
    if (cat) {
      next.set("cat", cat);
    } else {
      next.delete("cat");
    }
    if (loc) {
      next.set("loc", loc);
    } else {
      next.delete("loc");
    }
    if (minp) {
      next.set("minp", minp);
    } else {
      next.delete("minp");
    }
    if (maxp) {
      next.set("maxp", maxp);
    } else {
      next.delete("maxp");
    }
    if (prb) {
      next.set("prb", prb);
    } else {
      next.delete("prb");
    }
    next.set("cond", cond);
    next.set("sell", sell);
    next.delete("cnew");
    next.delete("cused");
    const tEl = document.getElementById("browse-time-select");
    if (tEl && tEl.value && tEl.value !== "any") {
      next.set("t", tEl.value);
    } else {
      next.delete("t");
    }
    next.delete("page");
    browseListingsCache = { key: "", data: [] };
    const qs = next.toString();
    window.history.replaceState(
      null,
      "",
      `${window.location.pathname}${qs ? `?${qs}` : ""}${window.location.hash || "#/browse"}`
    );
    closeFilterSheet();
    render();
  });
}

function closeFilterSheet() {
  const sheet = document.getElementById("filter-sheet");
  if (sheet) {
    sheet.hidden = true;
    sheet.setAttribute("aria-hidden", "true");
  }
}

const renderDetail = async (id) => {
  const appEl = mainShell();
  if (!appEl) {
    return;
  }
  let listing = null;
  let loadFailed = false;
  try {
    listing = await fetchListing(id);
  } catch (e) {
    console.error(e);
    loadFailed = true;
  }
  if (loadFailed) {
    appEl.innerHTML = `<p class="browse-listings-soft-msg muted" role="status">${esc(LISTINGS_UNAVAILABLE_MSG)}</p>
      <p><a href="#/browse">← Back to listings</a></p>`;
    return;
  }
  if (!listing) {
    appEl.innerHTML = `<p>Listing not found. <a href="#/browse">Back to browse</a></p>`;
    return;
  }

  const fields = listing.categoryFields || {};
  const isDonation = listing.categoryId === DONATIONS_CATEGORY_ID;
  const cf = fields;
  const claimed = isDonation && Boolean(cf.claimed);
  const fieldRows =
    !isDonation && Object.keys(fields).length
      ? `<ul class="field-list">${Object.entries(fields)
          .map(
            ([k, v]) =>
              `<li><span>${esc(k)}</span><span>${esc(String(v))}</span></li>`
          )
          .join("")}</ul>`
      : "";

  const coll = isDonation ? donationCollectionMeta(cf.collectionMethod) : null;
  const collLine = coll
    ? `${coll.label}${
        cf.deliveryKm != null && cf.collectionMethod === "local_delivery"
          ? ` (within ${cf.deliveryKm} km)`
          : ""
      }`
    : "";

  const donationDetailsSection = isDonation
    ? `<section>
        <h2 class="site-footer__heading" style="margin-top:1rem">Donation details</h2>
        <ul class="field-list">
          <li><span>Sub-category</span><span>${esc(donationSubCategoryLabel(cf.donationSubCategory))}</span></li>
          <li><span>Condition</span><span>${esc(donationConditionLabel(cf.donationCondition))}</span></li>
          <li><span>Collection</span><span>${esc(collLine)}</span></li>
          <li><span>Area / city</span><span>${esc(listing.location || "")}</span></li>
          <li><span>Quantity</span><span>${esc(String(cf.quantity ?? 1))}</span></li>
        </ul>
      </section>`
    : "";

  const imgs = (listing.images || []).filter(
    (u) => typeof u === "string" && /^https?:\/\//i.test(u)
  );
  const mainSrc = imgs[0] || "";
  const views = Number(listing.viewCount) || Number(listing.views) || 0;
  const priceStr = (() => {
    if (isDonation) {
      return "";
    }
    const p = listing.price;
    if (p == null) {
      return "Contact for price";
    }
    const n = Number(p);
    if (!Number.isFinite(n) || n < 0) {
      return "Contact for price";
    }
    if (n === 0) {
      return "Free";
    }
    return `${esc(listing.currency || "HUF")} ${esc(String(n))}`;
  })();
  const posted = formatPostedTime(listing.createdAt);
  const bcTitle = excerptOneLine(listing.title, 40);
  const descRaw = String(listing.description || "");
  const descLong = descRaw.length > 320;
  const catBrowseHref = `${window.location.pathname}?cat=${encodeURIComponent(listing.categoryId)}#/browse`;

  const pillsRow = isDonation
    ? `<span class="pill pill--free">FREE</span><span class="pill">${esc(
        donationConditionLabel(cf.donationCondition)
      )}</span><span class="pill">${esc(donationSubCategoryLabel(cf.donationSubCategory))}</span>`
    : `<span class="pill">${esc(conditionLabel(listing.condition))}</span>
          <span class="pill">${esc(categoryDisplayName(listing.categoryId))}</span>`;

  const galleryClaim = isDonation && claimed
    ? `<div class="detail-claimed-ribbon" aria-hidden="true">CLAIMED</div>`
    : "";

  const safetySection = isDonation
    ? `<section class="detail-donation-safety">
          <strong>Safety reminder</strong>
          <p>Always meet in a public place. Nuvelo does not verify donors.</p>
        </section>`
    : `<section class="detail-safety">
          <strong>Safety tips</strong>
          <ul>
            <li>Avoid sending prepayments</li>
            <li>Meet in a public place</li>
            <li>Inspect before paying</li>
            <li>Check all documents</li>
          </ul>
        </section>`;

  const userNow = getUser();
  const isOwner = Boolean(userNow && userNow.id === listing.userId);

  const asideBlock = isDonation
    ? `<aside class="detail-jiji-aside">
        <div class="detail-aside-card detail-aside-card--donation">
          <p class="price-big price-big--free">FREE</p>
          <p class="muted small" style="margin:0">📍 ${esc(listing.location || "")}</p>
          <p class="muted small" style="margin:0.25rem 0">${esc(posted)}</p>
          <p class="muted small">${views ? `${esc(String(views))} views` : ""}</p>
          <p class="muted small" style="margin:0.5rem 0 0">${coll ? `${coll.icon} ${esc(collLine)}` : ""}</p>
          <hr style="border:0;border-top:1px solid var(--purple-border);margin:1rem 0" />
          <p style="margin:0;font-weight:700">${esc(listing.sellerName || "Donor")}</p>
          <p class="muted small">Donor · Member since ${esc(cf.sellerMemberSince || "—")}</p>
          <p class="muted small">Contact preference: ${esc(cf.contactPreference || "message via app")}</p>
          ${
            !isOwner
              ? `<button type="button" class="btn btn--primary" style="width:100%;margin-top:0.75rem;border-radius:8px" id="detail-donation-claim" ${
                  claimed ? "disabled" : ""
                }>${claimed ? "Claimed" : "I want this"}</button>`
              : ""
          }
          ${
            isOwner
              ? `<button type="button" class="btn btn--outline" style="width:100%;margin-top:0.75rem;border-radius:8px" id="detail-owner-claimed">${claimed ? "Mark as available" : "Mark as claimed"}</button>`
              : ""
          }
          <button type="button" class="btn btn--ghost" style="width:100%;margin-top:0.5rem" id="detail-report">Report listing</button>
        </div>
      </aside>`
    : `<aside class="detail-jiji-aside">
        <div class="detail-aside-card">
          ${listing.sellerVerified || listing.enterprise ? `<p class="pill" style="margin:0 0 0.5rem">ENTERPRISE</p>` : ""}
          <p class="price-big">${priceStr}</p>
          <p class="muted small" style="margin:0">📍 ${esc(listing.location || "")}</p>
          <p class="muted small" style="margin:0.25rem 0">${esc(posted)}</p>
          <p class="muted small">${views ? `${esc(String(views))} views` : ""}</p>
          <button type="button" class="btn btn--primary" style="width:100%;margin-top:0.75rem;border-radius:8px" id="detail-show-contact">Show contact</button>
          <p class="small muted" id="detail-phone-reveal" hidden style="margin:0.5rem 0 0">Phone: use the Nuvelo app to contact the seller securely.</p>
          <button type="button" class="btn btn--outline" style="width:100%;margin-top:0.5rem;border-radius:8px" id="detail-callback">Request call back</button>
          <hr style="border:0;border-top:1px solid var(--purple-border);margin:1rem 0" />
          <p style="margin:0;font-weight:700"><a href="#/browse">${esc(listing.sellerName || "Seller")}</a></p>
          <p class="muted small">Verified seller · 1+ years on Nuvelo</p>
          <p class="muted small">Typically replies within an hour</p>
          <button type="button" class="btn btn--ghost" style="width:100%;margin-top:0.5rem" id="detail-contact">Start chat</button>
          <p class="small" style="text-align:center;margin:0.75rem 0 0"><button type="button" class="btn btn--link" id="detail-offer">Make an offer</button></p>
          <div class="site-footer__social" style="margin-top:1rem;justify-content:center">
            <span class="site-footer__social-icon" title="Share">f</span>
            <span class="site-footer__social-icon" title="Share">𝕏</span>
            <span class="site-footer__social-icon" title="Share">W</span>
            <span class="site-footer__social-icon" title="Share">✉</span>
          </div>
        </div>
      </aside>`;

  appEl.innerHTML = `
    <nav class="breadcrumb-jiji" aria-label="Breadcrumb">
      <a href="#/browse">All ads</a> ›
      <a href="${catBrowseHref}">${esc(categoryDisplayName(listing.categoryId))}</a> ›
      <span class="muted">${esc(bcTitle)}</span>
    </nav>
    <div class="detail-jiji-wrap">
      <div class="detail-jiji-main">
        <div class="detail-gallery ${isDonation ? "detail-gallery--donation" : ""}">
          <div class="detail-gallery__main ${claimed && isDonation ? "detail-gallery__main--claimed" : ""}">
            ${galleryClaim}
            ${mainSrc ? `<img id="detail-main-img" src="${esc(mainSrc)}" alt="" />` : `<div class="detail-hero__img" style="min-height:200px;background:var(--purple-surface)"></div>`}
            ${imgs.length ? `<span class="detail-gallery__count" id="detail-img-count">1 / ${imgs.length}</span>` : ""}
          </div>
          ${
            imgs.length > 1
              ? `<div class="detail-gallery__thumbs" id="detail-thumbs">${imgs
                  .map(
                    (u, i) =>
                      `<button type="button" class="${i === 0 ? "is-active" : ""}" data-idx="${i}" aria-label="Photo ${i + 1}"><img src="${esc(u)}" alt="" /></button>`
                  )
                  .join("")}</div>`
              : ""
          }
        </div>
        <div style="display:flex;flex-wrap:wrap;gap:0.35rem;margin:0.75rem 0">
          ${pillsRow}
        </div>
        <h1 style="margin:0 0 0.5rem;font-size:1.5rem">${esc(listing.title)}</h1>
        <section>
          <h2 class="site-footer__heading" style="margin-top:1rem">Description</h2>
          <p class="desc-long ${descLong ? "is-collapsed" : ""}" id="detail-desc">${esc(listing.description)}</p>
          ${descLong ? `<button type="button" class="btn btn--link" id="detail-desc-more">Show more</button>` : ""}
        </section>
        ${donationDetailsSection}
        ${fieldRows ? `<section><h2 class="site-footer__heading" style="margin-top:1rem">Details</h2>${fieldRows}</section>` : ""}
        ${safetySection}
        <p class="small" style="margin-top:1rem"><a href="#/post" class="btn btn--link">Post ad like this</a></p>
      </div>
      ${asideBlock}
    </div>
    <p class="muted small" id="detail-contact-msg" style="margin-top:0.75rem"></p>
  `;

  const mainImg = document.getElementById("detail-main-img");
  document.querySelectorAll("#detail-thumbs button").forEach((btn) => {
    btn.addEventListener("click", () => {
      const i = Number(btn.getAttribute("data-idx"));
      const u = imgs[i];
      if (mainImg && u) {
        mainImg.src = u;
      }
      document.querySelectorAll("#detail-thumbs button").forEach((b) => b.classList.toggle("is-active", b === btn));
      const cnt = document.getElementById("detail-img-count");
      if (cnt) {
        cnt.textContent = `${i + 1} / ${imgs.length}`;
      }
    });
  });

  document.getElementById("detail-desc-more")?.addEventListener("click", (e) => {
    e.preventDefault();
    document.getElementById("detail-desc")?.classList.remove("is-collapsed");
    e.target.hidden = true;
  });

  document.getElementById("detail-show-contact")?.addEventListener("click", () => {
    const el = document.getElementById("detail-phone-reveal");
    if (el) {
      el.hidden = false;
    }
  });
  document.getElementById("detail-callback")?.addEventListener("click", () => {
    window.alert("Request received. The seller may call you back in the Nuvelo app.");
  });
  document.getElementById("detail-offer")?.addEventListener("click", () => {
    window.alert("Offers can be sent from the Nuvelo app.");
  });

  document.getElementById("detail-contact")?.addEventListener("click", async () => {
    const user = getUser();
    const msg = document.getElementById("detail-contact-msg");
    if (!user) {
      msg.textContent = "Sign in first to message the seller.";
      openModal("login");
      return;
    }
    if (user.id === listing.userId) {
      msg.textContent = "This is your listing.";
      return;
    }
    msg.textContent =
      "In-app messaging is not wired yet. Use Show contact for now.";
  });

  document.getElementById("detail-donation-claim")?.addEventListener("click", async () => {
    const user = getUser();
    const msg = document.getElementById("detail-contact-msg");
    if (!user) {
      msg.textContent = "Sign in first to message the donor.";
      openModal("login");
      return;
    }
    if (user.id === listing.userId) {
      msg.textContent = "This is your listing.";
      return;
    }
    msg.textContent =
      "Your interest has been noted. In-app messaging will connect you to the donor when it is available.";
  });

  document.getElementById("detail-owner-claimed")?.addEventListener("click", () => {
    setDonationClaimed(listing.id, !claimed);
    render();
  });

  document.getElementById("detail-report")?.addEventListener("click", () => {
    window.alert("Thanks. This listing has been flagged for moderator review.");
  });
};

const eventDateFmt = (iso) =>
  new Date(iso).toLocaleString([], {
    weekday: "short",
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit"
  });

const eventFilterParams = () => {
  const p = new URLSearchParams(window.location.search);
  return {
    sub: p.get("esub") || "",
    city: p.get("ecity") || "",
    date: p.get("edate") || "any",
    free: p.get("efree") === "1"
  };
};

const eventMatchesDateRange = (eventIso, mode) => {
  if (!mode || mode === "any") return true;
  const now = new Date();
  const ev = new Date(eventIso);
  const diffDays = (ev.getTime() - now.getTime()) / 86400000;
  if (mode === "weekend") return diffDays >= 0 && diffDays <= 4;
  if (mode === "week") return diffDays >= 0 && diffDays <= 7;
  if (mode === "month") return diffDays >= 0 && diffDays <= 30;
  return true;
};

const renderEventsList = async () => {
  const appEl = mainShell();
  if (!appEl) return;
  const f = eventFilterParams();
  let rows = getAllEvents();
  rows = rows.filter((e) => {
    if (f.sub && e.subCategory !== f.sub) return false;
    if (f.city && e.city !== f.city) return false;
    if (f.free && !e.isFree) return false;
    if (!eventMatchesDateRange(e.dateTime, f.date)) return false;
    return true;
  });
  rows.sort((a, b) => new Date(a.dateTime) - new Date(b.dateTime));
  const filtersOpenLabel =
    f.sub || f.city || f.free || f.date !== "any" ? "Filters (active)" : "Filters";

  appEl.innerHTML = `
    <div class="feed-layout feed-layout--browse">
      <nav class="breadcrumb-jiji"><a href="#/">Home</a> › <span>Events</span></nav>
      <button type="button" class="btn btn--outline browse-filter-btn-mobile" id="events-filter-open">${filtersOpenLabel}</button>
      <div class="browse-layout browse-layout--jiji">
        <aside class="browse-sidebar browse-sidebar--desktop">
          <form id="events-filter-form" class="filter-panel filter-panel--jiji">
            <h3 style="margin:0">Event filters</h3>
            <label class="filter-panel__field"><span class="filter-panel__label">Sub-category</span>
              <select name="esub"><option value="">All</option>${EVENT_SUBCATEGORIES.map((s) => `<option value="${esc(s)}" ${f.sub === s ? "selected" : ""}>${esc(s)}</option>`).join("")}</select>
            </label>
            <label class="filter-panel__field"><span class="filter-panel__label">City</span>
              <select name="ecity"><option value="">All Hungary</option>${HUNGARIAN_LOCATIONS.filter((x) => x.value !== "all").map((x) => `<option value="${esc(x.label)}" ${f.city === x.label ? "selected" : ""}>${esc(x.label)}</option>`).join("")}</select>
            </label>
            <label class="filter-panel__field"><span class="filter-panel__label">Date range</span>
              <select name="edate">
                <option value="any" ${f.date === "any" ? "selected" : ""}>Any time</option>
                <option value="weekend" ${f.date === "weekend" ? "selected" : ""}>This weekend</option>
                <option value="week" ${f.date === "week" ? "selected" : ""}>This week</option>
                <option value="month" ${f.date === "month" ? "selected" : ""}>This month</option>
              </select>
            </label>
            <label class="filter-panel__check"><input type="checkbox" name="efree" value="1" ${f.free ? "checked" : ""} /> Free only</label>
            <div class="filter-actions-row">
              <button type="button" class="btn btn--ghost" id="events-filter-clear">Clear</button>
              <button type="submit" class="btn btn--primary">Apply</button>
            </div>
          </form>
        </aside>
        <div class="browse-main">
          <div class="sort-bar sort-bar--jiji">
            <h1 class="feed-head__title" style="margin:0">🎉 Events in Hungary</h1>
            <a class="btn btn--primary" href="#/post">Create event</a>
          </div>
          <div class="ad-grid--lc" id="events-grid" data-view="grid">
            ${rows.map((e) => `<article class="lc lc--grid event-card" role="link" tabindex="0" data-event-id="${esc(e.id)}">
              <div class="lc__media"><img src="${esc(e.image)}" alt="" loading="lazy" /></div>
              <div class="lc__body">
                <p class="lc__price">${e.isFree ? "FREE" : `HUF ${esc(String(e.price || 0))}`}</p>
                <h3 class="lc__title">${esc(e.title)}</h3>
                <p class="lc__excerpt">📅 ${esc(eventDateFmt(e.dateTime))}</p>
                <p class="lc__excerpt">📍 ${esc(e.city)} · ${esc(e.venue || "TBA")}</p>
                <div class="lc__foot"><span>${esc(e.subCategory)}</span><span>👥 ${e.attendees.length} going</span></div>
              </div>
            </article>`).join("")}
          </div>
        </div>
      </div>
    </div>
  `;
  const form = document.getElementById("events-filter-form");
  const applyFilter = (sourceForm) => {
    const fd = new FormData(sourceForm);
    const q = new URLSearchParams(window.location.search);
    ["esub", "ecity", "edate"].forEach((k) => {
      const v = String(fd.get(k) || "").trim();
      if (!v || (k === "edate" && v === "any")) q.delete(k);
      else q.set(k, v);
    });
    if (fd.get("efree")) q.set("efree", "1");
    else q.delete("efree");
    window.history.replaceState(null, "", `${window.location.pathname}${q.toString() ? `?${q}` : ""}#/events`);
    render();
  };
  form?.addEventListener("submit", (e) => {
    e.preventDefault();
    applyFilter(form);
  });
  document.getElementById("events-filter-clear")?.addEventListener("click", () => {
    window.history.replaceState(null, "", `${window.location.pathname}#/events`);
    render();
  });
  appEl.querySelectorAll("[data-event-id]").forEach((el) => {
    const go = () => setHash(`/event/${el.getAttribute("data-event-id")}`);
    el.addEventListener("click", go);
    el.addEventListener("keydown", (ev) => {
      if (ev.key === "Enter" || ev.key === " ") {
        ev.preventDefault();
        go();
      }
    });
  });
  document.getElementById("events-filter-open")?.addEventListener("click", () => {
    const sheet = document.getElementById("filter-sheet");
    const body = document.getElementById("filter-sheet-body");
    if (body) body.innerHTML = form.outerHTML;
    const mobileForm = body?.querySelector("form");
    mobileForm?.addEventListener("submit", (e) => {
      e.preventDefault();
      applyFilter(mobileForm);
      closeFilterSheet();
    });
    if (sheet) {
      sheet.hidden = false;
      sheet.setAttribute("aria-hidden", "false");
    }
  });
};

const renderEventDetail = async (eventId) => {
  const appEl = mainShell();
  if (!appEl) return;
  const row = getAllEvents().find((x) => x.id === eventId);
  if (!row) {
    appEl.innerHTML = `<p>Event not found. <a href="#/events">Back to events</a></p>`;
    return;
  }
  const user = getUser();
  const userId = user?.id || ensureAnonEventUser();
  const rsvpState = readJsonStore(EVENTS_RSVP_KEY, {});
  const eventRsvp = rsvpState[eventId] || { going: [], maybe: [] };
  const baseAttendees = [...row.attendees];
  if (eventRsvp.going.includes(userId) && !baseAttendees.some((a) => a.id === userId)) {
    baseAttendees.push({
      id: userId,
      name: user?.name || "You",
      avatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=120&q=80"
    });
  }

  appEl.innerHTML = `
    <nav class="breadcrumb-jiji"><a href="#/events">Events</a> › <span>${esc(row.title)}</span></nav>
    <div class="detail-jiji-wrap">
      <div class="detail-jiji-main">
        <div class="detail-gallery__main"><img src="${esc(row.image)}" alt="" /></div>
        <h1 style="margin-top:1rem">${esc(row.title)}</h1>
        <p>${esc(row.description)}</p>
        <p>📅 <strong>${esc(eventDateFmt(row.dateTime))}</strong> · ${esc(row.duration || "Duration TBA")}</p>
        <p>📍 <strong>${esc(row.city)}</strong> · ${esc(row.venue)} · ${esc(row.address || "")}</p>
        <p>Organiser: <strong>${esc(row.organizerName)}</strong></p>
        <p><span class="pill">${esc(row.subCategory)}</span> <span class="pill">${row.isFree ? "FREE" : `PAID · HUF ${esc(String(row.price || 0))}`}</span></p>
        <p class="muted">Contact preference: ${esc(row.contactPreference || "message via app")}</p>
        <div class="site-footer__social">${(row.tags || []).map((t) => `<span class="filter-chip">${esc(t)}</span>`).join("")}</div>
      </div>
      <aside class="detail-jiji-aside">
        <div class="detail-aside-card">
          <p class="price-big">👥 ${baseAttendees.length} going</p>
          <p class="muted small">Maybe: ${eventRsvp.maybe.length}</p>
          <button class="btn btn--primary" style="width:100%;margin-bottom:0.5rem" id="event-going-btn">I'm Going</button>
          <button class="btn btn--outline" style="width:100%;margin-bottom:0.5rem" id="event-maybe-btn">Maybe</button>
          <button class="btn btn--ghost" style="width:100%;margin-bottom:0.5rem" id="event-share-btn">Share</button>
          <button class="btn btn--ghost" style="width:100%" id="event-report-btn">Report event</button>
          <div style="margin-top:0.8rem">${baseAttendees.slice(0, 8).map((a) => `<img src="${esc(a.avatar)}" alt="${esc(a.name)}" style="width:28px;height:28px;border-radius:50%;margin-right:4px" />`).join("")}</div>
        </div>
      </aside>
    </div>
  `;

  const persist = (kind) => {
    const all = readJsonStore(EVENTS_RSVP_KEY, {});
    const cur = all[eventId] || { going: [], maybe: [] };
    cur.going = cur.going.filter((x) => x !== userId);
    cur.maybe = cur.maybe.filter((x) => x !== userId);
    cur[kind].push(userId);
    all[eventId] = cur;
    writeJsonStore(EVENTS_RSVP_KEY, all);
    render();
  };
  document.getElementById("event-going-btn")?.addEventListener("click", () => persist("going"));
  document.getElementById("event-maybe-btn")?.addEventListener("click", () => persist("maybe"));
  document.getElementById("event-share-btn")?.addEventListener("click", async () => {
    try {
      await navigator.clipboard.writeText(window.location.href);
      window.alert("Event link copied.");
    } catch {
      window.alert("Copy failed. You can copy the URL manually.");
    }
  });
  document.getElementById("event-report-btn")?.addEventListener("click", () => {
    window.alert("Thanks. The event report has been logged for moderation.");
  });
};

const staticPageShell = (title, bodyHtml) => `
  <article class="stack" style="max-width:920px;margin:0 auto;padding:0 0 2rem">
    <h1 style="margin:0">${esc(title)}</h1>
    ${bodyHtml}
  </article>
`;

const renderStaticPage = async (slug) => {
  const appEl = mainShell();
  if (!appEl) {
    return;
  }

  const pages = {
    terms: staticPageShell(
      "Terms & Conditions",
      `
      <p>Welcome to Nuvelo. These Terms and Conditions govern access to and use of our marketplace where users can publish and discover listings for rentals, jobs, services, vehicles, electronics, furniture, fashion, and other legal categories in Hungary. By accessing Nuvelo, creating an account, posting a listing, or responding to a listing, you agree to comply with these terms in full. If you do not agree, you must not use the platform.</p>
      <p>Nuvelo is a user-generated marketplace. We provide technical infrastructure to help buyers, sellers, tenants, landlords, job seekers, and service providers connect. Nuvelo is not a party to contracts concluded between users. Every user is responsible for verifying information, reviewing documents, and making independent decisions before any transaction. Any contract for sale, rental, employment, or service is solely between the users involved.</p>
      <p>Users must provide accurate profile information, including a valid name and contact details. You are responsible for maintaining account security and for all actions taken under your account. You may not create accounts using false identities, impersonate others, or share accounts in a way that bypasses moderation. If you suspect unauthorized access, notify us immediately and update your credentials.</p>
      <p>Listings must be lawful, accurate, and clearly described. You must include truthful pricing, location, and condition details. Misleading titles, bait-and-switch tactics, hidden fees, duplicate spam listings, or intentionally false category placement are prohibited. Listings must represent actual goods, properties, jobs, or services available in Hungary and must not attempt to redirect users to scams or unrelated external offers.</p>
      <p>Prohibited content includes illegal goods, counterfeit products, weapons where forbidden by law, unsafe medical claims, discriminatory listings, fraudulent investment offers, phishing schemes, stolen property, explicit content involving minors, and anything that violates Hungarian or EU law. Nuvelo may remove content, suspend accounts, and cooperate with authorities when required by law or when user safety is at risk.</p>
      <p>Users posting jobs must comply with labor law, including lawful working conditions, pay transparency where required, and non-discrimination obligations. Users posting rentals must have legal rights to lease the property and provide accurate information about terms, deposits, and utility obligations. Service providers must represent qualifications truthfully and must not claim licenses or certifications they do not hold.</p>
      <p>Users must communicate respectfully. Harassment, threats, hate speech, extortion, and abuse are forbidden. You may not scrape user data, harvest email addresses, or use automated scripts to spam messages. Contact information obtained through Nuvelo may only be used for legitimate transaction communication connected to the listing. Reuse for unrelated marketing or bulk solicitation is prohibited.</p>
      <p>Nuvelo may moderate listings before or after publication. Moderation actions can include requesting edits, limiting visibility, rejecting listings, or suspending accounts. Moderation decisions are based on safety, legal compliance, quality standards, and platform integrity. We are not obligated to publish every listing and we may prioritize user trust and legal obligations over listing visibility.</p>
      <p>Fees and paid features, if offered, are disclosed in-app. Unless explicitly stated otherwise, standard listing and browsing functionality may be offered without charge during MVP periods. Any future paid products, such as promoted placement or premium tools, will be governed by separate pricing notices. Non-refundable rules may apply after a paid feature is delivered.</p>
      <p>Nuvelo does not guarantee that users are truthful, that listings remain available, or that transactions will succeed. Platform availability may be interrupted due to maintenance, outages, third-party failures, or force majeure events. To the maximum extent permitted by law, Nuvelo disclaims implied warranties, including merchantability and fitness for a particular purpose. Use of the platform is at your own risk.</p>
      <p>Limitation of liability: Nuvelo is not liable for indirect, incidental, or consequential damages, lost profits, loss of data, missed opportunities, or personal disputes arising from user interactions. Our total liability for direct damages related to your use of the service is limited to the amount paid by you to Nuvelo for paid features in the 12 months preceding the claim, or 20,000 HUF if no payment was made.</p>
      <p>You agree to indemnify and hold Nuvelo harmless against claims, losses, and costs arising from your listings, your user content, your legal violations, or disputes with other users. This includes reasonable legal costs where permitted by law. Nuvelo may participate in dispute resolution evidence requests but is not obligated to mediate private contractual disagreements.</p>
      <p>These terms may be updated to reflect legal changes, product updates, or safety requirements. Material changes will be published on this page with an updated effective date. Continued use after updates means acceptance of revised terms. If you disagree with a change, you must stop using the service and request account closure.</p>
      <p>These terms are governed by applicable Hungarian law, without prejudice to mandatory EU consumer protections. Disputes should first be raised through Nuvelo support so we can attempt resolution in good faith. If unresolved, disputes may be submitted to competent courts in Hungary. If any clause is invalid, the remaining terms remain in force.</p>
      <p><strong>Effective date:</strong> 8 April 2026. Contact: <a href="mailto:support@nuvelo.app">support@nuvelo.app</a></p>
      `
    ),
    privacy: staticPageShell(
      "Privacy Policy",
      `
      <p>Nuvelo respects your privacy and processes personal data in accordance with the EU General Data Protection Regulation (GDPR) and applicable Hungarian law. This Privacy Policy explains what data we collect, why we collect it, how we use it, and what rights you have. It applies to users browsing, posting listings, messaging sellers, and contacting support through Nuvelo.</p>
      <p><strong>Data controller:</strong> Nuvelo Marketplace. For privacy requests, email <a href="mailto:privacy@nuvelo.app">privacy@nuvelo.app</a>. We process account and listing data to operate the marketplace, prevent abuse, and comply with legal obligations.</p>
      <p><strong>Data we collect:</strong> account details (name, email, phone, role), listing details (title, description, category, price, location, images), communication metadata (message timestamps, moderation reports), technical information (IP address, browser type, device characteristics), and analytics/cookie data where consent applies. We do not intentionally collect special category data unless users include it in free-text fields.</p>
      <p><strong>Legal bases:</strong> contract performance (providing marketplace functions), legitimate interests (fraud prevention, abuse detection, service security), consent (optional analytics/marketing cookies), and legal obligations (law-enforcement requests, tax/accounting where applicable).</p>
      <p><strong>How we use data:</strong> creating and maintaining user accounts, publishing and ranking listings, filtering search results by location and category, enabling contact between users, preventing spam/scams, enforcing listing policies, and improving platform performance. We also use aggregated data to understand usage trends and prioritize product fixes.</p>
      <p><strong>Retention:</strong> Account and listing records are retained while your account is active and for a limited period afterward to handle disputes, legal obligations, and fraud prevention. Logs and technical diagnostics are retained for shorter operational windows unless needed for security investigations. Where possible, data is anonymized when no longer required.</p>
      <p><strong>Sharing:</strong> We share data only when necessary: with infrastructure providers (hosting, storage, monitoring), with support tooling vendors, and with legal authorities when required by law. We do not sell personal data. If service providers process data outside the EEA, we use appropriate safeguards such as Standard Contractual Clauses.</p>
      <p><strong>Public data:</strong> Listing content is intentionally visible to other users and search engines depending on site indexing settings. Do not post sensitive personal information in listing descriptions, images, or chat messages. If you publish contact details in a listing, other users may store or reuse that information at their own discretion.</p>
      <p><strong>Security:</strong> We apply technical and organizational measures such as transport encryption, access controls, monitoring, and moderation tools to protect user data. No internet service is completely secure; users should also protect their accounts by using strong passwords and being cautious with suspicious messages.</p>
      <p><strong>Your GDPR rights:</strong> right of access, rectification, erasure, restriction, objection, and data portability, plus the right to withdraw consent for consent-based processing. You may also lodge a complaint with a supervisory authority, including the Hungarian Data Protection Authority (NAIH), if you believe your data rights were violated.</p>
      <p><strong>Cookies and analytics:</strong> Nuvelo uses necessary cookies for essential operation and optional analytics cookies for product improvement. Consent is collected where required. You can control cookie preferences in your browser and via site controls where available. See our Cookie Policy for detailed cookie categories.</p>
      <p><strong>Children:</strong> Nuvelo is not intended for children under 16. If we learn that personal data of a child was collected without valid authorization, we will remove it as required by law.</p>
      <p><strong>Policy updates:</strong> We may update this Privacy Policy to reflect legal or service changes. Material updates will be posted with a revised effective date. Continued use after updates indicates acknowledgement of the new policy terms.</p>
      <p><strong>Effective date:</strong> 8 April 2026. Privacy contact: <a href="mailto:privacy@nuvelo.app">privacy@nuvelo.app</a></p>
      `
    ),
    cookies: staticPageShell(
      "Cookie Policy",
      `
      <p>This Cookie Policy explains how Nuvelo uses cookies and similar technologies when you visit our website. Cookies are small text files stored on your device that help websites remember preferences, maintain sessions, and understand usage.</p>
      <h2>Cookie categories we use</h2>
      <p><strong>Necessary cookies:</strong> Required for core functionality such as routing, session continuity, and security controls. These cannot be disabled if you want the website to function properly.</p>
      <p><strong>Analytics cookies:</strong> Help us understand which pages are useful, where users encounter errors, and how performance can be improved. We use aggregated metrics where possible.</p>
      <p><strong>Marketing cookies:</strong> If enabled in future campaigns, these cookies may help measure ad effectiveness and show relevant promotions. We only use them with consent where required.</p>
      <h2>Managing cookies</h2>
      <p>You can control cookies through browser settings by blocking or deleting stored cookies. You can also use private browsing modes to reduce persistence. Blocking necessary cookies may break parts of the site.</p>
      <p>For privacy requests related to cookies, contact <a href="mailto:privacy@nuvelo.app">privacy@nuvelo.app</a>.</p>
      `
    ),
    faq: staticPageShell(
      "Frequently Asked Questions",
      `
      <h2>General</h2>
      <p><strong>1) How do I post an ad?</strong><br />Go to <code>#/post</code>, complete the required fields, add photos, and submit. Listings may be moderated before they appear publicly.</p>
      <p><strong>2) Do I need an account to browse?</strong><br />No. Browsing is open. You need an account to publish listings and use direct contact features.</p>
      <p><strong>3) How do I contact a seller?</strong><br />Open the listing page and use the available contact action. Always keep conversations on-platform when possible.</p>
      <p><strong>4) Is posting free?</strong><br />Core posting is currently free during MVP. Paid promotion features may be introduced later.</p>
      <p><strong>5) Why was my listing rejected?</strong><br />Common reasons include missing details, prohibited content, misleading titles, duplicate posts, or poor-quality images.</p>
      <p><strong>6) How can I stay safe?</strong><br />Meet in public places, avoid prepayments, verify documents, and report suspicious users immediately.</p>
      <p><strong>7) Can I edit or delete my listing?</strong><br />Yes. Use your account area or moderation request channels if direct editing is not yet enabled for your listing type.</p>
      <p><strong>8) Why can’t I find my city in search?</strong><br />Use the location dropdown and check spelling/diacritics. Filters can hide results if min/max prices are too strict.</p>
      <p><strong>9) How fast does moderation happen?</strong><br />Most listings are reviewed within one business day, but high-risk categories may take longer.</p>
      <p><strong>10) How do I report fraud or abuse?</strong><br />Use the report action in listing/chat views or email <a href="mailto:support@nuvelo.app">support@nuvelo.app</a> with screenshots and links.</p>
      `
    ),
    safety: staticPageShell(
      "Safety Tips",
      `
      <p>Nuvelo is built for trusted local trading, but every online marketplace requires caution. Use these practical guidelines for safer buying and selling.</p>
      <h2>For buyers</h2>
      <p>Meet sellers in busy public places, ideally during daytime. Inspect the item carefully before payment. Ask for receipts, serial numbers, and ownership proof for high-value goods. Be careful with offers that are far below market value.</p>
      <p>Never send advance payment to unknown sellers, especially via irreversible channels. Prefer secure, traceable payment methods and avoid sharing unnecessary personal data.</p>
      <h2>For sellers</h2>
      <p>Use clear listing photos, accurate descriptions, and realistic prices to reduce misunderstandings. Meet buyers in safe places and do not hand over goods before receiving full payment. For rentals, verify tenant identity and use written agreements.</p>
      <h2>For jobs and services</h2>
      <p>Employers should provide clear role terms and lawful work conditions. Candidates should verify company details before sharing sensitive documents. Service providers should state qualifications honestly and avoid taking large upfront payments without contracts.</p>
      <h2>Report suspicious behavior</h2>
      <p>If you notice fake profiles, phishing links, pressure tactics, or requests to move off-platform immediately, stop communication and report the user. Fast reporting helps protect everyone.</p>
      `
    ),
    about: staticPageShell(
      "About Nuvelo",
      `
      <p>Nuvelo is a classifieds marketplace built for Hungary’s international community. We help expats and locals connect around real everyday needs: finding rentals, posting jobs, buying and selling goods, and offering trusted services.</p>
      <p>Our mission is to make local discovery simpler, safer, and more transparent for people living and working across languages and cultures in Hungary.</p>
      <p>We focus on practical marketplace tools, clear listings, moderation standards, and a mobile-friendly experience that works on both desktop and phone.</p>
      <p>Contact: <a href="mailto:support@nuvelo.app">support@nuvelo.app</a></p>
      `
    ),
    contact: staticPageShell(
      "Contact Us",
      `
      <p>If you need support, have a moderation question, or want to report an issue, contact us using the form below.</p>
      <form id="contact-form" class="stack" style="max-width:640px">
        <label>Name<input name="name" required placeholder="Your full name" /></label>
        <label>Email<input name="email" type="email" required placeholder="you@example.com" /></label>
        <label>Message<textarea name="message" required rows="6" placeholder="How can we help?"></textarea></label>
        <div><button type="submit" class="btn btn--primary">Send message</button></div>
        <p id="contact-msg" class="muted"></p>
      </form>
      <p>Support email: <a href="mailto:support@nuvelo.app">support@nuvelo.app</a></p>
      `
    )
  };

  appEl.innerHTML =
    pages[slug] || staticPageShell("Page not found", `<p>We could not find that page. <a href="#/">Return home</a>.</p>`);

  if (slug === "contact") {
    document.getElementById("contact-form")?.addEventListener("submit", (e) => {
      e.preventDefault();
      const msg = document.getElementById("contact-msg");
      if (msg) {
        msg.textContent =
          "Thanks. Your message has been queued for support review. We typically reply within 1 business day.";
      }
      e.target.reset();
    });
  }
};

const categoryFieldHtml = (categoryId) => {
  if (categoryId === "vehicles") {
    return `
      <div class="category-fields stack">
        <label>Make <input name="cf_make" required placeholder="Toyota" /></label>
        <label>Model <input name="cf_model" required placeholder="Corolla" /></label>
        <label>Year <input name="cf_year" required type="number" placeholder="2018" /></label>
      </div>`;
  }
  if (categoryId === "real-estate" || categoryId === "rentals") {
    return `
      <div class="category-fields stack">
        <label>Type <input name="cf_type" required placeholder="studio" /></label>
        <label>Bedrooms <input name="cf_bedrooms" required type="number" /></label>
        <label>Bathrooms <input name="cf_bathrooms" required type="number" /></label>
        <label>Area (m²) <input name="cf_area" required type="number" /></label>
      </div>`;
  }
  if (categoryId === "electronics") {
    return `
      <div class="category-fields stack">
        <label>Brand <input name="cf_brand" required placeholder="Apple" /></label>
        <label>Model <input name="cf_model" required placeholder="iPhone 12" /></label>
      </div>`;
  }
  if (categoryId === "jobs") {
    return `
      <div class="category-fields stack">
        <label>Role <input name="cf_role" required placeholder="Barista" /></label>
        <label>Contract type <input name="cf_contractType" required placeholder="part-time" /></label>
      </div>`;
  }
  if (categoryId === "services") {
    return `
      <div class="category-fields stack">
        <label>Service type <input name="cf_serviceType" required placeholder="Cleaning" /></label>
      </div>`;
  }
  return `<p class="muted small">No extra fields for this category.</p>`;
};

const buildCategoryFields = (categoryId, fd) => {
  const out = {};
  if (categoryId === "vehicles") {
    out.make = String(fd.get("cf_make") || "").trim();
    out.model = String(fd.get("cf_model") || "").trim();
    out.year = Number(fd.get("cf_year"));
  } else if (categoryId === "real-estate" || categoryId === "rentals") {
    out.type = String(fd.get("cf_type") || "").trim();
    out.bedrooms = Number(fd.get("cf_bedrooms"));
    out.bathrooms = Number(fd.get("cf_bathrooms"));
    out.area = Number(fd.get("cf_area"));
  } else if (categoryId === "electronics") {
    out.brand = String(fd.get("cf_brand") || "").trim();
    out.model = String(fd.get("cf_model") || "").trim();
  } else if (categoryId === "jobs") {
    out.role = String(fd.get("cf_role") || "").trim();
    out.contractType = String(fd.get("cf_contractType") || "").trim();
  } else if (categoryId === "services") {
    out.serviceType = String(fd.get("cf_serviceType") || "").trim();
  } else if (categoryId === DONATIONS_CATEGORY_ID) {
    out.donationSubCategory = String(fd.get("donationSubCategory") || "").trim();
    out.donationCondition = String(fd.get("donationCondition") || "good").trim();
    out.collectionMethod = String(fd.get("donationCollectionMethod") || "pickup").trim();
    const km = fd.get("donationDeliveryKm");
    out.deliveryKm =
      out.collectionMethod === "local_delivery" && km ? Number(km) : null;
    out.contactPreference = String(fd.get("donationContact") || "message via app").trim();
    out.quantity = fd.get("donationQuantity") ? Number(fd.get("donationQuantity")) : 1;
    out.claimed = false;
    out.sellerMemberSince = String(new Date().getFullYear());
  }
  return out;
};

const renderPost = async () => {
  const appEl = mainShell();
  if (!appEl) {
    return;
  }
  const user = getUser();
  if (!user) {
    appEl.innerHTML = `
      <div class="post-shell">
        <header class="post-shell__head">
          <h1 class="post-shell__title">Post an ad</h1>
          <p class="post-shell__lead muted">Sign in to publish. Your ad is reviewed before it appears.</p>
          <p class="post-shell__hint muted small" style="margin-top:0.75rem;max-width:36rem;line-height:1.5">
            To post a new ad — rentals, jobs, goods, services, donations, and more — please sign in or create a free account.
            After you sign in you can choose a category, add photos, and set your price and location.
          </p>
        </header>
      <button type="button" class="btn btn--primary btn--lg" id="post-signin">Sign in to continue</button>
      </div>
    `;
    document.getElementById("post-signin")?.addEventListener("click", () => openModal("login"));
    return;
  }

  const defaultCat = apiCategoryIdForSlug(
    ADS_CATEGORIES.find((c) => c.slug === "rentals")?.slug || ADS_CATEGORIES[0].slug
  );
  const postLocDefault =
    HUNGARIAN_LOCATIONS.find((r) => r.value === "budapest")?.label || "Budapest";
  const postCategories = CATEGORIES.map((c) =>
    c.slug === EVENTS_CATEGORY ? { ...c, apiId: EVENTS_CATEGORY } : { ...c, apiId: apiCategoryIdForSlug(c.slug) }
  );
  const subOpts = ADS_CATEGORIES.map(
    (c) =>
      `<option value="${esc(apiCategoryIdForSlug(c.slug))}">${esc(c.label)} — General</option>`
  ).join("");
  const postLocCombobox = buildLocationComboboxHtml({
    fieldName: "location",
    storedRaw: postLocDefault,
    mode: "post",
    wrapClass: "loc-dd--post",
    btnClass: "loc-dd__btn loc-dd__btn--field"
  });

  appEl.innerHTML = `
    <div class="post-jiji post-shell">
      <p class="post-steps"><span class="is-on">Step 1 of 3</span> · Details · Photos</p>
      <header class="post-shell__head">
        <h1 class="post-shell__title">Post an ad</h1>
        <p class="post-shell__lead muted">Free listing — reviewed before it goes live.</p>
      </header>
    <form id="post-form" class="stack post-shell__form">
      <label>
        Category
        <select name="categoryId" id="post-category" required>
          ${postCategories.map((c) => {
            const apiId = c.apiId;
            return `<option value="${esc(apiId)}" ${apiId === defaultCat ? "selected" : ""}>${esc(c.label)}</option>`;
          }).join("")}
        </select>
      </label>
      <label>
        Subcategory
        <select name="subcategoryId" id="post-subcategory">${subOpts}</select>
      </label>
      <div id="event-fields" hidden>
        <label>
          Event sub-category
          <select name="eventSubCategory">${EVENT_SUBCATEGORIES.map((s) => `<option value="${esc(s)}">${esc(s)}</option>`).join("")}</select>
        </label>
        <label>Date <input name="eventDate" type="date" /></label>
        <label>Time <input name="eventTime" type="time" /></label>
        <label>Duration <input name="eventDuration" type="text" placeholder="e.g. 3 hours" /></label>
        <label>Venue / Address <input name="eventVenue" type="text" placeholder="Venue name or address" /></label>
        <label>Cover photo URL <input name="eventCover" type="url" placeholder="https://images.unsplash.com/photo-..." /></label>
        <label>Type
          <select name="eventPriceType">
            <option value="free">Free</option>
            <option value="paid">Paid</option>
          </select>
        </label>
        <label>Event price (HUF, if paid) <input name="eventPrice" type="number" min="0" step="1" /></label>
        <label>Max attendees (optional) <input name="eventCap" type="number" min="1" step="1" placeholder="Unlimited if empty" /></label>
        <label>Contact preference
          <select name="eventContact">
            <option value="message via app">Message via app</option>
            <option value="show email">Show email</option>
            <option value="show phone">Show phone</option>
          </select>
        </label>
        <label>Tags (comma separated) <input name="eventTags" type="text" placeholder="English-speaking, beginners welcome" /></label>
      </div>
      <div id="donation-fields" hidden>
        <label>
          Donation sub-category
          <select name="donationSubCategory" required>
            ${DONATION_SUBCATEGORIES.map(
              (s) => `<option value="${esc(s.key)}">${esc(s.label)}</option>`
            ).join("")}
          </select>
        </label>
        <fieldset class="filter-panel__fieldset" style="border:1px solid var(--purple-border);border-radius:8px;padding:0.75rem">
          <legend class="filter-panel__label">Condition</legend>
          ${DONATION_CONDITIONS.map(
            (c, i) =>
              `<label class="filter-panel__check"><input type="radio" name="donationCondition" value="${esc(c.key)}" ${
                i === 2 ? "checked" : ""
              } /> ${esc(c.label)}</label>`
          ).join("")}
        </fieldset>
        <label>
          Collection method
          <select name="donationCollectionMethod" id="donation-collection-method">
            ${DONATION_COLLECTION_METHODS.map(
              (m) => `<option value="${esc(m.key)}">${esc(m.label)}</option>`
            ).join("")}
          </select>
        </label>
        <label id="donation-deliveryKm-wrap" hidden>
          Delivery radius (km)
          <input name="donationDeliveryKm" type="number" min="1" max="200" step="1" placeholder="e.g. 10" />
        </label>
        <label>
          Contact preference
          <select name="donationContact">
            <option value="message via app">Message via app</option>
            <option value="show email">Show email</option>
            <option value="show phone">Show phone</option>
          </select>
        </label>
        <label>
          Quantity (if multiple of the same item)
          <input name="donationQuantity" type="number" min="1" step="1" value="1" />
        </label>
      </div>
      <label>
        Title (5+ characters)
        <input name="title" required minlength="5" placeholder="City center studio near metro" />
      </label>
      <label>
        Description (20+ characters)
        <textarea name="description" required minlength="20" rows="5" placeholder="Describe what you are offering…"></textarea>
      </label>
      <fieldset class="filter-panel__fieldset" id="post-condition-fieldset" style="border:1px solid var(--purple-border);border-radius:8px;padding:0.75rem">
        <legend class="filter-panel__label">Condition</legend>
        <label class="filter-panel__check"><input type="radio" name="condition" value="new" /> Brand New</label>
        <label class="filter-panel__check"><input type="radio" name="condition" value="used" /> Used</label>
        <label class="filter-panel__check"><input type="radio" name="condition" value="other" checked /> Other</label>
      </fieldset>
      <label id="post-price-label">
        Price (HUF, optional)
        <span class="filter-chip-row" style="margin:0.25rem 0 0"><span class="filter-chip">HUF</span></span>
        <input name="price" type="number" min="0" step="1" placeholder="Leave empty if negotiable" />
      </label>
      <label>
        Location
        ${postLocCombobox}
      </label>
      <label>
        Contact name
        <input name="contactName" type="text" placeholder="Your name" value="${esc(getUser()?.name || "")}" />
      </label>
      <label>
        Phone number
        <input name="contactPhone" type="tel" placeholder="+36 …" value="${esc(getUser()?.phone || "")}" />
      </label>
      <div id="post-cat-fields">${categoryFieldHtml(defaultCat)}</div>
      <label class="post-photo-zone">
        <span class="filter-panel__label">Photos — paste image URLs (one per line)</span>
        <textarea name="images" required rows="4" placeholder="Drag photos here or paste URLs (https://…), one per line"></textarea>
      </label>
      <div class="button-row" style="justify-content:space-between">
        <a class="btn btn--ghost" href="#/browse">Cancel</a>
        <button type="submit" class="btn btn--primary" style="border-radius:8px">Post Ad</button>
      </div>
      <p class="muted small" id="post-msg"></p>
    </form>
    </div>
  `;

  initLocationCombobox(document.querySelector("#post-form [data-loc-combobox]"));

  const catSelect = document.getElementById("post-category");
  const catFields = document.getElementById("post-cat-fields");
  const subSel = document.getElementById("post-subcategory");
  const eventFields = document.getElementById("event-fields");
  const donationFields = document.getElementById("donation-fields");
  const postPriceLabel = document.getElementById("post-price-label");
  const conditionFs = document.getElementById("post-condition-fieldset");
  catSelect?.addEventListener("change", () => {
    const isEvent = catSelect.value === EVENTS_CATEGORY;
    const isDonationPost = catSelect.value === DONATIONS_CATEGORY_ID;
    eventFields.hidden = !isEvent;
    if (donationFields) donationFields.hidden = !isDonationPost;
    catFields.hidden = isEvent || isDonationPost;
    subSel.closest("label").hidden = isEvent || isDonationPost;
    if (conditionFs) conditionFs.hidden = isEvent || isDonationPost;
    if (postPriceLabel) postPriceLabel.hidden = isDonationPost;
    if (!isEvent && !isDonationPost) {
      catFields.innerHTML = categoryFieldHtml(catSelect.value);
      if (subSel) {
        subSel.value = catSelect.value;
      }
    }
  });
  catSelect?.dispatchEvent(new Event("change"));

  document.getElementById("donation-collection-method")?.addEventListener("change", (e) => {
    const wrap = document.getElementById("donation-deliveryKm-wrap");
    if (wrap) wrap.hidden = e.target.value !== "local_delivery";
  });
  document.getElementById("donation-collection-method")?.dispatchEvent(new Event("change"));

  document.getElementById("post-form")?.addEventListener("submit", async (e) => {
    e.preventDefault();
    const form = e.target;
    const fd = new FormData(form);
    const categoryId = String(fd.get("categoryId") || "");
    const imagesRaw = String(fd.get("images") || "")
      .split(/\r?\n/)
      .map((s) => s.trim())
      .filter(Boolean);
    const isEvent = categoryId === EVENTS_CATEGORY;
    const isDonationPost = categoryId === DONATIONS_CATEGORY_ID;
    if (isEvent && String(fd.get("eventPriceType") || "free") === "paid") {
      const ep = Number(fd.get("eventPrice") ?? 0);
      if (!Number.isFinite(ep) || ep < 0) {
        throw new Error("Event price must be zero or a positive number.");
      }
    }
    if (!isDonationPost && !isEvent) {
      const rawP = fd.get("price");
      if (rawP !== null && String(rawP).trim() !== "") {
        const pn = Number(rawP);
        if (!Number.isFinite(pn) || pn < 0) {
          throw new Error("Price must be empty, zero, or a positive number.");
        }
      }
    }
    const condRaw = String(fd.get("condition") || "other");
    const condApi = isDonationPost
      ? String(fd.get("donationCondition") || "good")
      : condRaw === "new"
        ? "new"
        : condRaw === "used"
          ? "used"
          : "good";
    const payload = {
      title: String(fd.get("title") || "").trim(),
      description: String(fd.get("description") || "").trim(),
      categoryId,
      price: isDonationPost
        ? 0
        : (() => {
            const raw = fd.get("price");
            if (raw === null || String(raw).trim() === "") {
              return null;
            }
            const n = Number(raw);
            return Number.isFinite(n) && n >= 0 ? n : null;
          })(),
      currency: "HUF",
      location: String(fd.get("location") || "").trim(),
      images: imagesRaw,
      condition: condApi,
      categoryFields: buildCategoryFields(categoryId, fd),
      userId: user.id
    };
    const msg = document.getElementById("post-msg");
    msg.textContent = "";
    try {
      if (isEvent) {
        const date = String(fd.get("eventDate") || "").trim();
        const time = String(fd.get("eventTime") || "19:00").trim();
        if (!date) {
          throw new Error("Event date is required.");
        }
        const eventRow = {
          id: `ev-user-${Date.now()}`,
          title: payload.title,
          description: payload.description,
          subCategory: String(fd.get("eventSubCategory") || EVENT_SUBCATEGORIES[0]),
          dateTime: new Date(`${date}T${time}:00`).toISOString(),
          duration: String(fd.get("eventDuration") || "").trim() || "2 hours",
          city: payload.location || "Budapest",
          venue: String(fd.get("eventVenue") || "").trim() || "TBA venue",
          address: String(fd.get("eventVenue") || "").trim() || "TBA address",
          image: String(fd.get("eventCover") || "").trim() || payload.images[0] || "https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=900&q=80",
          isFree: String(fd.get("eventPriceType") || "free") !== "paid",
          price: String(fd.get("eventPriceType") || "free") === "paid" ? Number(fd.get("eventPrice") || 0) : 0,
          maxAttendees: fd.get("eventCap") ? Number(fd.get("eventCap")) : null,
          contactPreference: String(fd.get("eventContact") || "message via app"),
          tags: String(fd.get("eventTags") || "").split(",").map((s) => s.trim()).filter(Boolean),
          organizerName: user.name || "Nuvelo member",
          attendees: [{ id: user.id, name: user.name || "You", avatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=120&q=80" }]
        };
        const custom = readJsonStore(EVENTS_STORE_KEY, []);
        custom.push(eventRow);
        writeJsonStore(EVENTS_STORE_KEY, custom);
        msg.textContent = "Your event is live. Redirecting…";
        setTimeout(() => setHash(`/event/${eventRow.id}`), 700);
        return;
      }
      const created = await createListing(payload, user.id);
      msg.textContent = "Your listing is live. Redirecting…";
      setTimeout(() => setHash(`/listing/${created.id}`), 800);
    } catch (err) {
      console.error(err);
      msg.textContent = err?.message || "Could not create listing. Check your API connection and try again.";
    }
  });
};

const navDrawerEl = () => document.getElementById("nav-drawer");
const navBurgerEl = () => document.getElementById("nav-burger");

const setNavDrawerOpen = (open) => {
  const drawer = navDrawerEl();
  const burger = navBurgerEl();
  if (!drawer || !burger) {
    return;
  }
  drawer.hidden = !open;
  drawer.setAttribute("aria-hidden", open ? "false" : "true");
  burger.setAttribute("aria-expanded", open ? "true" : "false");
  document.body.classList.toggle("nav-drawer-open", open);
};

const render = async () => {
  setNavDrawerOpen(false);
  updateAuthUi();
  const route = parseHash();
  document.body.classList.toggle("is-landing", route.view === "landing");
  syncHeaderChrome(route);
  const appEl = mainShell();
  if (!appEl) {
    return;
  }
  try {
    if (route.view === "landing") {
      appEl.innerHTML = `
        <div class="page-loading" role="status" aria-live="polite" aria-busy="true">
          <span class="page-loading__spinner" aria-hidden="true"></span>
          <span class="page-loading__text">Loading…</span>
        </div>
      `;
      await renderLanding();
      return;
    }
    appEl.innerHTML = `
      <div class="page-loading" role="status" aria-live="polite" aria-busy="true">
        <span class="page-loading__spinner" aria-hidden="true"></span>
        <span class="page-loading__text">Loading…</span>
      </div>
    `;
    if (route.view === "detail") {
      await renderDetail(route.id);
      return;
    }
    if (route.view === "post") {
      await renderPost();
      return;
    }
    if (route.view === "events") {
      await renderEventsList();
      return;
    }
    if (route.view === "eventDetail") {
      await renderEventDetail(route.id);
      return;
    }
    if (route.view === "static") {
      await renderStaticPage(route.page);
      return;
    }
    await renderList();
  } catch (err) {
    console.error(err);
    appEl.innerHTML = `
      <section class="stack">
        <h2>We could not load this page.</h2>
        <p class="muted">${esc(friendlyNetworkError(err))}</p>
        <p><a href="#/">Go to home</a> · <a href="#/browse">Browse listings</a></p>
      </section>
    `;
  }
};

navBurgerEl()?.addEventListener("click", () => {
  const drawer = navDrawerEl();
  if (!drawer) {
    return;
  }
  setNavDrawerOpen(drawer.hidden);
});

document.body.addEventListener("click", (e) => {
  const btn = e.target.closest("#category-rail [data-cat]");
  if (!btn) {
    return;
  }
  const catVal = btn.getAttribute("data-cat") ?? "";
  const next = new URLSearchParams(window.location.search);
  if (catVal) {
    next.set("cat", catVal);
  } else {
    next.delete("cat");
  }
  next.delete("page");
  const qs = next.toString();
  window.history.replaceState(
    null,
    "",
    `${window.location.pathname}${qs ? `?${qs}` : ""}#/browse`
  );
  render();
});

document.body.addEventListener("click", (e) => {
  if (e.target.id === "browse-load-more") {
    const next = new URLSearchParams(window.location.search);
    const cur = Math.max(1, parseInt(next.get("page") || "1", 10) || 1);
    next.set("page", String(cur + 1));
    const qs = next.toString();
    window.history.replaceState(
      null,
      "",
      `${window.location.pathname}${qs ? `?${qs}` : ""}#/browse`
    );
    render();
    return;
  }
  const drawerLink = e.target.closest("#nav-drawer a[href]");
  if (drawerLink) {
    setNavDrawerOpen(false);
  }
  if (e.target.id === "drawer-signin" || e.target.closest("#drawer-signin")) {
    e.preventDefault();
    setNavDrawerOpen(false);
    openModal("login");
  }
});

document.body.addEventListener("change", (e) => {
  const hid = window.location.hash || "#/browse";
  if (e.target.id === "browse-sort-select") {
    const next = new URLSearchParams(window.location.search);
    next.set("sort", e.target.value);
    next.delete("page");
    const qs = next.toString();
    window.history.replaceState(
      null,
      "",
      `${window.location.pathname}${qs ? `?${qs}` : ""}${hid}`
    );
    render();
    return;
  }
  if (e.target.id === "browse-time-select") {
    const next = new URLSearchParams(window.location.search);
    const v = e.target.value;
    if (v === "any") {
      next.delete("t");
    } else {
      next.set("t", v);
    }
    next.delete("page");
    const qs = next.toString();
    window.history.replaceState(
      null,
      "",
      `${window.location.pathname}${qs ? `?${qs}` : ""}${hid}`
    );
    render();
  }
});

document.getElementById("header-search-form")?.addEventListener("submit", (e) => {
  e.preventDefault();
  const form = e.target;
  const fd = new FormData(form);
  const next = new URLSearchParams(window.location.search);
  const qq = String(fd.get("q") || "").trim();
  const loc = String(fd.get("loc") || "").trim();
  if (qq) {
    next.set("q", qq);
  } else {
    next.delete("q");
  }
  if (loc) {
    next.set("loc", loc);
  } else {
    next.delete("loc");
  }
  next.delete("page");
  browseListingsCache = { key: "", data: [] };
  const qs = next.toString();
  window.history.replaceState(
    null,
    "",
    `${window.location.pathname}${qs ? `?${qs}` : ""}#/browse`
  );
  render();
});

window.addEventListener("hashchange", render);
window.addEventListener(
  "scroll",
  () => {
    syncLandingHeaderScroll();
  },
  { passive: true }
);
document.getElementById("filter-sheet-close")?.addEventListener("click", closeFilterSheet);
document.getElementById("filter-sheet-backdrop")?.addEventListener("click", closeFilterSheet);

bindHungarianLocationGlobalHandlers();
const headerLocRootInit = document.querySelector("#header-search-form [data-loc-combobox]");
initLocationCombobox(headerLocRootInit);
syncLocationCombobox(
  headerLocRootInit,
  new URLSearchParams(window.location.search).get("loc") || ""
);

void (async () => {
  await initAuth();
  syncAuthBackendHint();
  await render().catch((e) => console.error(e));
})();
