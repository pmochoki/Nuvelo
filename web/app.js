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

const STORAGE_KEY = "nuvelo_user_profile";

const appEl = document.getElementById("app");
const authBtn = document.getElementById("auth-btn");
const userChip = document.getElementById("user-chip");
const loginModal = document.getElementById("login-modal");
const loginForm = document.getElementById("login-form");

let categoriesCache = [];

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
  if (user) {
    authBtn.hidden = true;
    userChip.hidden = false;
    userChip.textContent = `${user.name} · ${user.role}`;
  } else {
    authBtn.hidden = false;
    userChip.hidden = true;
  }
};

const openModal = (mode = "login") => {
  const titleEl = document.getElementById("login-title");
  const subEl = document.getElementById("login-subtitle");
  if (titleEl) {
    titleEl.textContent = mode === "signup" ? "Sign up" : "Log in";
  }
  if (subEl) {
    subEl.textContent =
      mode === "signup"
        ? "Create your Nuvelo profile to post listings and message sellers."
        : "Use the same name and email as before to reconnect to your listings.";
  }
  loginModal.hidden = false;
  loginModal.querySelector("input[name='name']")?.focus();
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
  openModal();
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
  const fd = new FormData(loginForm);
  const name = String(fd.get("name") || "").trim();
  const role = String(fd.get("role") || "").trim();
  const email = String(fd.get("email") || "").trim() || null;
  const phone = String(fd.get("phone") || "").trim() || null;
  const res = await fetch(`${API_BASE}/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name, role, email, phone })
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    window.alert(err.error || "Sign-in failed.");
    return;
  }
  const profile = await res.json();
  setUser(profile);
  updateAuthUi();
  closeModal();
  setHash("/browse");
});

const esc = (s) => {
  const d = document.createElement("div");
  d.textContent = s ?? "";
  return d.innerHTML;
};

const fetchCategories = async () => {
  if (categoriesCache.length) {
    return categoriesCache;
  }
  const res = await fetch(`${API_BASE}/categories`);
  if (!res.ok) {
    throw new Error("Could not load categories.");
  }
  categoriesCache = await res.json();
  return categoriesCache;
};

const fetchListings = (params) => {
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
  const viewer = getUser();
  if (viewer?.id) {
    q.set("viewerId", viewer.id);
  }
  return fetch(`${API_BASE}/listings?${q.toString()}`).then((r) => {
    if (!r.ok) {
      throw new Error("Could not load listings.");
    }
    return r.json();
  });
};

const fetchListing = (id) =>
  fetch(
    `${API_BASE}/listings/${encodeURIComponent(id)}${getUser()?.id ? `?viewerId=${encodeURIComponent(getUser().id)}` : ""}`
  ).then((r) => {
    if (r.status === 404) {
      return null;
    }
    if (!r.ok) {
      throw new Error("Could not load listing.");
    }
    return r.json();
  });

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
  return { view: "landing" };
};

const setHash = (path) => {
  window.location.hash = path.startsWith("#") ? path : `#${path}`;
};

const categoryName = (id) =>
  categoriesCache.find((c) => c.id === id)?.name || id;

const categoryIcon = (id) => {
  const map = {
    rentals: "🏠",
    jobs: "💼",
    clothes: "👕",
    services: "🛠️",
    electronics: "📱",
    vehicles: "🚗",
    "real-estate": "🏢"
  };
  return map[id] || "📦";
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
  }
};

const renderLanding = () => {
  appEl.innerHTML = `
    <section class="landing" aria-label="Nuvelo">
      <img
        class="landing__logo"
        src="./nuvelo-logo.svg"
        width="500"
        height="220"
        alt="Nuvelo — Nice vibes only"
      />
      <p class="landing__tagline">
        Rentals, jobs, services &amp; goods — for Hungary’s international community.
      </p>
      <div class="landing__actions">
        <button type="button" class="btn btn--primary btn--lg" id="landing-login">
          Log in
        </button>
        <button type="button" class="btn btn--outline btn--lg" id="landing-signup">
          Sign up
        </button>
      </div>
      <p class="landing__guest">
        <button type="button" class="btn btn--link" id="landing-browse">
          Browse without an account
        </button>
      </p>
    </section>
  `;
  document.getElementById("landing-login")?.addEventListener("click", () => {
    openModal("login");
  });
  document.getElementById("landing-signup")?.addEventListener("click", () => {
    openModal("signup");
  });
  document.getElementById("landing-browse")?.addEventListener("click", () => {
    setHash("/browse");
  });
};

