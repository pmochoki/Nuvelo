import { HUNGARIAN_LOCATIONS } from "../data/hungarianLocations.js";
import { getDisplayInitials } from "../lib/profileInitials.js";
import { renderProfileMobileHeader, renderProfileMobileTabs, renderProfileSidebar } from "./ProfilePage.js";

const AVATAR_STORAGE_KEY = "nuvelo_avatar_dataurl";

const esc = (s) => {
  const d = document.createElement("div");
  d.textContent = s ?? "";
  return d.innerHTML;
};

function readLocalAvatarDataUrl() {
  try {
    const u = localStorage.getItem(AVATAR_STORAGE_KEY);
    return typeof u === "string" && u.startsWith("data:image/") ? u : "";
  } catch {
    return "";
  }
}

function cityOptionsHtml(selectedCity) {
  const opts = HUNGARIAN_LOCATIONS.filter((l) => l.value !== "all").map(
    (l) =>
      `<option value="${esc(l.value)}"${selectedCity === l.value ? " selected" : ""}>${esc(l.label)}</option>`
  );
  return `<option value="">Select city…</option>${opts.join("")}`;
}

const ROLE_OPTIONS = ["Buyer", "Tenant", "Seller", "Agent", "Landlord"];
const DEFAULT_SAVE_LABEL = "Save changes";

/**
 * @param {object} user — extended with profile fields
 */
