import { DONATIONS_CATEGORY_ID } from "../data/donationConstants.js";
import { isSupabaseConfigured } from "../lib/supabaseClient.js";

const esc = (s) => {
  const d = document.createElement("div");
  d.textContent = s ?? "";
  return d.innerHTML;
};

/** @param {string} pathname */
export function getProfileSectionFromPathname(
  pathname = typeof location !== "undefined" ? location.pathname : "/"
) {
  let p = pathname || "/";
  if (p.length > 1 && p.endsWith("/")) {
    p = p.slice(0, -1);
  }
  const parts = p.replace(/^\/+/, "").split("/").filter(Boolean);
  if (parts[0] !== "profile") {
    return "adverts";
  }
  const sub = parts[1] || "adverts";
  if (sub === "statistics") {
    return "performance";
  }
  return sub;
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

/** @param {string} [iso] */
function formatMsgTime(iso) {
  if (!iso) {
    return "";
  }
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) {
    return "";
  }
  return d.toLocaleTimeString(undefined, { hour: "2-digit", minute: "2-digit" });
}

/**
 * Thread row for the messages list (server-backed threads use this shape).
 * @param {object} t
 * @param {string} t.id
 * @param {string} t.name
 * @param {string} t.listingTitle
 * @param {string} [t.thumb]
 * @param {string} t.preview
 * @param {string} t.dateLabel
 * @param {number} [t.unread]
 * @param {boolean} [t.spam]
 */
export function buildMessageThreadRowHtml(t) {
  const thumb = t.thumb
    ? `<img src="${esc(t.thumb)}" alt="" width="56" height="56" loading="lazy" />`
    : `<div class="msg-row__ph" aria-hidden="true"></div>`;
  const unread = t.unread || 0;
  const badge =
    unread > 0
      ? `<span class="msg-row__unread-badge" aria-label="${unread} unread">${esc(unread > 9 ? "9+" : String(unread))}</span>`
      : "";
  return `
    <button type="button" class="msg-row${unread ? " msg-row--unread" : ""}" data-thread-id="${esc(t.id)}" data-thread-spam="${t.spam ? "1" : ""}">
      <div class="msg-row__thumb">${thumb}</div>
      <div class="msg-row__body">
        <div class="msg-row__top">
          <span class="msg-row__name">${esc(t.name)}</span>
          <time class="msg-row__date" datetime="">${esc(t.dateLabel)}</time>
        </div>
        <p class="msg-row__listing">${esc(t.listingTitle)}</p>
        <div class="msg-row__bottom">
          <span class="msg-row__preview">${esc(t.preview)}</span>
          ${badge}
        </div>
      </div>
    </button>`;
}

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
    <a href="/listing/${encodeURIComponent(String(ad.id))}" class="advert-row advert-row--saved-card">
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
      return `<a href="/listing/${encodeURIComponent(String(ad.id))}" class="advert-row my-advert-row">${body}</a>`;
    })
    .join("");
}

/**
 * Compact avatar + name on small screens (sidebar is hidden).
 * @param {object} user
 */
export function renderProfileMobileHeader(user) {
  const name = user.name || "Member";
  const avatar = user.avatarUrl || "/default-avatar.svg";
  return `
  <div class="profile-mobile-header">
    <img class="profile-mobile-header__avatar" src="${esc(avatar)}" alt="" width="40" height="40" decoding="async" />
    <span class="profile-mobile-header__name">${esc(name)}</span>
  </div>`;
}

/**
 * Mobile-only horizontal nav (mirrors sidebar links).
 * @param {string} activeSection
 */
