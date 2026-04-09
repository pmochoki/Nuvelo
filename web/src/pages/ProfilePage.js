import { DONATIONS_CATEGORY_ID } from "../data/donationConstants.js";

const esc = (s) => {
  const d = document.createElement("div");
  d.textContent = s ?? "";
  return d.innerHTML;
};

/** @param {string} hash */
export function getProfileSectionFromHash(hash = typeof location !== "undefined" ? location.hash : "") {
  const parts = hash.replace(/^#\/?/, "").split("/").filter(Boolean);
  if (parts[0] !== "profile") {
    return "adverts";
  }
  return parts[1] || "adverts";
}

function listingThumb(listing) {
  const u = listing.images?.[0];
  return typeof u === "string" && /^https?:\/\//i.test(u) ? u : "";
}

function formatShortTime(iso) {
  if (!iso) {
    return "—";
  }
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) {
    return "—";
  }
  return d.toLocaleString(undefined, {
    month: "short",
    day: "numeric",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit"
  });
}

const MOCK_MESSAGE_THREADS = [
  {
    id: "mock-peter",
    name: "Péter",
    initial: "P",
    preview: "Is this still available?",
    time: "Today · 2:14 PM",
    unread: 2
  },
  {
    id: "mock-anna",
    name: "Anna",
    initial: "A",
    preview: "I can pick it up tomorrow, what time works?",
    time: "Yesterday · 6:02 PM",
    unread: 0
  },
  {
    id: "mock-zsofi",
    name: "Zsófi",
    initial: "Z",
    preview: "Thanks — sending photos now.",
    time: "Mon · 10:22 AM",
    unread: 1
  }
];

const MOCK_NOTIFICATIONS = [
  {
    id: "n1",
    text: "Your ad “Dog Walking” has been approved.",
    time: "Today · 9:05 AM",
    unread: true
  },
  {
    id: "n2",
    text: "Péter sent you a message.",
    time: "Today · 2:14 PM",
    unread: true
  },
  {
    id: "n3",
    text: "Your ad has 5 new views.",
    time: "Yesterday · 4:40 PM",
    unread: false
  }
];

const MOCK_MY_ADVERTS = [
  {
    id: "demo-my-1",
    title: "Vintage desk lamp",
    categoryLabel: "Electronics",
    status: "Active",
    createdAt: "2026-04-06T14:20:00.000Z",
    location: "Budapest",
    price: 12000,
    images: ["https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?w=200&q=80"]
  },
  {
    id: "demo-my-2",
    title: "Mountain bike 29″",
    categoryLabel: "Vehicles",
    status: "Pending review",
    createdAt: "2026-04-07T09:00:00.000Z",
    location: "Debrecen",
    price: 85000,
    images: ["https://images.unsplash.com/photo-1576435728678-68d0fbf94e91?w=200&q=80"]
  },
  {
    id: "demo-my-3",
    title: "Hungarian lesson — 1h",
    categoryLabel: "Services",
    status: "Active",
    createdAt: "2026-03-28T11:30:00.000Z",
    location: "Szeged",
    price: 4500,
    images: []
  }
];

function priceLineForListing(listing) {
  if (listing.categoryId === DONATIONS_CATEGORY_ID) {
    return "FREE";
  }
  const p = listing.price;
  if (p == null) {
    return "Contact for price";
  }
  const n = Number(p);
  if (!Number.isFinite(n) || n < 0) {
    return "Contact for price";
  }
  return `HUF ${n.toLocaleString("hu-HU")}`;
}

function renderAdvertRows(listings) {
  return listings
    .map(
      (ad) => `
    <a href="#/listing/${encodeURIComponent(String(ad.id))}" class="advert-row advert-row--saved-card">
      <div class="advert-row__media">
        ${
          listingThumb(ad)
            ? `<img src="${esc(listingThumb(ad))}" alt="" width="96" height="96" loading="lazy" />`
            : `<div class="advert-row__ph" aria-hidden="true"></div>`
        }
      </div>
      <div class="advert-row__body">
        <h3 class="advert-row__title">${esc(ad.title)}</h3>
        <p class="advert-row__meta">${esc(ad.location || "")}</p>
        <p class="advert-row__price">${esc(priceLineForListing(ad))}</p>
      </div>
    </a>`
    )
    .join("");
}