function renderContactDetailsForm(user) {
  const firstName = String(user.firstName || "").trim();
  const lastName = String(user.lastName || "").trim();
  const fullName = String(user.fullName || "").trim() || [firstName, lastName].filter(Boolean).join(" ").trim();
  const email = String(user.email || "").trim();
  const phone = String(user.phone || "").trim();
  const phoneRest = phone
    .replace(/^\+\s*36\s*/i, "")
    .replace(/[^\d]/g, "");
  const city = user.city || "";
  const birthday = String(user.birthday || "");
  const sex = String(user.sex || "");
  const bio = String(user.bio || "").trim();
  const role = String(user.role || "Buyer").trim();
  const bioLen = bio.length;

  const localAv = readLocalAvatarDataUrl();
  const remoteAv =
    user.avatarUrl &&
    typeof user.avatarUrl === "string" &&
    !user.avatarUrl.includes("default-avatar") &&
    (user.avatarUrl.startsWith("http") || user.avatarUrl.startsWith("data:image"))
      ? user.avatarUrl
      : "";
  const photoSrc = localAv || remoteAv;
  const hasPhoto = Boolean(photoSrc);
  const initials = getDisplayInitials(fullName || "Member");

  const roleOpts = ROLE_OPTIONS.map(
    (r) => `<option value="${esc(r)}"${role === r ? " selected" : ""}>${esc(r)}</option>`
  ).join("");

  const imgAttrs = hasPhoto ? ` src="${esc(photoSrc)}"` : "";

  const sexOpts = [
    { v: "", l: "Prefer not to say" },
    { v: "male", l: "Male" },
    { v: "female", l: "Female" }
  ]
    .map((o) => `<option value="${esc(o.v)}"${sex === o.v ? " selected" : ""}>${esc(o.l)}</option>`)
    .join("");

  return `
    <div class="settings-jiji">
      <div class="profile-section-header profile-section-header--settings-jiji">
        <h2>Account settings</h2>
      </div>
      <div class="settings-jiji__body">
        <form class="settings-jiji-form" id="profile-settings-form" novalidate action="javascript:void(0)">
          <section class="settings-jiji-section settings-jiji-section--photo">
            <h3 class="settings-jiji-section__title">Profile photo</h3>
            <p class="settings-account-photo__lead muted small">Your photo appears on your profile and in the header after you save or upload.</p>
            <div class="settings-account-photo" data-settings-avatar>
              <div class="settings-account-photo__circle">
                <img
                  id="settings-avatar-img"
                  class="settings-account-photo__img${hasPhoto ? "" : " settings-account-photo__img--hidden"}"
                  width="112"
                  height="112"
                  alt=""
                  decoding="async"${imgAttrs}
                />
                <div
                  id="settings-avatar-initials"
                  class="settings-account-photo__initials"
                  aria-hidden="true"
                  ${hasPhoto ? " hidden" : ""}
                >${esc(initials)}</div>
                <button type="button" class="settings-account-photo__trigger" id="avatar-edit-btn" aria-label="Upload profile photo">
                  <span class="settings-account-photo__overlay" aria-hidden="true">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3h6l2 3h4a2 2 0 012 2z"/>
                      <circle cx="12" cy="13" r="4"/>
                    </svg>
                  </span>
                </button>
              </div>
              <input
                type="file"
                id="avatar-input"
                accept="image/jpeg,image/png,image/webp,image/gif,.jpg,.jpeg,.png,.webp"
                hidden
              />
              <p class="settings-account-photo__hint muted small">JPG, PNG or WebP. Images are stored in this browser only.</p>
            </div>
          </section>

          <section class="settings-jiji-section">
            <h3 class="settings-jiji-section__title">Account information</h3>
            <div class="settings-jiji-name-row">
              <div class="form-field">
                <label class="form-label" for="settings-first-name">First name</label>
                <input
                  type="text"
                  id="settings-first-name"
                  name="firstName"
                  class="form-input"
                  value="${esc(firstName)}"
                  maxlength="60"
                  autocomplete="given-name"
                  data-settings-track
                />
              </div>
              <div class="form-field">
                <label class="form-label" for="settings-last-name">Last name</label>
                <input
                  type="text"
                  id="settings-last-name"
                  name="lastName"
                  class="form-input"
                  value="${esc(lastName)}"
                  maxlength="60"
                  autocomplete="family-name"
                  data-settings-track
                />
              </div>
            </div>
            <div class="form-field">
              <label class="form-label" for="settings-email">Email address</label>
              <input
                type="email"
                id="settings-email"
                name="email"
                class="form-input"
                value="${esc(email)}"
                maxlength="120"
                autocomplete="email"
                data-settings-track
                aria-invalid="false"
                aria-describedby="settings-email-error"
              />
              <p class="form-field__error" id="settings-email-error" role="alert" hidden></p>
            </div>
            <div class="form-field">
              <label class="form-label" for="settings-phone">Phone number</label>
              <div class="phone-prefix-field">
                <span class="phone-prefix-field__pre" aria-hidden="true">+36</span>
                <input
                  type="tel"
                  id="settings-phone"
                  name="phoneNational"
                  class="form-input phone-prefix-field__input"
                  value="${esc(phoneRest)}"
                  inputmode="numeric"
                  autocomplete="tel-national"
                  placeholder="20 123 4567"
                  data-settings-track
                  aria-describedby="settings-phone-error"
                />
              </div>
              <p class="form-field__error" id="settings-phone-error" role="alert" hidden></p>
            </div>
            <div class="form-field">
              <label class="form-label" for="settings-location">Location / city</label>
              <select id="settings-location" name="location" class="form-input form-select" data-settings-track>
                ${cityOptionsHtml(city)}
              </select>
            </div>
            <div class="form-field">
              <label class="form-label" for="settings-birthday">Birthday</label>
              <input
                type="date"
                id="settings-birthday"
                name="birthday"
                class="form-input"
                value="${esc(birthday)}"
                data-settings-track
              />
            </div>
            <div class="form-field">
              <label class="form-label" for="settings-sex">Sex</label>
              <select id="settings-sex" name="sex" class="form-input form-select" data-settings-track>
                ${sexOpts}
              </select>
            </div>
            <div class="form-field">
              <label class="form-label" for="settings-bio">Bio / About me</label>
              <span class="char-count" id="bio-count" aria-live="polite">${bioLen} / 300</span>
              <textarea
                id="settings-bio"
                name="bio"
                class="form-input form-textarea"
                rows="4"
                maxlength="300"
                data-char-target="bio-count"
                data-char-max="300"
                data-settings-track
              >${esc(bio)}</textarea>
            </div>
            <div class="form-field">
              <label class="form-label" for="settings-role">Role</label>
              <select id="settings-role" name="role" class="form-input form-select" data-settings-track>
                ${roleOpts}
              </select>
            </div>
          </section>

          <div class="settings-jiji-actions">
            <button type="button" class="btn btn--ghost settings-cancel-btn" id="settings-cancel-btn" disabled>
              Cancel
            </button>
            <button type="button" class="btn btn--primary settings-save-btn" id="save-profile-btn">${esc(DEFAULT_SAVE_LABEL)}</button>
          </div>
        </form>
        <p id="profile-settings-saved-msg" class="settings-saved-msg nuvelo-toast-placeholder" hidden role="status"></p>
      </div>
    </div>`;
}

/**
 * @param {object} user
 * @param {string} _settingsSection — reserved for future sub-routes
 */
export function renderSettingsPage(user, _settingsSection) {
  return `
<div class="profile-shell">
  ${renderProfileMobileHeader(user)}
  ${renderProfileMobileTabs("settings")}
  <div class="profile-layout profile-layout--jiji profile-layout--settings-jiji">
    ${renderProfileSidebar(user, "settings")}
    <main class="profile-content profile-content--jiji profile-card">
      ${renderContactDetailsForm(user)}
    </main>
  </div>
</div>`;
}