export function renderProfileMobileTabs(activeSection) {
  const item = (href, key, label) => {
    const active = activeSection === key ? " profile-mobile-tabs__link--active" : "";
    return `<a href="${href}" class="profile-mobile-tabs__link${active}" data-profile-tab="${esc(key)}">${esc(label)}</a>`;
  };
  return `
  <div class="profile-mobile-tabs-wrap">
    <nav class="profile-mobile-tabs" aria-label="Profile" data-profile-mobile-tabs>
      ${item("/profile/adverts", "adverts", "Ads")}
      ${item("/profile/messages", "messages", "Messages")}
      ${item("/profile/saved", "saved", "Saved")}
      ${item("/profile/performance", "performance", "Stats")}
      ${item("/profile/notifications", "notifications", "Alerts")}
      ${item("/profile/feedback", "feedback", "Feedback")}
      ${item("/profile/settings", "settings", "Settings")}
    </nav>
  </div>`;
}

/**
 * Shared left column for all profile routes (Jiji-style card + nav).
 * @param {object} user
 * @param {string} section — active profile section key
 */
export function renderProfileSidebar(user, section) {
  const name = user.name || "Member";
  const phone = user.phone || "Add phone in Settings";
  const avatar = user.avatarUrl || "/default-avatar.svg";
  const navItem = (href, key, label, emoji) => {
    const active = section === key ? " active" : "";
    return `<a href="${href}" class="profile-sidenav-item${active}">
      <span class="profile-sidenav-item__emoji" aria-hidden="true">${emoji}</span>
      <span class="profile-sidenav-item__label">${esc(label)}</span>
    </a>`;
  };

  return `
  <aside class="profile-sidebar profile-sidebar--jiji" data-profile-sidebar>
    <div class="profile-sidebar-card">
      <div class="profile-sidebar-card__head">
        <a href="/profile/settings" class="profile-settings-pill${section === "settings" ? " profile-settings-pill--active" : ""}" title="Settings">
          <span>SETTINGS</span>
          <span class="profile-settings-pill__ico" aria-hidden="true">⚙️</span>
        </a>
      </div>
      <div class="profile-identity">
        <button type="button" class="profile-avatar-ring" id="profile-sidebar-avatar-btn" aria-label="Change profile photo">
          <img src="${esc(avatar)}" alt="" class="profile-avatar-large" id="profile-sidebar-avatar-img" width="96" height="96" decoding="async" />
          <span class="profile-avatar-ring__camera" aria-hidden="true">📷</span>
        </button>
        <input type="file" id="profile-sidebar-avatar-input" accept="image/*" hidden />
        <h2 class="profile-name profile-name--jiji">${esc(name)}</h2>
        <p class="profile-phone profile-phone--accent">${esc(phone)}</p>
      </div>
      <nav class="profile-sidenav profile-sidenav--jiji">
        ${navItem("/post", "promo", "Boost your reach", "😍")}
        ${navItem("/profile/followers", "followers", "Followers", "👥")}
        ${navItem("/profile/adverts", "adverts", "My adverts", "📋")}
        ${navItem("/profile/feedback", "feedback", "Feedback", "😊")}
        ${navItem("/faq", "faq", "Frequently Asked Questions", "❓")}
      </nav>
      <div class="profile-sidenav-extra muted small">
        <p class="profile-sidenav-extra__title">Quick links</p>
        ${navItem("/profile/messages", "messages", "Messages", "💬")}
        ${navItem("/profile/saved", "saved", "Saved ads", "🔖")}
        ${navItem("/profile/notifications", "notifications", "Notifications", "🔔")}
        ${navItem("/profile/performance", "performance", "Performance", "📊")}
      </div>
      <div class="profile-sidebar__foot">
        <button type="button" class="btn btn--pill btn--signin profile-sign-out-btn" id="profile-sign-out">
          Sign out
        </button>
      </div>
    </div>
  </aside>`;
}

