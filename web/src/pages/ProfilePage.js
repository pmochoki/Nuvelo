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
    <a href="#/listing/${encodeURIComponent(String(ad.id))}" class="advert-row">
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
    case "settings":
      return renderSettings(user);
    case "feedback":
      return renderFeedback(user);
    default:
      return renderMyAdverts(user);
  }
}

function renderMyAdverts(user) {
  const ads = user.adverts || [];
  return `
    <div class="profile-section-header">
      <h2>My adverts</h2>
    </div>
    ${
      ads.length === 0
        ? `<div class="profile-empty-state">
           <p>There are no adverts yet. Create new one now!</p>
           <a href="#/post" class="btn btn--primary">Post an ad</a>
         </div>`
        : `<div class="advert-row-list">${renderAdvertRows(ads)}</div>`
    }`;
}

function renderSavedAds(user) {
  const saved = user.savedAds || [];
  return `
    <div class="profile-section-header"><h2>Saved ads</h2></div>
    ${
      saved.length === 0
        ? `<div class="profile-empty-state"><p>No saved ads yet. Browse and save listings you like.</p>
           <p><a href="#/browse" class="btn btn--primary">Browse ads</a></p></div>`
        : `<div class="advert-row-list">${renderAdvertRows(saved)}</div>`
    }`;
}

function renderMessages() {
  return `
    <div class="profile-section-header"><h2>Messages</h2></div>
    <div class="profile-empty-state"><p>No messages yet.</p></div>`;
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

function renderFeedback() {
  return `
    <div class="profile-section-header"><h2>Feedback</h2></div>
    <div class="profile-empty-state">
      <p>We’d love to hear from you. A feedback form will be available here soon.</p>
      <p><a href="#/contact" class="btn btn--primary">Contact us</a></p>
    </div>`;
}

function renderSettings(user) {
  return `
    <div class="profile-section-header"><h2>Settings</h2></div>
    <div class="profile-settings-panel">
      <p class="muted">Account details</p>
      <ul class="profile-settings-list">
        <li><span class="profile-settings-k">Name</span> <span class="profile-settings-v">${esc(user.name)}</span></li>
        <li><span class="profile-settings-k">Role</span> <span class="profile-settings-v">${esc(user.role || "")}</span></li>
        <li><span class="profile-settings-k">Phone</span> <span class="profile-settings-v">${esc(user.phone || "—")}</span></li>
        <li><span class="profile-settings-k">Email</span> <span class="profile-settings-v">${esc(user.email || "—")}</span></li>
      </ul>
      <p class="muted small">More preferences will be added here later.</p>
    </div>`;
}