const renderList = async () => {
  await fetchCategories().catch(() => {});
  const params = new URLSearchParams(window.location.search);
  const filters = {
    query: params.get("q") || "",
    categoryId: params.get("cat") || "",
    location: params.get("loc") || ""
  };

  const hf = document.getElementById("header-search-form");
  if (hf?.elements?.q && hf?.elements?.loc) {
    hf.elements.q.value = filters.query;
    hf.elements.loc.value = filters.location;
  }

  let listings = [];
  let error = null;
  try {
    listings = await fetchListings(filters);
  } catch (e) {
    error = e.message;
  }

  const catChips = [
    `<button type="button" class="cat-chip${!filters.categoryId ? " cat-chip--active" : ""}" data-cat=""><span class="cat-chip__emoji" aria-hidden="true">✨</span><span class="cat-chip__label">All</span></button>`,
    ...categoriesCache.map((c) => {
      const active = c.id === filters.categoryId ? " cat-chip--active" : "";
      return `<button type="button" class="cat-chip${active}" data-cat="${esc(c.id)}"><span class="cat-chip__emoji" aria-hidden="true">${categoryIcon(c.id)}</span><span class="cat-chip__label">${esc(c.name)}</span></button>`;
    })
  ].join("");

  const feedTitle = filters.location
    ? `Ads in ${esc(filters.location)}`
    : "Popular in Hungary";

  appEl.innerHTML = `
    <div class="feed-layout">
      <div class="category-rail-wrap">
        <div class="category-rail" id="category-rail" role="tablist" aria-label="Categories">
          ${catChips}
        </div>
      </div>
      <div class="feed-head">
        <h1 class="feed-head__title">${feedTitle}</h1>
        <p class="feed-head__sub muted">Free classifieds · rentals, jobs, services &amp; more</p>
      </div>
      ${error ? `<div class="banner-error">${esc(error)}</div>` : ""}
      <div class="ad-grid" id="listing-cards"></div>
    </div>
  `;

  const grid = document.getElementById("listing-cards");
  if (!listings.length) {
    grid.innerHTML = `<div class="empty-state">No ads match your filters yet. Try another category or search.</div>`;
    return;
  }

  listings.forEach((listing) => {
    const thumb = listingImageUrl(listing);
    const imgBlock = thumb
      ? `<img class="ad-card__img" src="${esc(thumb)}" alt="" loading="lazy" decoding="async" />`
      : `<div class="ad-card__img ad-card__img--ph" aria-hidden="true"></div>`;
    const priceLine =
      listing.price != null
        ? `${esc(listing.currency || "HUF")} ${esc(String(listing.price))}`
        : "Ask for price";

    const card = document.createElement("article");
    card.className = "ad-card";
    card.tabIndex = 0;
    card.setAttribute("role", "link");
    card.setAttribute(
      "aria-label",
      `${listing.title}, ${priceLine}, ${listing.location}`
    );
    card.innerHTML = `
      <div class="ad-card__media">${imgBlock}</div>
      <div class="ad-card__body">
        <p class="ad-card__price">${priceLine}</p>
        <h2 class="ad-card__title">${esc(listing.title)}</h2>
        <p class="ad-card__meta">${esc(listing.location)} · ${esc(listing.sellerName || "Seller")}</p>
        <span class="ad-card__cat">${esc(categoryName(listing.categoryId))}</span>
      </div>
    `;
    const go = () => setHash(`/listing/${listing.id}`);
    card.addEventListener("click", go);
    card.addEventListener("keydown", (ev) => {
      if (ev.key === "Enter" || ev.key === " ") {
        ev.preventDefault();
        go();
      }
    });
    grid.appendChild(card);
  });
};