function renderMessagesLayout() {
  return `
    <div class="messages-jiji" data-messages-root>
      <div class="messages-jiji__left" data-msg-list-column>
        <p class="messages-jiji__banner" data-msg-banner hidden role="alert"></p>
        <h2 class="messages-jiji__title">My messages</h2>
        <label class="messages-jiji__search-wrap">
          <span class="messages-jiji__search-icon" aria-hidden="true">⌕</span>
          <input type="search" class="messages-jiji__search" placeholder="Search messages" data-msg-search autocomplete="off" />
        </label>
        <div class="messages-jiji__tabs" role="tablist" data-msg-tabs>
          <button type="button" class="messages-jiji__tab is-active" role="tab" aria-selected="true" data-msg-tab="all">All</button>
          <button type="button" class="messages-jiji__tab" role="tab" aria-selected="false" data-msg-tab="unread">Unread (0)</button>
          <button type="button" class="messages-jiji__tab" role="tab" aria-selected="false" data-msg-tab="spam">Spam (0)</button>
        </div>
        <div class="messages-jiji__empty-inbox" data-msg-empty-inbox hidden>
          <div class="messages-jiji__empty-inbox-illus" aria-hidden="true">💬</div>
          <p class="messages-jiji__empty-inbox-text">No messages yet. When someone contacts you about a listing, it will appear here.</p>
          <a href="/browse" class="btn btn--primary messages-jiji__empty-inbox-cta">Browse ads</a>
        </div>
        <div class="messages-jiji__lists" data-msg-lists-wrap>
          <div class="messages-jiji__list" data-msg-list-all role="list"></div>
          <div class="messages-jiji__list" data-msg-list-unread hidden role="list"></div>
          <div class="messages-jiji__list" data-msg-list-spam hidden role="list"></div>
        </div>
      </div>
      <div class="messages-jiji__right" data-msg-pane>
        <div class="messages-jiji__empty" data-msg-empty>
          <div class="messages-jiji__empty-illus" aria-hidden="true">💬</div>
          <p class="messages-jiji__empty-title">Select a chat to start messaging</p>
        </div>
        <div class="messages-jiji__chat" data-msg-chat hidden></div>
      </div>
    </div>`;
}

/**
 * @param {object} thread — display fields for header
 * @param {string} thread.otherDisplayName
 * @param {string} thread.listingTitle
 * @param {string} [thread.thumb]
 * @param {Array<{ sender_id: string, body: string, created_at: string }>} messages
 * @param {string} currentUserId
 */
export function buildChatPanelHtml(thread, messages, currentUserId) {
  const bubbles = (messages || [])
    .map((m) => {
      const mine = m.sender_id === currentUserId;
      const cls = mine ? "chat-bubble chat-bubble--me" : "chat-bubble chat-bubble--them";
      const tm = formatMsgTime(m.created_at);
      return `<div class="${cls}">
        <p class="chat-bubble__text">${esc(m.body)}</p>
        <time class="chat-bubble__time">${esc(tm)}</time>
      </div>`;
    })
    .join("");
  const thumb = thread.thumb
    ? `<img src="${esc(thread.thumb)}" alt="" width="40" height="40" />`
    : `<div class="chat-head__ph"></div>`;
  return `
    <header class="chat-head">
      <button type="button" class="chat-head__back" data-msg-back aria-label="Back to messages">←</button>
      <div class="chat-head__thumb">${thumb}</div>
      <div class="chat-head__meta">
        <p class="chat-head__name">${esc(thread.otherDisplayName)}</p>
        <p class="chat-head__listing">${esc(thread.listingTitle)}</p>
      </div>
    </header>
    <div class="chat-scroll" role="log" data-msg-scroll>${bubbles}</div>
    <footer class="chat-compose">
      <input type="text" class="chat-compose__input" placeholder="Type a message…" aria-label="Message" data-msg-input autocomplete="off" />
      <button type="button" class="btn btn--primary chat-compose__send" data-msg-send>Send</button>
    </footer>`;
}

