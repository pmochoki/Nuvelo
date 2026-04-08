import { CATEGORIES } from "./src/data/categories.js";
import { HUNGARIAN_LOCATIONS } from "./src/data/hungarianLocations.js";

/** Public API (Render). Override in console: window.__NUVELO_API__ = "https://…" */
const RENDER_API_DEFAULT = "https://nuvelo-backend.onrender.com";

const API_BASE = (() => {
  if (typeof window === "undefined") {
    return RENDER_API_DEFAULT;
  }
  const injected = window.__NUVELO_API__;
  if (injected) {
    return String(injected).replace(/\/$/, "");
  }
  const { hostname, origin } = window.location;
  if (!hostname || origin === "null") {
    return "http://localhost:4000";
  }
  if (hostname === "localhost" || hostname === "127.0.0.1") {
    return origin;
  }
  // Backend serves both site + API on Render
  if (hostname.endsWith(".onrender.com")) {
    return origin;
  }
  // Site on Vercel (or any other static host) → API stays on Render
  return RENDER_API_DEFAULT;
})();

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

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
    return "Could not connect to the server. Check your connection, or wait a minute and try again (the API may be waking up).";
  }
  return msg || "Something went wrong. Please try again.";
};

/** Helps with cold starts on free hosting (e.g. Render spin-up). */
const fetchWithRetry = async (url, init = {}, attempts = 2) => {
  let lastErr;
  for (let i = 0; i < attempts; i++) {
    try {
      return await fetch(url, init);
    } catch (err) {
      lastErr = err;
      if (i < attempts - 1) {
        await sleep(800 * (i + 1));
      }
    }
  }
  throw lastErr;
};

const STORAGE_KEY = "nuvelo_user_profile";
const VIEW_MODE_KEY = "nuvelo_list_view";
const CATEGORY_SLUGS = {
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

const appEl = document.getElementById("app");
const authBtn = document.getElementById("auth-btn");
const userChip = document.getElementById("user-chip");
const loginModal = document.getElementById("login-modal");
const loginForm = document.getElementById("login-form");

const getUser = () => {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) {
      return null;
    }
    return JSON.parse(raw);
  } catch {
    return null;
  }
};

const setUser = (profile) => {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(profile));
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
  } else {
    authBtn.hidden = false;
    if (regBtn) {
      regBtn.hidden = false;
    }
    userChip.hidden = true;
  }
};

let authModalMode = "login";

const openModal = (mode = "login") => {
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
  if (formEl) {
    formEl.hidden = mode === "signup";
  }
  if (switchBtn) {
    switchBtn.textContent =
      mode === "signup" ? "Already have an account? Sign in" : "New here? Register";
  }
  loginModal.hidden = false;
  if (mode === "login" && formEl && !formEl.hidden) {
    loginModal.querySelector("input[name='name']")?.focus();
  }
};

const closeModal = () => {
  loginModal.hidden = true;
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

document.getElementById("auth-google-stub")?.addEventListener("click", () => {
  window.alert("Google sign-in is not connected yet. Use email or phone below.");
});

document.getElementById("auth-fb-stub")?.addEventListener("click", () => {
  window.alert("Facebook sign-in is not connected yet. Use email or phone below.");
});

document.getElementById("auth-show-email-form")?.addEventListener("click", () => {
  const formEl = document.getElementById("login-form");
  if (formEl) {
    formEl.hidden = false;
    formEl.querySelector("input[name='name']")?.focus();
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
  const errEl = document.getElementById("login-error");
  const submitBtn = loginForm.querySelector("button[type='submit']");
  if (errEl) {
    errEl.textContent = "";
    errEl.hidden = true;
  }
  const fd = new FormData(loginForm);
  const name = String(fd.get("name") || "").trim();
  const role = String(fd.get("role") || "").trim();
  const email = String(fd.get("email") || "").trim() || null;
  const phone = String(fd.get("phone") || "").trim() || null;
  if (submitBtn) {
    submitBtn.disabled = true;
  }
  try {
    const res = await fetchWithRetry(
      `${API_BASE}/auth/login`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name, role, email, phone })
      },
      2
    );
    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      const text =
        err.error ||
        (res.status === 404 || res.status === 502
          ? "Sign-in service is unavailable. Please try again later."
          : "Could not sign in. Please try again.");
      if (errEl) {
        errEl.textContent = text;
        errEl.hidden = false;
      }
      return;
    }
    const profile = await res.json();
    setUser(profile);
    updateAuthUi();
    closeModal();
    setHash("/browse");
  } catch (err) {
    if (errEl) {
      errEl.textContent = friendlyNetworkError(err);
      errEl.hidden = false;
    }
  } finally {
    if (submitBtn) {
      submitBtn.disabled = false;
    }
  }
});

