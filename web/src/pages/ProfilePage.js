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

/** Mock chat threads — Hungary marketplace; at least 2 with unread > 0 */
export const MOCK_MESSAGE_THREADS = [
  {
    id: "mock-dog",
    name: "Krisztina M.",
    listingTitle: "Dog walking — Újbuda, flexible hours",
    thumb: "https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=120&h=120&fit=crop&q=80",
    preview: "Is this still available for next week?",
    dateLabel: "8 Apr",
    unread: 2,
    spam: false,
    messages: [
      { from: "them", text: "Hi! Is this still available for next week?", time: "14:02" },
      { from: "me", text: "Yes, I’m free Tue–Thu afternoons.", time: "14:18" },
      { from: "them", text: "Perfect — could we meet near Kosztolányi tér?", time: "14:20" }
    ]
  },
  {
    id: "mock-flat",
    name: "András T.",
    listingTitle: "2 BR apartment · near Nyugati",
    thumb: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=120&h=120&fit=crop&q=80",
    preview: "Can we schedule a viewing on Saturday morning?",
    dateLabel: "7 Apr",
    unread: 0,
    spam: false,
    messages: [
      { from: "them", text: "Can we schedule a viewing on Saturday morning?", time: "10:05" },
      { from: "me", text: "Saturday works — 10:30?", time: "10:12" },
      { from: "them", text: "Yes, see you at the building entrance.", time: "10:14" }
    ]
  },
  {
    id: "mock-car",
    name: "Péter K.",
    listingTitle: "VW Golf 7 — low mileage, HUF negotiable",
    thumb: "https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=120&h=120&fit=crop&q=80",
    preview: "Still interested if the service book is complete.",
    dateLabel: "6 Apr",
    unread: 1,
    spam: false,
    messages: [
      { from: "them", text: "Still interested if the service book is complete.", time: "18:40" },
      { from: "me", text: "Full VW history, two keys. Want photos of the underside?", time: "18:55" }
    ]
  },
  {
    id: "mock-bike",
    name: "Anna L.",
    listingTitle: "City bike 28″ — lights included",
    thumb: "https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=120&h=120&fit=crop&q=80",
    preview: "I can pick it up tomorrow — what time works?",
    dateLabel: "5 Apr",
    unread: 0,
    spam: false,
    messages: [
      { from: "them", text: "I can pick it up tomorrow — what time works?", time: "19:12" },
      { from: "me", text: "After 17:00 near Blaha Lujza tér works for me.", time: "19:30" }
    ]
  },
  {
    id: "mock-spam",
    name: "Promo Deals",
    listingTitle: "WIN IPHONE CLICK HERE!!!",
    thumb: "",
    preview: "Congratulations! Claim your prize now…",
    dateLabel: "3 Apr",
    unread: 0,
    spam: true,
    messages: [{ from: "them", text: "Congratulations! Claim your prize now…", time: "08:00" }]
  }
];

/** Sum of unread counts for nav badge (demo) */
export function getMockUnreadMessageTotal() {
  return MOCK_MESSAGE_THREADS.filter((t) => !t.spam).reduce((sum, t) => sum + (t.unread || 0), 0);
}

export function getMockUnreadThreadCount() {
  return MOCK_MESSAGE_THREADS.filter((t) => !t.spam && t.unread > 0).length;
}

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
 * Mobile-only horizontal nav (mirrors sidebar links).
 * @param {string} activeSection
 */