const renderDetail = async (id) => {
  await fetchCategories().catch(() => {});
  let listing = null;
  let error = null;
  try {
    listing = await fetchListing(id);
  } catch (e) {
    error = e.message;
  }
  if (error) {
    appEl.innerHTML = `<div class="banner-error">${esc(error)}</div>
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

  const heroImg = listingImageUrl(listing);
  const heroBlock = heroImg
    ? `<div class="detail-hero"><img class="detail-hero__img" src="${esc(heroImg)}" alt="" /></div>`
    : "";

  appEl.innerHTML = `
    <article class="detail detail--jiji">
      <p class="detail-back"><a href="#/browse">← All ads</a></p>
      ${heroBlock}
      <p class="pill">${esc(categoryName(listing.categoryId))}</p>
      <h1>${esc(listing.title)}</h1>
      <p class="lead">${esc(listing.location)} · ${esc(listing.sellerName || "Seller")}</p>
      <p class="price-tag" style="font-size:1.25rem;margin-bottom:1rem">
        ${listing.price != null ? `${esc(listing.currency || "HUF")} ${esc(String(listing.price))}` : "Contact for price"}
      </p>
      <p>${esc(listing.description)}</p>
      ${fieldRows}
      <div class="button-row" style="margin-top:1.5rem">
        <button type="button" class="btn btn--primary" id="detail-contact">Start conversation</button>
      </div>
      <p class="muted small" id="detail-contact-msg" style="margin-top:0.75rem"></p>
    </article>
  `;

  document.getElementById("detail-contact")?.addEventListener("click", async () => {
    const user = getUser();
    const msg = document.getElementById("detail-contact-msg");
    if (!user) {
      msg.textContent = "Sign in first to message the seller.";
      openModal();
      return;
    }
    if (user.id === listing.userId) {
      msg.textContent = "This is your listing.";
      return;
    }
    try {
      const res = await fetch(`${API_BASE}/conversations`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          listingId: listing.id,
          buyerId: user.id,
          sellerId: listing.userId
        })
      });
      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err.error || "Could not start conversation.");
      }
      msg.textContent =
        "Conversation started. Open the Nuvelo app to continue messaging.";
    } catch (e) {
      msg.textContent = e.message || "Something went wrong.";
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
    document.getElementById("post-signin")?.addEventListener("click", openModal);
    return;
  }

  await fetchCategories().catch(() => {});
  const defaultCat = categoriesCache[0]?.id || "clothes";

  appEl.innerHTML = `
    <div class="post-shell">
      <header class="post-shell__head">
        <h1 class="post-shell__title">Post an ad</h1>
        <p class="post-shell__lead muted">Free listing — reviewed before it goes live.</p>
      </header>
    <form id="post-form" class="stack post-shell__form">
      <label>
        Title (5+ characters)
        <input name="title" required minlength="5" placeholder="City center studio near metro" />
      </label>
      <label>
        Description (20+ characters)
        <textarea name="description" required minlength="20" placeholder="Describe what you are offering…"></textarea>
      </label>
      <label>
        Category
        <select name="categoryId" id="post-category">
          ${categoriesCache
            .map(
              (c) =>
                `<option value="${esc(c.id)}" ${c.id === defaultCat ? "selected" : ""}>${esc(c.name)}</option>`
            )
            .join("")}
        </select>
      </label>
      <div id="post-cat-fields">${categoryFieldHtml(defaultCat)}</div>
      <label>
        Price (optional, HUF)
        <input name="price" type="number" min="0" step="1" placeholder="Leave empty if negotiable" />
      </label>
      <label>
        Location
        <input name="location" required placeholder="Budapest" />
      </label>
      <label>
        Condition
        <select name="condition">
          <option value="new">New</option>
          <option value="good" selected>Good</option>
          <option value="used">Used</option>
        </select>
      </label>
      <label>
        Image URLs (one per line, at least one)
        <textarea name="images" required rows="3" placeholder="https://…"></textarea>
      </label>
      <div class="button-row">
        <a class="btn btn--ghost" href="#/browse">Cancel</a>
        <button type="submit" class="btn btn--primary">Submit for review</button>
      </div>
      <p class="muted small" id="post-msg"></p>
    </form>
    </div>
  `;

  const catSelect = document.getElementById("post-category");
  const catFields = document.getElementById("post-cat-fields");
  catSelect?.addEventListener("change", () => {
    catFields.innerHTML = categoryFieldHtml(catSelect.value);
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
    const payload = {
      title: String(fd.get("title") || "").trim(),
      description: String(fd.get("description") || "").trim(),
      categoryId,
      price: fd.get("price") ? Number(fd.get("price")) : null,
      currency: "HUF",
      location: String(fd.get("location") || "").trim(),
      images: imagesRaw,
      condition: String(fd.get("condition") || "good"),
      categoryFields: buildCategoryFields(categoryId, fd),
      userId: user.id
    };
    const msg = document.getElementById("post-msg");
    msg.textContent = "";
    const res = await fetch(`${API_BASE}/listings`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });
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
  });
};

const render = async () => {
  updateAuthUi();
  const route = parseHash();
  if (route.view === "landing" && getUser()) {
    setHash("/browse");
    return;
  }
  document.body.classList.toggle("is-landing", route.view === "landing");
  syncHeaderChrome(route);
  if (route.view === "landing") {
    renderLanding();
    return;
  }
  appEl.innerHTML = `<p class="muted">Loading…</p>`;
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
  const qs = next.toString();
  window.history.replaceState(
    null,
    "",
    `${window.location.pathname}${qs ? `?${qs}` : ""}#/browse`
  );
  render();
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
  const qs = next.toString();
  window.history.replaceState(
    null,
    "",
    `${window.location.pathname}${qs ? `?${qs}` : ""}#/browse`
  );
  render();
});

window.addEventListener("hashchange", render);
updateAuthUi();
render();