const esc = (s) => {
  const d = document.createElement("div");
  d.textContent = s ?? "";
  return d.innerHTML;
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

const renderLocationListHtml = (root, searchQuery) => {
  const list = root.querySelector("[data-loc-list]");
  if (!list) {
    return;
  }
  const mode = root.getAttribute("data-loc-mode") || "filter";
  const q = String(searchQuery || "").trim().toLowerCase();
  const rows = locationRowsForMode(mode);
  const filtered = !q
    ? rows
    : rows.filter(
        (r) =>
          r.label.toLowerCase().includes(q) || r.value.toLowerCase().includes(q)
      );
  list.innerHTML = filtered
    .map(
      (r) =>
        `<li role="none"><button type="button" role="option" class="loc-dd__opt" data-loc-opt data-loc-value="${esc(r.value)}" data-loc-label="${esc(r.label)}">${esc(r.label)}</button></li>`
    )
    .join("");
};

const closeLocationPanel = (root) => {
  if (!root) {
    return;
  }
  const panel = root.querySelector("[data-loc-panel]");
  const btn = root.querySelector("[data-loc-btn]");
  const search = root.querySelector("[data-loc-search]");
  root.classList.remove("is-open");
  if (panel) {
    panel.hidden = true;
  }
  if (btn) {
    btn.setAttribute("aria-expanded", "false");
  }
  if (search) {
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
  const panel = root.querySelector("[data-loc-panel]");
  const btn = root.querySelector("[data-loc-btn]");
  const search = root.querySelector("[data-loc-search]");
  root.classList.add("is-open");
  if (panel) {
    panel.hidden = false;
  }
  if (btn) {
    btn.setAttribute("aria-expanded", "true");
  }
  renderLocationListHtml(root, "");
  if (search) {
    search.value = "";
    search.focus();
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
  const list = root.querySelector("[data-loc-list]");

  root.addEventListener("click", (e) => {
    e.stopPropagation();
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
    renderLocationListHtml(root, search.value);
  });

  list?.addEventListener("click", (e) => {
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
  <button type="button" class="${btnClass}" data-loc-btn aria-haspopup="listbox" aria-expanded="false">${esc(btnText)}</button>
  <div class="loc-dd__panel" data-loc-panel hidden>
    <input type="search" class="loc-dd__search" data-loc-search placeholder="Search cities…" autocomplete="off" aria-label="Search cities" />
    <ul class="loc-dd__list" role="listbox" data-loc-list></ul>
  </div>
</div>`;
};

const fetchListings = async (params) => {
  const q = new URLSearchParams();
  if (params.query) {
    q.set("query", params.query);
  }
  if (params.categoryId) {
    q.set("categoryId", params.categoryId);
  }
  if (params.location) {
    q.set("location", params.location);
  }
  if (params.minPrice != null && params.minPrice !== "" && !Number.isNaN(Number(params.minPrice))) {
    q.set("minPrice", String(params.minPrice));
  }
  if (params.maxPrice != null && params.maxPrice !== "" && !Number.isNaN(Number(params.maxPrice))) {
    q.set("maxPrice", String(params.maxPrice));
  }
  const viewer = getUser();
  if (viewer?.id) {
    q.set("viewerId", viewer.id);
  }
  let res;
  try {
    res = await fetchWithRetry(`${API_BASE}/listings?${q.toString()}`, {}, 2);
  } catch (err) {
    throw new Error(friendlyNetworkError(err));
  }
  if (!res.ok) {
    throw new Error("Could not load listings. The server may be busy or updating.");
  }
  return res.json();
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
    copy.sort(
      (a, b) =>
        (Number(b.viewCount) || Number(b.views) || 0) -
        (Number(a.viewCount) || Number(a.views) || 0)
    );
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

const formatAdCount = (n) => {
  const x = Number(n) || 0;
  return `${new Intl.NumberFormat("en-US").format(x)} ads`;
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
    return formatAdCount(catRow.count);
  }
  const n = Number(nFromListings) || 0;
  return n > 0 ? formatAdCount(n) : "Ads";
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
    return v === "list" ? "list" : "grid";
  } catch {
    return "grid";
  }
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
  const q = getUser()?.id ? `?viewerId=${encodeURIComponent(getUser().id)}` : "";
  let res;
  try {
    res = await fetchWithRetry(
      `${API_BASE}/listings/${encodeURIComponent(id)}${q}`,
      {},
      2
    );
  } catch (err) {
    throw new Error(friendlyNetworkError(err));
  }
  if (res.status === 404) {
    return null;
  }
  if (!res.ok) {
    throw new Error("Could not load listing.");
  }
  return res.json();
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
  if (parts[0] === "browse") {
    return { view: "list" };
  }
  if (parts[0] === "category" && parts[1]) {
    const slug = parts[1].toLowerCase();
    const catId = CATEGORY_SLUGS[slug] || slug;
    return { view: "list", categorySlug: catId };
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

const syncHeaderChrome = (route) => {
  const wrap = document.getElementById("header-search-wrap");
  if (wrap) {
    wrap.hidden = route.view === "landing";
    wrap.removeAttribute("aria-hidden");
    if (wrap.hidden) {
      wrap.setAttribute("aria-hidden", "true");
    }
  }
};

const countByCategory = (listings) => {
  const m = {};
  listings.forEach((l) => {
    const id = l.categoryId || "";
    m[id] = (m[id] || 0) + 1;
  });
  return m;
};

const buildListingCardEl = (listing, opts = {}) => {
  const {
    viewMode = "grid",
    markPopular = false,
    idx = 0
  } = opts;
  const thumb = listingImageUrl(listing);
  const priceLine =
    listing.price != null
      ? `${listing.currency || "HUF"} ${listing.price}`
      : "Ask for price";
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

  const card = document.createElement("article");
  card.className = `lc lc--${viewMode === "list" ? "list" : "grid"}`;
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
      ${sellerIco}
    </div>
    <div class="lc__body">
      <p class="lc__price">${esc(priceLine)}</p>
      <h3 class="lc__title">${esc(listing.title)}</h3>
      <p class="lc__excerpt">${esc(excerpt)}</p>
      <span class="lc__cond">${esc(conditionLabel(listing.condition))}</span>
      <div class="lc__foot">
        <span>📍 ${esc(loc)}</span>
        <span>${esc(posted || "")}</span>
      </div>
    </div>
  `;
  return card;
};

const renderLanding = async () => {
  let listings = [];
  try {
    listings = await fetchListings({});
  } catch {
    listings = [];
  }
  const counts = countByCategory(listings);
  const viewMode = getListViewMode();
  const trending = sortListings([...listings], "popular").slice(0, 24);

  const catRows = CATEGORIES.map((row) => {
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
  }).join("");

  const pills = [
    `<button type="button" class="jiji-pill" data-home-pill="post">Post ad</button>`,
    `<button type="button" class="jiji-pill jiji-pill--active" data-home-pill="trending">Trending</button>`,
    ...CATEGORIES.map((row) => {
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
            <span class="jiji-promo-card jiji-promo-card--c">Verified sellers</span>
            <span class="jiji-promo-card jiji-promo-card--d">How to sell</span>
            <span class="jiji-promo-card jiji-promo-card--e">Safety tips</span>
          </div>
          <div class="jiji-pills" id="home-pills">${pills}</div>
          <section class="jiji-trending" aria-label="Trending ads">
            <div class="jiji-section-head">
              <h2>Trending ads</h2>
              <div class="jiji-view-toggle">
                <button type="button" id="home-view-grid" aria-pressed="${viewMode === "grid"}" title="Grid">⊞</button>
                <button type="button" id="home-view-list" aria-pressed="${viewMode === "list"}" title="List">☰</button>
              </div>
            </div>
            <div class="ad-grid--lc" id="home-listing-grid" data-view="${viewMode}"></div>
          </section>
        </div>
      </div>
    </div>
  `;

  const grid = document.getElementById("home-listing-grid");
  trending.forEach((listing, i) => {
    grid.appendChild(
      buildListingCardEl(listing, { viewMode, markPopular: true, idx: i })
    );
  });

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
  let error = null;
  try {
    if (browseListingsCache.key === cacheKey) {
      listings = browseListingsCache.data;
    } else {
      listings = await fetchListings(fetchFilters);
      browseListingsCache = { key: cacheKey, data: listings };
    }
  } catch (e) {
    error = friendlyNetworkError(e);
    browseListingsCache = { key: "", data: [] };
  }

  let afterBand = error ? [] : filterByPriceBand(listings, filters.priceBand);
  afterBand = error ? [] : filterBySellerPref(afterBand, filters.sellerFilter);
  const afterCondition = error
    ? []
    : filterByCondition(afterBand, filters.conditionNew, filters.conditionUsed);
  const afterTime = error ? [] : filterByTimePref(afterCondition, filters.timeFilter);
  const sorted = error ? [] : sortListings(afterTime, filters.sort);
  const totalCount = sorted.length;
  const totalPages = Math.max(1, Math.ceil(totalCount / PAGE_SIZE));
  const curPage = Math.min(Math.max(1, filters.page), totalPages);
  const start = (curPage - 1) * PAGE_SIZE;
  const pageSlice = sorted.slice(start, start + PAGE_SIZE);
  const viewMode = getListViewMode();
  const subCount = totalCount;

  const catChips = [
    `<button type="button" class="cat-chip${!filters.categoryId ? " cat-chip--active" : ""}" data-cat=""><span class="cat-chip__emoji" aria-hidden="true">✨</span><span class="cat-chip__label">All</span></button>`,
    ...CATEGORIES.map((c) => {
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
    ...CATEGORIES.map((c) => {
      const apiId = apiCategoryIdForSlug(c.slug);
      return `<option value="${esc(apiId)}"${apiId === filters.categoryId ? " selected" : ""}>${esc(c.label)}</option>`;
    })
  ].join("");

  const sortSel = filters.sort;
  const cond = filters.conditionMode;
  const prb = filters.priceBand;
  const sell = filters.sellerFilter;
  const timeSel = filters.timeFilter;

  const filterFieldsHtml = `
    <div class="filter-panel filter-panel--jiji">
      <div class="filter-section">
        <h3>Categories</h3>
        <p class="muted small" style="margin:0 0 0.5rem"><strong>${filters.categoryId ? esc(categoryDisplayName(filters.categoryId)) : "All categories"}</strong></p>
        <a href="#/browse" class="small">All in category · ${esc(formatAdCount(subCount))}</a>
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
  if (totalPages > 1 && !error) {
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
      <button type="button" class="btn btn--outline browse-filter-btn-mobile" id="browse-filter-open">Filters</button>
      ${error ? `<div class="banner-error" role="alert">${esc(error)}</div>` : ""}
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
          <div class="jiji-section-head" style="margin-bottom:0.5rem">
            <span></span>
            <div class="jiji-view-toggle">
              <button type="button" id="browse-view-grid" aria-pressed="${viewMode === "grid"}">⊞</button>
              <button type="button" id="browse-view-list" aria-pressed="${viewMode === "list"}">☰</button>
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

  if (!pageSlice.length && !error) {
    grid.innerHTML = `<div class="empty-state">No ads match your filters yet.</div>`;
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
  let listing = null;
  let error = null;
  try {
    listing = await fetchListing(id);
  } catch (e) {
    error = friendlyNetworkError(e);
  }
  if (error) {
    appEl.innerHTML = `<div class="banner-error" role="alert">${esc(error)}</div>
      <p><a href="#/browse">← Back to listings</a></p>`;
    return;
  }
  if (!listing) {
    appEl.innerHTML = `<p>Listing not found. <a href="#/browse">Back to browse</a></p>`;
    return;
  }

  const fields = listing.categoryFields || {};
  const fieldRows = Object.keys(fields).length
    ? `<ul class="field-list">${Object.entries(fields)
        .map(
          ([k, v]) =>
            `<li><span>${esc(k)}</span><span>${esc(String(v))}</span></li>`
        )
        .join("")}</ul>`
    : "";

  const imgs = (listing.images || []).filter(
    (u) => typeof u === "string" && /^https?:\/\//i.test(u)
  );
  const mainSrc = imgs[0] || "";
  const views = Number(listing.viewCount) || Number(listing.views) || 0;
  const priceStr =
    listing.price != null
      ? `${esc(listing.currency || "HUF")} ${esc(String(listing.price))}`
      : "Contact for price";
  const posted = formatPostedTime(listing.createdAt);
  const bcTitle = excerptOneLine(listing.title, 40);
  const descRaw = String(listing.description || "");
  const descLong = descRaw.length > 320;
  const catBrowseHref = `${window.location.pathname}?cat=${encodeURIComponent(listing.categoryId)}#/browse`;

  appEl.innerHTML = `
    <nav class="breadcrumb-jiji" aria-label="Breadcrumb">
      <a href="#/browse">All ads</a> ›
      <a href="${catBrowseHref}">${esc(categoryDisplayName(listing.categoryId))}</a> ›
      <span class="muted">${esc(bcTitle)}</span>
    </nav>
    <div class="detail-jiji-wrap">
      <div class="detail-jiji-main">
        <div class="detail-gallery">
          <div class="detail-gallery__main">
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
          <span class="pill">${esc(conditionLabel(listing.condition))}</span>
          <span class="pill">${esc(categoryDisplayName(listing.categoryId))}</span>
        </div>
        <h1 style="margin:0 0 0.5rem;font-size:1.5rem">${esc(listing.title)}</h1>
        <section>
          <h2 class="site-footer__heading" style="margin-top:1rem">Description</h2>
          <p class="desc-long ${descLong ? "is-collapsed" : ""}" id="detail-desc">${esc(listing.description)}</p>
          ${descLong ? `<button type="button" class="btn btn--link" id="detail-desc-more">Show more</button>` : ""}
        </section>
        ${fieldRows ? `<section><h2 class="site-footer__heading" style="margin-top:1rem">Details</h2>${fieldRows}</section>` : ""}
        <section class="detail-safety">
          <strong>Safety tips</strong>
          <ul>
            <li>Avoid sending prepayments</li>
            <li>Meet in a public place</li>
            <li>Inspect before paying</li>
            <li>Check all documents</li>
          </ul>
        </section>
        <p class="small" style="margin-top:1rem"><a href="#/post" class="btn btn--link">Post ad like this</a></p>
      </div>
      <aside class="detail-jiji-aside">
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
      </aside>
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
    try {
      const res = await fetchWithRetry(
        `${API_BASE}/conversations`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            listingId: listing.id,
            buyerId: user.id,
            sellerId: listing.userId
          })
        },
        2
      );
      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err.error || "Could not start conversation.");
      }
      msg.textContent =
        "Conversation started. Open the Nuvelo app to continue messaging.";
    } catch (e) {
      msg.textContent = friendlyNetworkError(e);
    }
  });
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
  }
  return out;
};

const renderPost = async () => {
  const user = getUser();
  if (!user) {
    appEl.innerHTML = `
      <div class="post-shell">
        <header class="post-shell__head">
          <h1 class="post-shell__title">Post an ad</h1>
          <p class="post-shell__lead muted">Sign in to publish. Your ad is reviewed before it appears.</p>
        </header>
      <button type="button" class="btn btn--primary btn--lg" id="post-signin">Sign in to continue</button>
      </div>
    `;
    document.getElementById("post-signin")?.addEventListener("click", () => openModal("login"));
    return;
  }

  const defaultCat = apiCategoryIdForSlug(CATEGORIES[0].slug);
  const postLocDefault =
    HUNGARIAN_LOCATIONS.find((r) => r.value === "budapest")?.label || "Budapest";
  const subOpts = CATEGORIES.map(
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
          ${CATEGORIES.map((c) => {
            const apiId = apiCategoryIdForSlug(c.slug);
            return `<option value="${esc(apiId)}" ${apiId === defaultCat ? "selected" : ""}>${esc(c.label)}</option>`;
          }).join("")}
        </select>
      </label>
      <label>
        Subcategory
        <select name="subcategoryId" id="post-subcategory">${subOpts}</select>
      </label>
      <label>
        Title (5+ characters)
        <input name="title" required minlength="5" placeholder="City center studio near metro" />
      </label>
      <label>
        Description (20+ characters)
        <textarea name="description" required minlength="20" rows="5" placeholder="Describe what you are offering…"></textarea>
      </label>
      <fieldset class="filter-panel__fieldset" style="border:1px solid var(--purple-border);border-radius:8px;padding:0.75rem">
        <legend class="filter-panel__label">Condition</legend>
        <label class="filter-panel__check"><input type="radio" name="condition" value="new" /> Brand New</label>
        <label class="filter-panel__check"><input type="radio" name="condition" value="used" /> Used</label>
        <label class="filter-panel__check"><input type="radio" name="condition" value="other" checked /> Other</label>
      </fieldset>
      <label>
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
  catSelect?.addEventListener("change", () => {
    catFields.innerHTML = categoryFieldHtml(catSelect.value);
    if (subSel) {
      subSel.value = catSelect.value;
    }
  });

  document.getElementById("post-form")?.addEventListener("submit", async (e) => {
    e.preventDefault();
    const form = e.target;
    const fd = new FormData(form);
    const categoryId = String(fd.get("categoryId") || "");
    const imagesRaw = String(fd.get("images") || "")
      .split(/\r?\n/)
      .map((s) => s.trim())
      .filter(Boolean);
    const condRaw = String(fd.get("condition") || "other");
    const condApi =
      condRaw === "new" ? "new" : condRaw === "used" ? "used" : "good";
    const payload = {
      title: String(fd.get("title") || "").trim(),
      description: String(fd.get("description") || "").trim(),
      categoryId,
      price: fd.get("price") ? Number(fd.get("price")) : null,
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
      const res = await fetchWithRetry(
        `${API_BASE}/listings`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(payload)
        },
        2
      );
      if (!res.ok) {
        const body = await res.json().catch(() => ({}));
        const text = Array.isArray(body.errors)
          ? body.errors.join(" ")
          : body.error || "Could not create listing.";
        msg.textContent = text;
        return;
      }
      const created = await res.json();
      msg.textContent =
        "Listing submitted as pending moderation. Thank you!";
      setTimeout(() => setHash(`/listing/${created.id}`), 800);
    } catch (err) {
      msg.textContent = friendlyNetworkError(err);
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
  if (route.view === "landing") {
    renderLanding();
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
  await renderList();
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
document.getElementById("filter-sheet-close")?.addEventListener("click", closeFilterSheet);
document.getElementById("filter-sheet-backdrop")?.addEventListener("click", closeFilterSheet);

bindHungarianLocationGlobalHandlers();
const headerLocRootInit = document.querySelector("#header-search-form [data-loc-combobox]");
initLocationCombobox(headerLocRootInit);
syncLocationCombobox(
  headerLocRootInit,
  new URLSearchParams(window.location.search).get("loc") || ""
);

updateAuthUi();
render();
