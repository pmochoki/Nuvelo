import { DONATIONS_CATEGORY_ID } from "../data/donationConstants.js";
import { tfn } from "../i18n/format.js";
import { t } from "../i18n/i18n.js";
import {
  CHAT_EMOJIS,
  formatMessageBodyHtml,
  interleaveChatDateSeparators,
  QUICK_REPLY_KEYS
} from "../lib/chatUi.js";
import { formatNumber, formatPrice } from "../utils/format.js";

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
  const sub = parts[1] || "hub";
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
 * @param {boolean} [t.listingClosed]
 * @param {string} [t.otherAvatar]
 */
export function buildMessageThreadRowHtml(t) {
  const thumb = t.thumb
    ? `<img src="${esc(t.thumb)}" alt="" width="56" height="56" loading="lazy" />`
    : `<div class="msg-row__ph" aria-hidden="true"></div>`;
  const avatarOverlay = t.otherAvatar
    ? `<img class="msg-row__avatar-overlay" src="${esc(t.otherAvatar)}" alt="" width="20" height="20" loading="lazy" />`
    : `<span class="msg-row__avatar-overlay msg-row__avatar-overlay--ph" aria-hidden="true"></span>`;
  const unread = t.unread || 0;
  const badge =
    unread > 0
      ? `<span class="msg-row__unread-badge" aria-label="${esc(formatNumber(unread))} ${esc(t("msg.unread_badge"))}">${esc(unread > 9 ? "9+" : formatNumber(unread))}</span>`
      : "";
  const closedTag = t.listingClosed
    ? `<span class="msg-row__closed-tag">${esc(t("chat.closed"))}</span>`
    : "";
  return `
    <button type="button" class="msg-row${unread ? " msg-row--unread" : ""}" data-thread-id="${esc(t.id)}" data-thread-spam="${t.spam ? "1" : ""}">
      <div class="msg-row__thumb-wrap">
        <div class="msg-row__thumb">${thumb}</div>
        ${avatarOverlay}
      </div>
      <div class="msg-row__body">
        <div class="msg-row__top">
          <span class="msg-row__name">${esc(t.name)}</span>
          <time class="msg-row__date" datetime="">${esc(t.dateLabel)}</time>
        </div>
        <p class="msg-row__listing-title">${esc(t.listingTitle)} ${closedTag}</p>
        <div class="msg-row__bottom">
          <span class="msg-row__preview">${esc(t.preview)}</span>
          ${badge}
        </div>
      </div>
    </button>`;
}

/**
 * @param {{ sender_id: string, body: string, displayBody?: string, created_at?: string }} m
 * @param {string} currentUserId
 */
export function buildChatBubbleHtml(m, currentUserId) {
  const mine = m.sender_id === currentUserId;
  const cls = mine ? "chat-bubble chat-bubble--me" : "chat-bubble chat-bubble--them";
  const tm = formatMsgTime(m.created_at);
  const displayText = m.displayBody ?? m.body;
  const translated =
    !mine && m.displayBody && m.displayBody.trim() !== String(m.body || "").trim();
  const translatedTag = translated
    ? `<span class="chat-bubble__translated muted small">${esc(t("chat.translated"))}</span>`
    : "";
  return `<div class="${cls}">
        ${formatMessageBodyHtml(displayText)}
        ${translatedTag}
        <time class="chat-bubble__time">${esc(tm)}</time>
      </div>`;
}

/**
 * @param {object} ctx
 * @param {string} ctx.otherDisplayName
 * @param {string} [ctx.otherAvatarUrl]
 */
export function buildChatSafetyBannersHtml() {
  return `
    <div class="chat-safety-banners" role="note">
      <p class="chat-safety-banner chat-safety-banner--warn">
        <span class="chat-safety-banner__ico" aria-hidden="true">📣</span>
        <span>${esc(t("chat.safety.no_prepay"))}</span>
      </p>
      <p class="chat-safety-banner chat-safety-banner--tip">
        <span class="chat-safety-banner__ico" aria-hidden="true">📞</span>
        <span>${esc(t("chat.safety.call_slow"))}</span>
      </p>
    </div>`;
}