export function renderProfileMobileTabs(activeSection) {
  const item = (href, key, label) => {
    const active = activeSection === key ? " profile-mobile-tabs__link--active" : "";
    return `<a href="${href}" class="profile-mobile-tabs__link${active}" data-profile-tab="${esc(key)}">${esc(label)}</a>`;
  };
  return `
  <nav class="profile-mobile-tabs" aria-label="Profile" data-profile-mobile-tabs>
    ${item("#/profile/adverts", "adverts", "Ads")}
    ${item("#/profile/messages", "messages", "Messages")}
    ${item("#/profile/saved", "saved", "Saved")}
    ${item("#/profile/performance", "performance", "Stats")}
    ${item("#/profile/notifications", "notifications", "Alerts")}
    ${item("#/profile/feedback", "feedback", "Feedback")}
    ${item("#/profile/settings", "settings", "Settings")}
  </nav>`;
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
        <a href="#/profile/settings" class="profile-settings-pill${section === "settings" ? " profile-settings-pill--active" : ""}" title="Settings">
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
        ${navItem("#/post", "promo", "Boost your reach", "😍")}
        ${navItem("#/profile/followers", "followers", "Followers", "👥")}
        ${navItem("#/profile/adverts", "adverts", "My adverts", "📋")}
        ${navItem("#/profile/feedback", "feedback", "Feedback", "😊")}
        ${navItem("#/faq", "faq", "Frequently Asked Questions", "❓")}
      </nav>
      <div class="profile-sidenav-extra muted small">
        <p class="profile-sidenav-extra__title">Quick links</p>
        ${navItem("#/profile/messages", "messages", "Messages", "💬")}
        ${navItem("#/profile/saved", "saved", "Saved ads", "🔖")}
        ${navItem("#/profile/notifications", "notifications", "Notifications", "🔔")}
        ${navItem("#/profile/performance", "performance", "Performance", "📊")}
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
  const unreadThreads = getMockUnreadThreadCount();
  const threads = MOCK_MESSAGE_THREADS.filter((t) => !t.spam);
  const spamThreads = MOCK_MESSAGE_THREADS.filter((t) => t.spam);

  const threadRow = (t) => {
    const thumb = t.thumb
      ? `<img src="${esc(t.thumb)}" alt="" width="56" height="56" loading="lazy" />`
      : `<div class="msg-row__ph" aria-hidden="true"></div>`;
    const badge =
      t.unread > 0
        ? `<span class="msg-row__unread-badge" aria-label="${t.unread} unread">${esc(t.unread > 9 ? "9+" : String(t.unread))}</span>`
        : "";
    return `
    <button type="button" class="msg-row${t.unread ? " msg-row--unread" : ""}" data-thread-id="${esc(t.id)}" data-thread-spam="${t.spam ? "1" : ""}">
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
  };

  const listHtml = threads.map(threadRow).join("");
  const spamHtml = spamThreads.map(threadRow).join("");

  return `
    <div class="messages-jiji" data-messages-root>
      <div class="messages-jiji__left">
        <h2 class="messages-jiji__title">My messages</h2>
        <label class="messages-jiji__search-wrap">
          <span class="messages-jiji__search-icon" aria-hidden="true">⌕</span>
          <input type="search" class="messages-jiji__search" placeholder="Search messages" data-msg-search autocomplete="off" />
        </label>
        <div class="messages-jiji__tabs" role="tablist" data-msg-tabs>
          <button type="button" class="messages-jiji__tab is-active" role="tab" aria-selected="true" data-msg-tab="all">All</button>
          <button type="button" class="messages-jiji__tab" role="tab" aria-selected="false" data-msg-tab="unread">Unread (${unreadThreads})</button>
          <button type="button" class="messages-jiji__tab" role="tab" aria-selected="false" data-msg-tab="spam">Spam (${spamThreads.length})</button>
        </div>
        <div class="messages-jiji__list" data-msg-list-all role="list">${listHtml}</div>
        <div class="messages-jiji__list" data-msg-list-unread hidden role="list">${threads.filter((t) => t.unread > 0).map(threadRow).join("")}</div>
        <div class="messages-jiji__list" data-msg-list-spam hidden role="list">${spamHtml}</div>
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

function renderChatPanel(threadId) {
  const t = MOCK_MESSAGE_THREADS.find((x) => x.id === threadId);
  if (!t) {
    return "";
  }
  const bubbles = (t.messages || [])
    .map((m) => {
      const cls = m.from === "me" ? "chat-bubble chat-bubble--me" : "chat-bubble chat-bubble--them";
      return `<div class="${cls}">
        <p class="chat-bubble__text">${esc(m.text)}</p>
        <time class="chat-bubble__time">${esc(m.time)}</time>
      </div>`;
    })
    .join("");
  const thumb = t.thumb
    ? `<img src="${esc(t.thumb)}" alt="" width="40" height="40" />`
    : `<div class="chat-head__ph"></div>`;
  return `
    <header class="chat-head">
      <div class="chat-head__thumb">${thumb}</div>
      <div class="chat-head__meta">
        <p class="chat-head__name">${esc(t.name)}</p>
        <p class="chat-head__listing">${esc(t.listingTitle)}</p>
      </div>
    </header>
    <div class="chat-scroll" role="log">${bubbles}</div>
    <footer class="chat-compose">
      <input type="text" class="chat-compose__input" disabled placeholder="Replies coming soon…" aria-label="Message" />
      <button type="button" class="btn btn--primary chat-compose__send" disabled>Send</button>
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
        <a href="#/profile/followers" class="perf-summary-card">
          <span>New visitors</span>
          <span class="perf-summary-card__arrow" aria-hidden="true">›</span>
        </a>
        <a href="#/profile/messages" class="perf-summary-card">
          <span>New chats</span>
          <span class="perf-summary-card__arrow" aria-hidden="true">›</span>
        </a>
      </div>
    </div>`;
}

function renderFeedbackSection(user) {
  const uid = esc(user.id || "me");
  const profileLink = `${typeof location !== "undefined" ? location.origin : ""}${typeof location !== "undefined" ? location.pathname : "/"}#/profile/adverts?ref=${uid}`;
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
 * @param {string} [sectionFromRoute] — from router; falls back to hash
 */
export function renderProfilePage(user, sectionFromRoute) {
  const section = sectionFromRoute || getProfileSectionFromHash();
  const mainExtra = section === "messages" ? " profile-content--messages" : "";

  return `
<div class="profile-shell">
  ${renderProfileMobileTabs(section)}
  <div class="profile-layout profile-layout--jiji">
    ${renderProfileSidebar(user, section === "settings" ? "adverts" : section)}
    <main class="profile-content profile-content--jiji${mainExtra}">
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
      return renderNotifications(user);
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

/** Expose chat HTML for client-side thread switching */
export function getMessageChatHtml(threadId) {
  return renderChatPanel(threadId);
}