function renderPerformanceSection() {
  const metrics = [
    { icon: "🖤", label: "Traffic", value: "142" },
    { icon: "🟣", label: "Visitors", value: "87" },
    { icon: "🟢", label: "Contact views", value: "34" },
    { icon: "🟠", label: "Chats", value: "12" },
    { icon: "🔵", label: "Spent on Pro Sales", value: "HUF 0" }
  ];
  const metricCards = metrics
    .map(
      (m) => `
    <div class="perf-metric-card">
      <span class="perf-metric-card__icon" aria-hidden="true">${m.icon}</span>
      <div class="perf-metric-card__body">
        <span class="perf-metric-card__label">${esc(m.label)}</span>
        <span class="perf-metric-card__value">${esc(m.value)}</span>
      </div>
    </div>`
    )
    .join("");

  return `
    <div class="perf-page" data-perf-root>
      <div class="perf-page__header">
        <h2 class="perf-page__title">Performance</h2>
        <div class="perf-page__toggles" role="group" aria-label="Period" data-perf-period>
          <button type="button" class="perf-toggle is-active" data-perf="daily">Daily ✓</button>
          <button type="button" class="perf-toggle" data-perf="weekly">Weekly</button>
          <button type="button" class="perf-toggle" data-perf="monthly">Monthly</button>
        </div>
      </div>
      <p class="perf-page__range" data-perf-range>01/04/2026 – 09/04/2026</p>
      <div class="perf-chart-wrap">
        <svg class="perf-chart" viewBox="0 0 320 120" preserveAspectRatio="none" aria-hidden="true" data-perf-chart>
          <defs>
            <linearGradient id="perfGrad" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="var(--orange)" stop-opacity="0.35"/>
              <stop offset="100%" stop-color="var(--orange)" stop-opacity="0"/>
            </linearGradient>
          </defs>
          <polygon fill="url(#perfGrad)" points="0,120 0,45 40,52 80,38 120,55 160,42 200,48 240,35 280,50 320,40 320,120"/>
          <polyline fill="none" stroke="var(--orange)" stroke-width="2.5" points="0,45 40,52 80,38 120,55 160,42 200,48 240,35 280,50 320,40"/>
        </svg>
      </div>
      <div class="perf-metrics-grid">${metricCards}</div>
      <div class="perf-summary-row">
        <a href="/profile/followers" class="perf-summary-card">
          <span class="perf-summary-card__label">New visitors</span>
          <span class="perf-summary-card__arrow" aria-hidden="true">›</span>
        </a>
        <a href="/profile/messages" class="perf-summary-card">
          <span class="perf-summary-card__label">New chats</span>
          <span class="perf-summary-card__arrow" aria-hidden="true">›</span>
        </a>
      </div>
    </div>`;
}

function renderFeedbackSection(user) {
  const uid = esc(user.id || "me");
  const profileLink = `${typeof location !== "undefined" ? location.origin : ""}/profile/adverts?ref=${uid}`;
  return `
    <div class="feedback-jiji" data-feedback-root>
      <div class="feedback-jiji__header">
        <h2 class="feedback-jiji__title">Feedback</h2>
        <div class="feedback-jiji__toggles" role="group">
          <button type="button" class="feedback-toggle is-active" data-fb-tab="received">Received (0)</button>
          <button type="button" class="feedback-toggle" data-fb-tab="sent">Sent (0)</button>
        </div>
      </div>
      <div class="feedback-jiji__panel" data-fb-panel="received">
        <div class="feedback-empty">
          <div class="feedback-empty__art" aria-hidden="true">
            <svg width="120" height="100" viewBox="0 0 120 100" fill="none" xmlns="http://www.w3.org/2000/svg">
              <ellipse cx="60" cy="88" rx="40" ry="8" fill="#e2e8f0"/>
              <path d="M30 48c0-16 13-29 30-29s30 13 30 29v12H30V48z" fill="#f1f5f9" stroke="#cbd5e1" stroke-width="2"/>
              <circle cx="48" cy="44" r="4" fill="#64748b"/>
              <circle cx="72" cy="44" r="4" fill="#64748b"/>
              <path d="M48 58c6 6 18 6 24 0" stroke="#64748b" stroke-width="2" stroke-linecap="round"/>
            </svg>
          </div>
          <p class="feedback-empty__text">There are no feedbacks yet. Ask your customers to leave feedback about you. Copy the link and send them.</p>
          <button type="button" class="btn btn--primary feedback-copy-btn" data-copy-feedback-link data-link="${esc(profileLink)}">
            Copy my link
          </button>
        </div>
      </div>
      <div class="feedback-jiji__panel" data-fb-panel="sent" hidden>
        <div class="feedback-empty">
          <p class="feedback-empty__text muted">No sent feedback yet.</p>
        </div>
      </div>
    </div>`;
}