/**
 * @param {object} ctx
 * @param {string} ctx.listingTitle
 * @param {string} [ctx.thumb]
 * @param {string} ctx.priceLabel
 * @param {boolean} [ctx.listingClosed]
 * @param {string} [ctx.listingHref]
 * @param {boolean} [ctx.hasContact]
 */
export function buildChatListingBarHtml(ctx) {
  const thumb = ctx.thumb
    ? `<img src="${esc(ctx.thumb)}" alt="" width="48" height="48" loading="lazy" />`
    : `<div class="chat-listing-bar__ph" aria-hidden="true"></div>`;
  const closed = ctx.listingClosed
    ? `<span class="chat-listing-bar__closed">${esc(t("chat.closed"))}</span>`
    : "";
  const contactBtn = ctx.hasContact
    ? `<button type="button" class="chat-listing-bar__contact" data-chat-show-contact>
        <span class="chat-listing-bar__contact-ico" aria-hidden="true">📞</span>
        ${esc(t("detail.show_contact"))}
      </button>`
    : "";
  const titleInner = ctx.listingHref
    ? `<a href="${esc(ctx.listingHref)}" class="chat-listing-bar__title-link">${esc(ctx.listingTitle)}</a>`
    : `<span class="chat-listing-bar__title-link">${esc(ctx.listingTitle)}</span>`;
  return `
    <div class="chat-listing-bar" data-chat-listing-bar>
      <div class="chat-listing-bar__thumb">${thumb}</div>
      <div class="chat-listing-bar__meta">
        <p class="chat-listing-bar__title">${titleInner} ${closed}</p>
        <p class="chat-listing-bar__price">${esc(ctx.priceLabel)}</p>
        <div class="chat-listing-bar__contact-reveal" data-chat-contact-reveal hidden></div>
      </div>
      ${contactBtn}
    </div>`;
}

function buildChatQuickRepliesHtml() {
  const chips = QUICK_REPLY_KEYS.map(
    (key) =>
      `<button type="button" class="chat-quick-reply" data-chat-quick="${esc(t(key))}">${esc(t(key))}</button>`
  ).join("");
  return `<div class="chat-quick-replies" data-chat-quick-row role="group" aria-label="${esc(t("chat.quick.aria"))}">${chips}</div>`;
}

function buildChatEmojiPickerHtml() {
  const cells = CHAT_EMOJIS.map(
    (emo) => `<button type="button" class="chat-emoji-picker__btn" data-chat-emoji="${emo}" aria-label="${emo}">${emo}</button>`
  ).join("");
  return `<div class="chat-emoji-picker" data-chat-emoji-picker hidden>${cells}</div>`;
}

