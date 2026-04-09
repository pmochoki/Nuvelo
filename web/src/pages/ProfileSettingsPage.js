import { HUNGARIAN_LOCATIONS } from "../data/hungarianLocations.js";

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

function sidebarNav(settingsSection) {
  const item = (href, key, label, extra = "") => {
    const active = settingsSection === key ? " active" : "";
    return `<a href="${href}" class="profile-sidenav-item${active}">${esc(label)}${extra}</a>`;
  };

  return `
    <nav class="profile-sidenav settings-sidenav">
      ${item("#/profile/settings", "personal", "Personal details")}
      <a href="#/profile/settings/business" class="profile-sidenav-item settings-sidenav-item--row${settingsSection === "business" ? " active" : ""}">
        <span>Business details</span>
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
          <polyline points="9 18 15 12 9 6"/>
        </svg>
      </a>
      ${item("#/profile/settings/verify", "verify", "Verify your details")}
      ${item("#/profile/settings/phone", "phone", "Change phone number")}
      ${item("#/profile/settings/email", "email", "Change email")}
      ${item("#/profile/settings/password", "password", "Change password")}
      <button type="button" class="profile-sidenav-item signout-btn" id="signout-btn">Log out</button>
    </nav>`;
}

function renderPersonalForm(user) {
  const fnLen = String(user.firstName || "").length;
  const lnLen = String(user.lastName || "").length;

  return `
    <main class="profile-content">
      <div class="profile-section-header profile-section-header--settings">
        <h2>Personal details</h2>
        <button type="button" class="btn-saved" id="save-profile-btn" aria-label="Save profile">Save</button>
      </div>

      <div class="settings-form-wrap">
        <div class="avatar-upload-block">
          <div class="avatar-upload-wrap">
            <img src="${esc(user.avatarUrl || "/default-avatar.svg")}"
                 alt="${esc(user.name)}"
                 class="profile-avatar-large"
                 id="avatar-preview"/>
            <button type="button" class="avatar-edit-btn" id="avatar-edit-btn" title="Change photo" aria-label="Change photo">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/>
                <path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/>
              </svg>
            </button>
            <input type="file" id="avatar-input" accept="image/*" hidden/>
          </div>
        </div>

        <form class="settings-form" id="profile-settings-form">
          <div class="form-field">
            <label class="form-label" for="firstName">First Name*</label>
            <span class="char-count" id="fn-count" aria-live="polite">${fnLen} / 20</span>
            <input type="text" id="firstName" name="firstName"
                   value="${esc(user.firstName || "")}"
                   maxlength="20"
                   class="form-input"
                   data-char-target="fn-count"
                   data-char-max="20"/>
          </div>

          <div class="form-field">
            <label class="form-label" for="lastName">Last Name*</label>
            <span class="char-count" id="ln-count" aria-live="polite">${lnLen} / 20</span>
            <input type="text" id="lastName" name="lastName"
                   value="${esc(user.lastName || "")}"
                   maxlength="20"
                   class="form-input"
                   data-char-target="ln-count"
                   data-char-max="20"/>
          </div>

          <div class="form-field">
            <label class="form-label" for="location">Location*</label>
            <select id="location" name="location" class="form-input form-select">
              ${cityOptionsHtml(user.city)}
            </select>
          </div>

          <div class="form-field">
            <label class="form-label" for="birthday">Birthday</label>
            <input type="date" id="birthday" name="birthday"
                   value="${esc(user.birthday || "")}"
                   class="form-input"/>
          </div>

          <div class="form-field">
            <label class="form-label" for="sex">Sex</label>
            <select id="sex" name="sex" class="form-input form-select">
              <option value="">Prefer not to say</option>
              <option value="male"${user.sex === "male" ? " selected" : ""}>Male</option>
              <option value="female"${user.sex === "female" ? " selected" : ""}>Female</option>
            </select>
          </div>

          <div class="form-field">
            <label class="form-label" for="phone">Phone</label>
            <input type="tel" id="phone" name="phone"
                   value="${esc(user.phone || "")}"
                   class="form-input"
                   placeholder="+36…"/>
          </div>

          <button type="submit" class="btn btn--primary save-btn">Save changes</button>
        </form>
        <p id="profile-settings-saved-msg" class="settings-saved-msg muted" hidden role="status"></p>
      </div>
    </main>`;
}

function renderSubPlaceholder(title, blurb) {
  return `
    <main class="profile-content">
      <div class="profile-section-header">
        <h2>${esc(title)}</h2>
      </div>
      <div class="profile-empty-state">
        <p>${esc(blurb)}</p>
      </div>
    </main>`;
}

function mainPanel(settingsSection, user) {
  switch (settingsSection) {
    case "personal":
      return renderPersonalForm(user);
    case "business":
      return renderSubPlaceholder(
        "Business details",
        "Business profile and tax details will be available here soon."
      );
    case "verify":
      return renderSubPlaceholder(
        "Verify your details",
        "Identity verification will be available here soon."
      );
    case "phone":
      return renderSubPlaceholder(
        "Change phone number",
        "Phone number changes will be handled through a secure verification flow soon."
      );
    case "email":
      return renderSubPlaceholder(
        "Change email",
        "Email updates will be available here soon."
      );
    case "password":
      return renderSubPlaceholder(
        "Change password",
        "Password management will be available here soon."
      );
    default:
      return renderPersonalForm(user);
  }
}

/**
 * @param {object} user — extended with firstName, lastName, city, birthday, sex, avatarUrl, phone, name
 * @param {string} settingsSection — personal | business | verify | phone | email | password
 */
export function renderSettingsPage(user, settingsSection) {
  const sec = settingsSection || "personal";

  return `
<div class="profile-layout profile-layout--settings">

  <aside class="profile-sidebar">
    <div class="profile-sidebar-header">
      <a href="#/profile/adverts" class="back-link">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
          <polyline points="15 18 9 12 15 6"/>
        </svg>
        Settings
      </a>
    </div>

    ${sidebarNav(sec)}

  </aside>

  ${mainPanel(sec, user)}

</div>`;
}