/**
 * @param {object} user — { name, phone, avatarUrl, role, adverts?, savedAds? }
 * @param {string} [sectionFromRoute] — from router; falls back to pathname
 */
export function renderProfilePage(user, sectionFromRoute) {
  const section = sectionFromRoute || getProfileSectionFromPathname();
  const mainExtra = section === "messages" ? " profile-content--messages" : "";

  return `
<div class="profile-shell">
  ${renderProfileMobileHeader(user)}
  ${renderProfileMobileTabs(section)}
  <div class="profile-layout profile-layout--jiji">
    ${renderProfileSidebar(user, section === "settings" ? "adverts" : section)}
    <main class="profile-content profile-content--jiji profile-card${mainExtra}">
      ${renderProfileSection(section, user)}
    </main>
  </div>
</div>`;
}

function renderProfileSection(section, user) {
  switch (section) {
    case "adverts":
      return renderMyAdverts(user);
    case "saved":
      return renderSavedAds(user);
    case "messages":
      return renderMessagesLayout();
    case "notifications":
      return renderNotifications();
    case "followers":
      return renderFollowers(user);
    case "feedback":
      return renderFeedbackSection(user);
    case "performance":
      return renderPerformanceSection();
    default:
      return renderMyAdverts(user);
  }
}

function renderMyAdverts(user) {
  const real = user.adverts || [];
  const useDemo = real.length === 0 && !isSupabaseConfigured;
  const display = useDemo ? MOCK_MY_ADVERTS : real;
  const emptySignedIn =
    isSupabaseConfigured && real.length === 0
      ? `<div class="profile-empty-state">
          <p>You haven't posted any ads yet. Post your first one!</p>
          <p><a href="/post" class="btn btn--primary">Post an ad</a></p>
        </div>`
      : "";
  const listOrDemo =
    useDemo || real.length > 0
      ? `<div class="advert-row-list my-adverts-list">${renderMyAdvertRowsWithStatus(display, { demo: useDemo })}</div>`
      : emptySignedIn;
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
    ${listOrDemo}
    <div class="profile-cta-row">
      <a href="/post" class="btn btn--primary">Post an ad</a>
    </div>`;
}

function renderSavedAds(user) {
  const saved = user.savedAds || [];
  return `
    <div class="profile-section-header"><h2>Saved ads</h2></div>
    ${
      saved.length === 0
        ? `<div class="profile-empty-state"><p>No saved ads yet. Tap the heart on any listing to save it here.</p>
           <p><a href="/browse" class="btn btn--primary">Browse ads</a></p></div>`
        : `<div class="profile-saved-grid">${renderAdvertRows(saved)}</div>`
    }`;
}

function renderNotifications() {
  return `
    <div class="profile-section-header"><h2>Notifications</h2></div>
    <div class="profile-empty-state"><p>No notifications yet.</p></div>`;
}

function renderFollowers() {
  return `
    <div class="profile-section-header"><h2>Followers</h2></div>
    <div class="profile-empty-state"><p>No followers yet.</p></div>`;
}