function priceMarkupForListing(listing) {
  if (listing.categoryId === DONATIONS_CATEGORY_ID) {
    return esc(t("listing.free"));
  }
  const p = listing.price;
  if (p == null) {
    return esc(t("listing.contact_price"));
  }
  const n = Number(p);
  if (!Number.isFinite(n) || n < 0) {
    return esc(t("listing.contact_price"));
  }
  return `<span data-price="${String(Math.round(n))}">${esc(formatPrice(n))}</span>`;
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
        <p class="advert-row__price">${priceMarkupForListing(ad)}</p>
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

function renderMyAdvertRowsWithStatus(listings) {
  return listings
    .map((ad) => {
      const status = ad.status || "Approved";
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
      return `<a href="/listing/${encodeURIComponent(String(ad.id))}" class="advert-row my-advert-row">${body}</a>`;
    })
    .join("");
}

/**
 * Compact avatar + name on small screens (sidebar is hidden).
 * @param {object} user
 */
export function renderProfileMobileHeader(user) {
  const name = user.name || t("profile.member");
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
    <nav class="profile-mobile-tabs" aria-label="${esc(t("profile.nav_a11y"))}" data-profile-mobile-tabs>
      ${item("/profile", "hub", t("profile.tab.home"))}
      ${item("/profile/adverts", "adverts", t("profile.ads"))}
      ${item("/profile/messages", "messages", t("profile.messages"))}
      ${item("/profile/saved", "saved", t("profile.saved"))}
      ${item("/profile/performance", "performance", t("profile.stats"))}
      ${item("/profile/notifications", "notifications", t("profile.alerts"))}
      ${item("/profile/feedback", "feedback", t("profile.feedback"))}
      ${item("/profile/settings", "settings", t("nav.settings"))}
    </nav>
  </div>`;
}

/** Visible on phone — sign out on every profile tab regardless of auth provider. */
export function renderProfileMobileSignOutRow() {
  return `
  <div class="profile-mobile-signout-row">
    <button type="button" class="profile-mobile-signout-row__btn" data-nuvelo-signout>
      ${esc(t("nav.signout"))}
    </button>
  </div>`;
}

/**
 * Shared left column for all profile routes (Jiji-style card + nav).
 * @param {object} user
 * @param {string} section — active profile section key
 */
export function renderProfileSidebar(user, section) {
  const name = user.name || t("profile.member");
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
        <a href="/profile/settings" class="profile-settings-pill${section === "settings" ? " profile-settings-pill--active" : ""}" title="${esc(t("nav.settings"))}">
          <span>${esc(t("profile.settings_pill"))}</span>
          <span class="profile-settings-pill__ico" aria-hidden="true">⚙️</span>
        </a>
      </div>
      <div class="profile-identity">
        <button type="button" class="profile-avatar-ring" id="profile-sidebar-avatar-btn" aria-label="${esc(t("profile.change_photo"))}">
          <img src="${esc(avatar)}" alt="" class="profile-avatar-large" id="profile-sidebar-avatar-img" width="96" height="96" decoding="async" />
          <span class="profile-avatar-ring__camera" aria-hidden="true">📷</span>
        </button>
        <input type="file" id="profile-sidebar-avatar-input" accept="image/*" hidden />
        <h2 class="profile-name profile-name--jiji">${esc(name)}</h2>
      </div>
      <nav class="profile-sidenav profile-sidenav--jiji">
        ${navItem("/post", "promo", t("profile.boost"), "😍")}
        ${navItem("/profile/followers", "followers", t("profile.followers"), "👥")}
        ${navItem("/profile/adverts", "adverts", t("nav.adverts"), "📋")}
        ${navItem("/profile/feedback", "feedback", t("profile.feedback"), "😊")}
        ${navItem("/faq", "faq", t("profile.faq_long"), "❓")}
      </nav>
      <div class="profile-sidenav-extra muted small">
        <p class="profile-sidenav-extra__title">${esc(t("profile.quick_links"))}</p>
        ${navItem("/profile/messages", "messages", t("nav.messages"), "💬")}
        ${navItem("/profile/saved", "saved", t("nav.saved"), "🔖")}
        ${navItem("/profile/notifications", "notifications", t("nav.notifications"), "🔔")}
        ${navItem("/profile/performance", "performance", t("profile.performance_nav"), "📊")}
      </div>
      <div class="profile-sidebar__foot">
        <button type="button" class="btn btn--pill btn--signin profile-sign-out-btn" id="profile-sign-out" data-nuvelo-signout>
          ${esc(t("nav.signout"))}
        </button>
      </div>
    </div>
  </aside>`;
}

/**
 * Jiji-style profile hub: back, avatar + name, settings (mobile-first; also used in main column).
 * @param {object} user
 */
export function renderProfileHubToolbar(user) {
  const name = user.name || t("profile.member");
  const avatar = user.avatarUrl || "/default-avatar.svg";
  return `
  <header class="profile-hub-toolbar" aria-label="${esc(t("profile.nav_a11y"))}">
    <a href="/" class="profile-hub-toolbar__back" aria-label="${esc(t("profile.back_home"))}">‹</a>
    <div class="profile-hub-toolbar__identity">
      <button type="button" class="profile-hub-toolbar__avatar-btn" id="profile-hub-avatar-btn" aria-label="${esc(t("profile.change_photo"))}">
        <img class="profile-hub-toolbar__avatar" src="${esc(avatar)}" alt="" width="40" height="40" decoding="async" id="profile-hub-avatar-img" />
      </button>
      <input type="file" id="profile-hub-avatar-input" accept="image/*" hidden />
      <span class="profile-hub-toolbar__name">${esc(name)}</span>
    </div>
    <a href="/profile/settings" class="profile-hub-toolbar__settings">
      <span class="profile-hub-toolbar__settings-label">${esc(t("nav.settings"))}</span>
      <span class="profile-hub-toolbar__settings-ico" aria-hidden="true">⚙</span>
    </a>
  </header>`;
}

/**
 * Dashboard card grid (Jiji-style) for /profile hub.
 * @param {object} user
 */
function renderProfileHub(user) {
  const row = (href, title, emoji, badge) => {
    const b =
      badge != null && badge !== ""
        ? `<span class="profile-hub-card__badge">${esc(badge)}</span>`
        : "";
    return `<a href="${href}" class="profile-hub-card__row">
      <span class="profile-hub-card__row-emoji" aria-hidden="true">${emoji}</span>
      <span class="profile-hub-card__row-label">${esc(title)}</span>
      ${b}
      <span class="profile-hub-card__chev" aria-hidden="true">›</span>
    </a>`;
  };
  return `
  <div class="profile-hub-page" data-profile-hub>
    ${renderProfileHubToolbar(user)}
    <div class="profile-hub__bg">
      <a href="/post" class="profile-hub-hero">
        <span class="profile-hub-hero__emoji" aria-hidden="true">🤑</span>
        <span class="profile-hub-hero__text">${esc(t("profile.hub_post"))}</span>
        <span class="profile-hub-hero__chev" aria-hidden="true">›</span>
      </a>
      <div class="profile-hub__columns">
        <div class="profile-hub-card profile-hub-card--stack">
          ${row("/browse", t("profile.hub_browse"), "🛵", "")}
          ${row("/profile/notifications", t("profile.hub_notif"), "🔔", "")}
          ${row("/profile/followers", t("profile.hub_followers"), "👤", "")}
        </div>
        <div class="profile-hub-card profile-hub-card--stack">
          ${row("/profile/adverts", t("profile.hub_adverts"), "📋", "")}
          ${row("/profile/feedback", t("profile.hub_feedback"), "💬", "")}
        </div>
      </div>
      <div class="profile-hub__faq-wrap">
        <a href="/faq" class="profile-hub-card profile-hub-card--single">
          <span class="profile-hub-card__row-emoji" aria-hidden="true">❓</span>
          <span class="profile-hub-card__row-label">${esc(t("profile.hub_faq"))}</span>
          <span class="profile-hub-card__chev" aria-hidden="true">›</span>
        </a>
      </div>
    </div>
    <a href="/contact" class="profile-hub-fab" aria-label="${esc(t("profile.help_contact"))}">
      <span class="profile-hub-fab__ico" aria-hidden="true">?</span>
    </a>
  </div>`;
}

function renderMessagesLayout() {
  const searchIcon = `<svg class="messages-jiji__search-svg" width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true">
    <circle cx="11" cy="11" r="7" stroke="currentColor" stroke-width="2"/>
    <path d="M20 20l-4.3-4.3" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
  </svg>`;
  const backIcon = `<svg class="messages-jiji__back-svg" width="22" height="22" viewBox="0 0 24 24" fill="none" aria-hidden="true">
    <path d="M15 18l-6-6 6-6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>`;
  return `
    <div class="messages-jiji" data-messages-root>
      <div class="messages-jiji__left" data-msg-list-column>
        <header class="messages-jiji__shell" aria-label="${esc(t("messages.toolbar"))}">
          <a href="/" class="messages-jiji__back-link">${backIcon}</a>
          <label class="messages-jiji__search-shell">
            ${searchIcon}
            <input
              type="search"
              class="messages-jiji__search"
              placeholder="${esc(t("messages.search_in"))}"
              data-msg-search
              autocomplete="off"
              aria-label="${esc(t("messages.search_in"))}"
            />
          </label>
        </header>
        <p class="messages-jiji__banner" data-msg-banner hidden role="alert"></p>
        <h1 class="visually-hidden">${esc(t("messages.visually_hidden"))}</h1>
        <div class="messages-jiji__tabs" role="tablist" data-msg-tabs>
          <button type="button" class="messages-jiji__tab is-active" role="tab" aria-selected="true" data-msg-tab="all">${esc(t("messages.all"))}</button>
          <button type="button" class="messages-jiji__tab" role="tab" aria-selected="false" data-msg-tab="unread">${esc(tfn("messages.unread_count", 0))}</button>
          <button type="button" class="messages-jiji__tab" role="tab" aria-selected="false" data-msg-tab="spam">${esc(tfn("messages.spam_count", 0))}</button>
        </div>
        <p class="messages-jiji__translate-hint muted small" data-msg-translate-hint hidden>${esc(t("messages.auto_translate_hint"))}</p>
        <div class="messages-jiji__empty-inbox" data-msg-empty-inbox hidden>
          <div class="messages-jiji__empty-inbox-illus" aria-hidden="true">💬</div>
          <p class="messages-jiji__empty-inbox-text">${esc(t("messages.empty_inbox"))}</p>
          <a href="/browse" class="btn btn--primary messages-jiji__empty-inbox-cta">${esc(t("saved.browse"))}</a>
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
          <p class="messages-jiji__empty-title">${esc(t("messages.empty"))}</p>
        </div>
        <div class="messages-jiji__chat" data-msg-chat hidden></div>
      </div>
    </div>`;
}

/**
 * @param {object} thread — display fields for header + listing bar
 * @param {string} thread.otherDisplayName
 * @param {string} thread.listingTitle
 * @param {string} [thread.thumb]
 * @param {string} thread.priceLabel
 * @param {boolean} [thread.listingClosed]
 * @param {string} [thread.listingHref]
 * @param {boolean} [thread.hasContact]
 * @param {string} [thread.otherAvatarUrl]
 * @param {Array<{ sender_id: string, body: string, created_at: string }>} messages
 * @param {string} currentUserId
 */
export function buildChatPanelHtml(thread, messages, currentUserId) {
  const scrollHtml = interleaveChatDateSeparators(messages || [], (m) =>
    buildChatBubbleHtml(m, currentUserId)
  );
  const avatar = thread.otherAvatarUrl
    ? `<img src="${esc(thread.otherAvatarUrl)}" alt="" width="36" height="36" />`
    : `<span class="chat-head__avatar-ph" aria-hidden="true"></span>`;
  return `
    <header class="chat-head">
      <button type="button" class="chat-head__back" data-msg-back aria-label="${esc(t("chat.back_messages"))}">←</button>
      <div class="chat-head__avatar">${avatar}</div>
      <div class="chat-head__meta">
        <p class="chat-head__name">${esc(thread.otherDisplayName)}</p>
        <p class="chat-head__status muted small" data-chat-status hidden>${esc(t("chat.connecting"))}</p>
      </div>
    </header>
    ${buildChatListingBarHtml({
      listingTitle: thread.listingTitle,
      thumb: thread.thumb,
      priceLabel: thread.priceLabel,
      listingClosed: thread.listingClosed,
      listingHref: thread.listingHref,
      hasContact: thread.hasContact
    })}
    <div class="chat-scroll" role="log" data-msg-scroll>
      ${buildChatSafetyBannersHtml()}
      ${scrollHtml}
    </div>
    ${buildChatQuickRepliesHtml()}
    ${buildChatEmojiPickerHtml()}
    <footer class="chat-compose">
      <button type="button" class="chat-compose__icon-btn" data-chat-emoji-toggle aria-label="${esc(t("chat.emoji"))}" title="${esc(t("chat.emoji"))}">😊</button>
      <label class="chat-compose__attach">
        <input type="file" accept="image/jpeg,image/png,image/webp,.jpg,.jpeg,.png,.webp" data-chat-attach hidden />
        <span class="chat-compose__icon-btn" role="button" tabindex="0" aria-label="${esc(t("chat.attach_image"))}" title="${esc(t("chat.attach_image"))}">📎</span>
      </label>
      <input type="text" class="chat-compose__input" placeholder="${esc(t("chat.placeholder"))}" aria-label="${esc(t("chat.message_aria"))}" data-msg-input autocomplete="off" />
      <button type="button" class="btn btn--primary chat-compose__send" data-msg-send aria-label="${esc(t("chat.send"))}">${esc(t("chat.send"))}</button>
    </footer>`;
}

function renderPerformanceSection() {
  const metrics = [
    { icon: "🖤", label: t("perf.metric.traffic"), value: formatNumber(0) },
    { icon: "🟣", label: t("perf.metric.visitors"), value: formatNumber(0) },
    { icon: "🟢", label: t("perf.metric.contact"), value: formatNumber(0) },
    { icon: "🟠", label: t("perf.metric.chats"), value: formatNumber(0) },
    {
      icon: "🔵",
      label: t("perf.metric.spent"),
      value: `<span data-price="0">${esc(formatPrice(0))}</span>`,
      html: true
    }
  ];
  const metricCards = metrics
    .map(
      (m) => `
    <div class="perf-metric-card">
      <span class="perf-metric-card__icon" aria-hidden="true">${m.icon}</span>
      <div class="perf-metric-card__body">
        <span class="perf-metric-card__label">${esc(m.label)}</span>
        <span class="perf-metric-card__value">${m.html ? m.value : esc(m.value)}</span>
      </div>
    </div>`
    )
    .join("");

  return `
    <div class="perf-page" data-perf-root>
      <div class="perf-page__header">
        <h2 class="perf-page__title">${esc(t("perf.title"))}</h2>
        <div class="perf-page__toggles" role="group" aria-label="Period" data-perf-period>
          <button type="button" class="perf-toggle is-active" data-perf="daily">${esc(t("perf.toggle.daily"))} ✓</button>
          <button type="button" class="perf-toggle" data-perf="weekly">${esc(t("perf.toggle.weekly"))}</button>
          <button type="button" class="perf-toggle" data-perf="monthly">${esc(t("perf.toggle.monthly"))}</button>
        </div>
      </div>
      <p class="muted small perf-page__stats-note" style="margin:0 0 0.75rem">
        ${esc(t("perf.stats_note"))}
      </p>
      <p class="perf-page__range" data-perf-range>—</p>
      <div class="perf-chart-wrap">
        <svg class="perf-chart" viewBox="0 0 320 120" preserveAspectRatio="none" aria-hidden="true" data-perf-chart>
          <defs>
            <linearGradient id="perfGrad" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="var(--orange)" stop-opacity="0.12"/>
              <stop offset="100%" stop-color="var(--orange)" stop-opacity="0"/>
            </linearGradient>
          </defs>
          <polygon fill="url(#perfGrad)" points="0,120 0,118 320,118 320,120"/>
          <polyline fill="none" stroke="var(--orange)" stroke-width="1.5" stroke-opacity="0.35" points="0,118 320,118"/>
        </svg>
      </div>
      <div class="perf-metrics-grid">${metricCards}</div>
      <div class="perf-summary-row">
        <a href="/profile/followers" class="perf-summary-card">
          <span class="perf-summary-card__label">${esc(t("perf.summary.visitors"))}</span>
          <span class="perf-summary-card__arrow" aria-hidden="true">›</span>
        </a>
        <a href="/profile/messages" class="perf-summary-card">
          <span class="perf-summary-card__label">${esc(t("perf.summary.chats"))}</span>
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
        <h2 class="feedback-jiji__title">${esc(t("feedback.title"))}</h2>
        <div class="feedback-jiji__toggles" role="group">
          <button type="button" class="feedback-toggle is-active" data-fb-tab="received">${esc(tfn("feedback.received", 0))}</button>
          <button type="button" class="feedback-toggle" data-fb-tab="sent">${esc(tfn("feedback.sent", 0))}</button>
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
          <p class="feedback-empty__text">${esc(t("feedback.empty_received"))}</p>
          <button type="button" class="btn btn--primary feedback-copy-btn" data-copy-feedback-link data-link="${esc(profileLink)}">
            ${esc(t("feedback.copy_link"))}
          </button>
        </div>
      </div>
      <div class="feedback-jiji__panel" data-fb-panel="sent" hidden>
        <div class="feedback-empty">
          <p class="feedback-empty__text muted">${esc(t("feedback.empty_sent"))}</p>
        </div>
      </div>
    </div>`;
}

/** Mobile hub grid; desktop uses sidebar + section content instead. */
function isProfileDesktopLayout() {
  return (
    typeof window !== "undefined" && window.matchMedia("(min-width: 640px)").matches
  );
}

/**
 * @param {object} user — { name, phone, avatarUrl, role, adverts?, savedAds? }
 * @param {string} [sectionFromRoute] — from router; falls back to pathname
 */
export function renderProfilePage(user, sectionFromRoute) {
  const section = sectionFromRoute || getProfileSectionFromPathname();
  const effectiveSection =
    section === "hub" && isProfileDesktopLayout() ? "adverts" : section;
  const isHubView = effectiveSection === "hub";
  const mainExtra =
    effectiveSection === "messages"
      ? " profile-content--messages"
      : isHubView
        ? " profile-content--hub"
        : "";
  const showMobileHeader = !isHubView && effectiveSection !== "messages";
  const sidebarSection =
    effectiveSection === "settings" ? "adverts" : effectiveSection;

  return `
<div class="profile-shell${isHubView ? " profile-shell--hub" : ""}">
  ${showMobileHeader ? renderProfileMobileHeader(user) : ""}
  ${renderProfileMobileTabs(section)}
  ${renderProfileMobileSignOutRow()}
  <div class="profile-layout profile-layout--jiji${isHubView ? " profile-layout--profile-hub" : ""}">
    ${renderProfileSidebar(user, sidebarSection)}
    <main class="profile-content profile-content--jiji profile-card${mainExtra}">
      ${renderProfileSection(effectiveSection, user)}
    </main>
  </div>
</div>`;
}

function renderProfileSection(section, user) {
  switch (section) {
    case "hub":
      return renderProfileHub(user);
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
  const empty =
    real.length === 0
      ? `<div class="profile-empty-state" role="status">
          <p>${esc(t("adverts.empty"))}</p>
          <p><a href="/post" class="btn btn--primary">${esc(t("adverts.post"))}</a></p>
        </div>`
      : "";
  const list =
    real.length > 0
      ? `<div class="advert-row-list my-adverts-list">${renderMyAdvertRowsWithStatus(real)}</div>`
      : empty;
  return `
    <div class="profile-section-header profile-section-header--row">
      <h2>${esc(t("adverts.title"))}</h2>
    </div>
    ${list}
    ${
      real.length > 0
        ? `<div class="profile-cta-row">
      <a href="/post" class="btn btn--primary">${esc(t("browse.post_cta"))}</a>
    </div>`
        : ""
    }`;
}

function renderSavedAds(user) {
  const saved = user.savedAds || [];
  return `
    <div class="profile-section-header"><h2>${esc(t("saved.title"))}</h2></div>
    ${
      saved.length === 0
        ? `<div class="profile-empty-state"><p>${esc(t("saved.empty"))}</p>
           <p><a href="/browse" class="btn btn--primary">${esc(t("saved.browse"))}</a></p></div>`
        : `<div class="profile-saved-grid">${renderAdvertRows(saved)}</div>`
    }`;
}

function renderNotifications() {
  return `
    <div data-notifications-root>
      <div class="profile-section-header"><h2>${esc(t("notifications.title"))}</h2></div>
      <p class="muted small" data-notifications-loading style="margin:0 0 0.75rem">${esc(t("notifications.loading"))}</p>
      <p class="browse-listings-soft-msg muted" data-notifications-error hidden role="alert"></p>
      <div data-notifications-list></div>
    </div>`;
}

function renderFollowers() {
  return `
    <div class="profile-section-header"><h2>${esc(t("followers.title"))}</h2></div>
    <div class="profile-empty-state"><p>${esc(t("followers.empty"))}</p></div>`;
}