function statusClassForAdvert(status) {
  const s = String(status || "active").toLowerCase().replace(/\s+/g, "-");
  if (s.includes("pending")) {
    return "pending";
  }
  if (s.includes("reject")) {
    return "rejected";
  }
  return "active";
}

function renderMyAdvertRowsWithStatus(listings, { demo = false } = {}) {
  return listings
    .map((ad) => {
      const status = ad.status || (demo ? "Active" : "Approved");
      const sc = statusClassForAdvert(status);
      const cat = esc(ad.categoryLabel || ad.categoryId || "—");
      const posted = formatShortTime(ad.createdAt);
      const thumb = listingThumb(ad);
      const media = thumb
        ? `<img src="${esc(thumb)}" alt="" width="96" height="96" loading="lazy" />`
        : `<div class="advert-row__ph" aria-hidden="true"></div>`;
      const body = `
      <div class="advert-row__media">${media}</div>
      <div class="advert-row__body">
        <span class="advert-status advert-status--${esc(sc)}">${esc(status)}</span>
        <h3 class="advert-row__title">${esc(ad.title)}</h3>
        <p class="advert-row__meta">${cat}</p>
        <p class="advert-row__posted">${esc(posted)}</p>
      </div>`;
      if (demo) {
        return `<div class="advert-row advert-row--demo" role="article">${body}</div>`;
      }
      return `<a href="#/listing/${encodeURIComponent(String(ad.id))}" class="advert-row my-advert-row">${body}</a>`;
    })
    .join("");
}

/**
 * @param {object} user — { name, phone, avatarUrl, role, adverts?, savedAds? }
 * @param {string} [sectionFromRoute] — from router; falls back to hash
 */
export function renderProfilePage(user, sectionFromRoute) {
  const section = sectionFromRoute || getProfileSectionFromHash();

  return `
<div class="profile-layout">

  <aside class="profile-sidebar">
    <div class="profile-sidebar-header">
      <a href="#/profile/settings" class="profile-settings-link" title="Settings">
        <span>SETTINGS</span>
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="12" r="3"/>
          <path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/>
        </svg>
      </a>
    </div>

    <div class="profile-avatar-block">
      <img src="${esc(user.avatarUrl || "/default-avatar.svg")}"
           alt="${esc(user.name)}"
           class="profile-avatar-large"/>
      <h2 class="profile-name">${esc(user.name)}</h2>
      <p class="profile-phone">${esc(user.phone || "")}</p>
    </div>

    <nav class="profile-sidenav">
      <a href="#/profile/saved" class="profile-sidenav-item ${section === "saved" ? "active" : ""}">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M19 21l-7-5-7 5V5a2 2 0 012-2h10a2 2 0 012 2z"/>
        </svg>
        Saved ads
      </a>

      <a href="#/profile/messages" class="profile-sidenav-item ${section === "messages" ? "active" : ""}">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/>
        </svg>
        Messages
      </a>

      <a href="#/profile/notifications" class="profile-sidenav-item ${section === "notifications" ? "active" : ""}">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/>
          <path d="M13.73 21a2 2 0 01-3.46 0"/>
        </svg>
        Notifications
      </a>

      <a href="#/profile/adverts" class="profile-sidenav-item ${section === "adverts" ? "active" : ""}">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <rect x="3" y="3" width="18" height="18" rx="2"/>
          <line x1="3" y1="9" x2="21" y2="9"/>
          <line x1="9" y1="3" x2="9" y2="21"/>
        </svg>
        My adverts
      </a>

      <a href="#/profile/followers" class="profile-sidenav-item ${section === "followers" ? "active" : ""}">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/>
          <circle cx="9" cy="7" r="4"/>
          <path d="M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75"/>
        </svg>
        Followers
      </a>

      <a href="#/profile/feedback" class="profile-sidenav-item ${section === "feedback" ? "active" : ""}">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="12" r="10"/>
          <path d="M8 14s1.5 2 4 2 4-2 4-2M9 9h.01M15 9h.01"/>
        </svg>
        Feedback
      </a>

      <a href="#/faq" class="profile-sidenav-item">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="12" r="10"/>
          <path d="M9.09 9a3 3 0 015.83 1c0 2-3 3-3 3M12 17h.01"/>
        </svg>
        Frequently Asked Questions
      </a>
    </nav>

    <div class="profile-sidebar__foot">
      <button type="button" class="btn btn--pill btn--signin profile-sign-out-btn" id="profile-sign-out">
        Sign out
      </button>
    </div>
  </aside>

  <main class="profile-content">
    ${renderProfileSection(section, user)}
  </main>

</div>`;
}

