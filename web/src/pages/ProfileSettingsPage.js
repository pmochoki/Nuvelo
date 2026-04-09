import { HUNGARIAN_LOCATIONS } from "../data/hungarianLocations.js";
import { renderProfileMobileTabs, renderProfileSidebar } from "./ProfilePage.js";

const esc = (s) => {
  const d = document.createElement("div");
  d.textContent = s ?? "";
  return d.innerHTML;
};

function cityOptionsHtml(selectedCity) {
  const opts = HUNGARIAN_LOCATIONS.filter((l) => l.value !== "all").map(
    (l) =>
      `<option value="${esc(l.value)}"${selectedCity === l.value ? " selected" : ""}>${esc(l.label)}</option>`
  );
  return `<option value="">Select city…</option>${opts.join("")}`;
}

const ROLE_OPTIONS = ["Buyer", "Tenant", "Seller", "Agent", "Landlord"];

/**
 * @param {object} user — extended with profile fields
 */
function renderContactDetailsForm(user) {
  const fullName = String(user.fullName || user.name || "").trim();
  const email = String(user.email || "").trim();
  const phone = String(user.phone || "").trim();
  const phoneRest = phone
    .replace(/^\+\s*36\s*/i, "")
    .replace(/[^\d]/g, "");
  const city = user.city || "";
  const bio = String(user.bio || "").trim();
  const role = String(user.role || "Buyer").trim();
  const avatar = user.avatarUrl || "/default-avatar.svg";
  const bioLen = bio.length;

  const roleOpts = ROLE_OPTIONS.map(
    (r) => `<option value="${esc(r)}"${role === r ? " selected" : ""}>${esc(r)}</option>`
  ).join("");

  return `
    <div class="settings-jiji">
      <div class="profile-section-header profile-section-header--settings-jiji">
        <h2>Contact details</h2>
      </div>
      <div class="settings-jiji__body">
        <form class="settings-jiji-form" id="profile-settings-form" novalidate>
          <section class="settings-jiji-section">
            <h3 class="settings-jiji-section__title">Contact details</h3>
            <div class="form-field">
              <label class="form-label" for="settings-full-name">Full name</label>
              <input type="text" id="settings-full-name" name="fullName" class="form-input" value="${esc(fullName)}" required maxlength="120" autocomplete="name" data-settings-track />
            </div>
            <div class="form-field">
              <label class="form-label" for="settings-email">Email address</label>
              <input type="email" id="settings-email" name="email" class="form-input" value="${esc(email)}" required maxlength="120" autocomplete="email" data-settings-track />
            </div>
            <div class="form-field">
              <label class="form-label" for="settings-phone">Phone number</label>
              <div class="phone-prefix-field">
                <span class="phone-prefix-field__pre" aria-hidden="true">+36</span>
                <input type="tel" id="settings-phone" name="phoneNational" class="form-input phone-prefix-field__input" value="${esc(phoneRest)}" inputmode="tel" autocomplete="tel-national" placeholder="20 123 4567" data-settings-track />
              </div>
            </div>
            <div class="form-field">
              <label class="form-label" for="settings-location">Location / city</label>
              <select id="settings-location" name="location" class="form-input form-select" data-settings-track>
                ${cityOptionsHtml(city)}
              </select>
            </div>
          </section>

          <section class="settings-jiji-section">
            <h3 class="settings-jiji-section__title">Profile photo</h3>
            <div class="settings-photo-row">
              <div class="avatar-upload-wrap settings-avatar-wrap">
                <img src="${esc(avatar)}" alt="" class="profile-avatar-large" id="avatar-preview" width="96" height="96" decoding="async" />
                <button type="button" class="avatar-edit-btn avatar-edit-btn--large" id="avatar-edit-btn" title="Upload photo" aria-label="Upload photo">
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                    <path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3h6l2 3h4a2 2 0 012 2z"/>
                    <circle cx="12" cy="13" r="4"/>
                  </svg>
                </button>
                <input type="file" id="avatar-input" accept="image/*" hidden />
              </div>
            </div>
          </section>

          <section class="settings-jiji-section">
            <h3 class="settings-jiji-section__title">About me</h3>
            <div class="form-field">
              <label class="form-label" for="settings-bio">Bio</label>
              <span class="char-count" id="bio-count" aria-live="polite">${bioLen} / 300</span>
              <textarea id="settings-bio" name="bio" class="form-input form-textarea" rows="4" maxlength="300" data-char-target="bio-count" data-char-max="300" data-settings-track>${esc(bio)}</textarea>
            </div>
          </section>

          <section class="settings-jiji-section">
            <h3 class="settings-jiji-section__title">Role</h3>
            <div class="form-field">
              <label class="form-label" for="settings-role">How you use Nuvelo</label>
              <select id="settings-role" name="role" class="form-input form-select" data-settings-track>
                ${roleOpts}
              </select>
            </div>
          </section>

          <div class="settings-jiji-actions">
            <button type="submit" class="btn btn--primary settings-save-btn" id="save-profile-btn" disabled>Save changes</button>
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
  ${renderProfileMobileTabs("settings")}
  <div class="profile-layout profile-layout--jiji profile-layout--settings-jiji">
    ${renderProfileSidebar(user, "settings")}
    <main class="profile-content profile-content--jiji">
      ${renderContactDetailsForm(user)}
    </main>
  </div>
</div>`;
}