function renderProfileSection(section, user) {
  switch (section) {
    case "adverts":
      return renderMyAdverts(user);
    case "saved":
      return renderSavedAds(user);
    case "messages":
      return renderMessages(user);
    case "notifications":
      return renderNotifications(user);
    case "followers":
      return renderFollowers(user);
    case "feedback":
      return renderFeedback(user);
    default:
      return renderMyAdverts(user);
  }
}

function renderMyAdverts(user) {
  const real = user.adverts || [];
  const useDemo = real.length === 0;
  const display = useDemo ? MOCK_MY_ADVERTS : real;
  return `
    <div class="profile-section-header profile-section-header--row">
      <h2>My adverts</h2>
      ${useDemo ? `<span class="profile-pill profile-pill--demo">Sample</span>` : ""}
    </div>
    ${
      useDemo
        ? `<p class="muted small profile-hint">These are example listings. Post your own ad to manage it here.</p>`
        : ""
    }
    <div class="advert-row-list my-adverts-list">${renderMyAdvertRowsWithStatus(display, { demo: useDemo })}</div>
    <div class="profile-cta-row">
      <a href="#/post" class="btn btn--primary">Post an ad</a>
    </div>`;
}

function renderSavedAds(user) {
  const saved = user.savedAds || [];
  return `
    <div class="profile-section-header"><h2>Saved ads</h2></div>
    ${
      saved.length === 0
        ? `<div class="profile-empty-state"><p>No saved ads yet. Tap the heart on any listing to save it here.</p>
           <p><a href="#/browse" class="btn btn--primary">Browse ads</a></p></div>`
        : `<div class="profile-saved-grid">${renderAdvertRows(saved)}</div>`
    }`;
}

function renderMessages() {
  const rows = MOCK_MESSAGE_THREADS.map(
    (t) => `
    <button type="button" class="msg-thread${t.unread ? " msg-thread--unread" : ""}">
      <span class="msg-thread__avatar" aria-hidden="true">${esc(t.initial)}</span>
      <span class="msg-thread__main">
        <span class="msg-thread__top">
          <span class="msg-thread__name">${esc(t.name)}</span>
          <time class="msg-thread__time">${esc(t.time)}</time>
        </span>
        <span class="msg-thread__preview">${esc(t.preview)}</span>
      </span>
      ${
        t.unread
          ? `<span class="msg-thread__badge" aria-label="${t.unread} unread">${esc(String(t.unread > 9 ? "9+" : t.unread))}</span>`
          : ""
      }
    </button>`
  ).join("");
  return `
    <div class="profile-section-header"><h2>Messages</h2></div>
    <div class="messages-inbox" role="list">${rows}</div>
    <p class="muted small profile-hint">Preview threads — full chat is coming soon.</p>`;
}

function renderNotifications() {
  const items = MOCK_NOTIFICATIONS.map(
    (n) => `
    <div class="notif-item${n.unread ? " notif-item--unread" : ""}" role="listitem">
      <span class="notif-item__dot" aria-hidden="true"></span>
      <div class="notif-item__body">
        <p class="notif-item__text">${esc(n.text)}</p>
        <time class="notif-item__time">${esc(n.time)}</time>
      </div>
    </div>`
  ).join("");
  return `
    <div class="profile-section-header"><h2>Notifications</h2></div>
    <div class="notif-list" role="list">${items}</div>
    <p class="muted small profile-hint">Sample notifications — preferences will be configurable later.</p>`;
}

function renderFollowers() {
  return `
    <div class="profile-section-header"><h2>Followers</h2></div>
    <div class="profile-empty-state"><p>No followers yet.</p></div>`;
}

function renderFeedback() {
  return `
    <div class="profile-section-header"><h2>Feedback</h2></div>
    <div class="profile-empty-state">
      <p>We’d love to hear from you. A feedback form will be available here soon.</p>
      <p><a href="#/contact" class="btn btn--primary">Contact us</a></p>
    </div>`;
}
