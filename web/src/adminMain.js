import "./admin.css";

/**
 * Listings/admin API base. Prefer same-origin `/api` (Vercel serverless proxies in repo `/api`).
 * Set `VITE_API_URL` only when calling a backend directly (CORS must allow your origin).
 */
const API_BASE =
  typeof import.meta.env.VITE_API_URL === "string" && import.meta.env.VITE_API_URL.trim() !== ""
    ? import.meta.env.VITE_API_URL.trim().replace(/\/+$/, "")
    : "/api";

/** Simple gate for /admin.html — override in Vercel with VITE_ADMIN_PASSWORD. */
const ADMIN_PASSWORD =
  typeof import.meta.env.VITE_ADMIN_PASSWORD === "string" &&
  import.meta.env.VITE_ADMIN_PASSWORD.trim() !== ""
    ? import.meta.env.VITE_ADMIN_PASSWORD.trim()
    : "nuvelo-admin";

const ADMIN_SESSION_KEY = "nuvelo_admin_session";

const root = document.getElementById("admin-root");

const esc = (s) => {
  const d = document.createElement("div");
  d.textContent = s ?? "";
  return d.innerHTML;
};

/** Seed data when the backend is unreachable — 4 pending + 2 approved for realistic counts. */
const MOCK_LISTINGS_SEED = [
  {
    id: "mock-pending-1",
    title: "VW Golf — low mileage, Budapest",
    categoryId: "vehicles",
    location: "Budapest XI",
    createdAt: "2026-04-08T09:15:00.000Z",
    status: "pending"
  },
  {
    id: "mock-pending-2",
    title: "2 BR flat near Nyugati — long-term",
    categoryId: "rentals",
    location: "District VI",
    createdAt: "2026-04-08T08:40:00.000Z",
    status: "pending"
  },
  {
    id: "mock-pending-3",
    title: "MacBook Pro 14″ — M2, warranty",
    categoryId: "electronics",
    location: "Debrecen",
    createdAt: "2026-04-07T18:22:00.000Z",
    status: "pending"
  },
  {
    id: "mock-pending-4",
    title: "English tutor — business & exam prep",
    categoryId: "services",
    location: "Remote / Budapest",
    createdAt: "2026-04-07T12:05:00.000Z",
    status: "pending"
  },
  {
    id: "mock-approved-1",
    title: "City bike 28″ — lights included",
    categoryId: "vehicles",
    location: "Szeged",
    createdAt: "2026-04-05T11:00:00.000Z",
    status: "approved"
  },
  {
    id: "mock-approved-2",
    title: "IKEA desk + chair — pick up Óbuda",
    categoryId: "furniture",
    location: "Budapest III",
    createdAt: "2026-04-04T09:30:00.000Z",
    status: "approved"
  }
];

/** In-memory copy while using demo mode (approvals/rejections update this until refresh). */
let mockListingState = null;

function cloneMockSeed() {
  return JSON.parse(JSON.stringify(MOCK_LISTINGS_SEED));
}

function buildApiUrl(path) {
  const pathPart = path.startsWith("/") ? path : `/${path}`;
  return `${API_BASE}${pathPart}`;
}

async function apiFetch(path, options = {}) {
  const url = buildApiUrl(path);
  let res;
  try {
    res = await fetch(url, {
      ...options,
      headers: {
        "Content-Type": "application/json",
        ...(options.headers || {})
      }
    });
  } catch (err) {
    const msg = err?.message || String(err);
    throw new Error(`Admin API network error (${url}): ${msg}`);
  }
  const txt = await res.text();
  let data = null;
  try {
    data = txt ? JSON.parse(txt) : null;
  } catch {
    data = null;
  }
  if (!res.ok) {
    throw new Error(data?.error || data?.message || `Request failed (${res.status})`);
  }
  return data;
}

function headerHtml() {
  return `
  <header class="admin-header">
    <h1>Nuvelo moderation</h1>
    <p>Approve or reject pending listings using backend admin endpoints.</p>
  </header>
`;
}

function cardHtml(title, value) {
  return `<div class="card"><strong>${esc(title)}</strong><p style="margin:8px 0 0;font-size:1.5rem">${esc(
    String(value)
  )}</p></div>`;
}

async function loadDashboardData() {
  if (mockListingState) {
    const all = mockListingState;
    const pending = all.filter((x) => x.status === "pending");
    return { all, pending, isMock: true };
  }
  try {
    const [all, pending] = await Promise.all([
      apiFetch("/admin/listings"),
      apiFetch("/admin/listings?status=pending")
    ]);
    mockListingState = null;
    return { all: Array.isArray(all) ? all : [], pending: Array.isArray(pending) ? pending : [], isMock: false };
  } catch {
    mockListingState = cloneMockSeed();
    const all = mockListingState;
    const pending = all.filter((x) => x.status === "pending");
    return { all, pending, isMock: true };
  }
}

function healthHref() {
  return API_BASE.startsWith("http") ? `${API_BASE}/health` : "/api/health";
}

async function renderDashboard() {
  const { all, pending, isMock } = await loadDashboardData();
  const counts = {
    total: all.length,
    pending: pending.length,
    approved: all.filter((x) => x.status === "approved").length
  };

  const mockBanner = isMock
    ? `<div class="admin-mock-banner" role="status">
        <strong>Demo mode.</strong> The admin API is unreachable — showing sample pending listings.
        Actions update this session only. Use <strong>Refresh</strong> to retry the live API.
      </div>`
    : "";

  const rows = pending
    .map(
      (l) => `<tr data-id="${esc(l.id)}">
        <td>${esc(l.title)}</td>
        <td>${esc(l.categoryId || "")}</td>
        <td>${esc(l.location || "")}</td>
        <td>${esc(String(l.createdAt || "").slice(0, 16))}</td>
        <td>
          <button type="button" data-act="approve">Approve</button>
          <button type="button" data-act="reject" class="danger">Reject</button>
        </td>
      </tr>`
    )
    .join("");

  root.innerHTML = `
    ${headerHtml()}
    <main class="admin-main">
      ${mockBanner}
      <div class="admin-toolbar">
        <button type="button" id="admin-refresh">Refresh</button>
        <a href="/" style="margin-left:12px;color:var(--orange);align-self:center">← Marketplace</a>
        <a href="${esc(healthHref())}" target="_blank" rel="noopener noreferrer" style="margin-left:12px;align-self:center;font-size:0.85rem">API health</a>
      </div>
      <section>
        <h2>Snapshot</h2>
        <div class="card-grid">
          ${cardHtml("Total listings", counts.total)}
          ${cardHtml("Pending", counts.pending)}
          ${cardHtml("Approved", counts.approved)}
        </div>
      </section>
      <section>
        <h2>Pending listings</h2>
        <div class="admin-table-wrap">
          <table class="admin-listings">
            <thead><tr><th>Title</th><th>Category</th><th>Location</th><th>Created</th><th>Actions</th></tr></thead>
            <tbody>${rows || '<tr><td colspan="5">No pending listings.</td></tr>'}</tbody>
          </table>
        </div>
      </section>
    </main>
  `;

  document.getElementById("admin-refresh")?.addEventListener("click", () => {
    mockListingState = null;
    void init();
  });

  root.querySelectorAll("tbody button[data-act]").forEach((btn) => {
    btn.addEventListener("click", async () => {
      const tr = btn.closest("tr");
      const id = tr?.getAttribute("data-id");
      if (!id) {
        return;
      }
      const status = btn.getAttribute("data-act") === "approve" ? "approved" : "rejected";
      btn.disabled = true;

      if (isMock && mockListingState) {
        const row = mockListingState.find((x) => String(x.id) === String(id));
        if (row) {
          row.status = status;
        }
        await renderDashboard();
        return;
      }

      try {
        await apiFetch(`/admin/listings/${encodeURIComponent(id)}/status`, {
          method: "POST",
          body: JSON.stringify({ status })
        });
        mockListingState = null;
        await init();
      } catch (err) {
        window.alert(err?.message || String(err));
        btn.disabled = false;
      }
    });
  });
}

function renderPasswordGate() {
  if (!root) {
    return;
  }
  root.innerHTML = `
    <header class="admin-header">
      <h1>Nuvelo moderation</h1>
      <p>Enter the admin password to continue.</p>
    </header>
    <main class="admin-main admin-gate">
      <form class="admin-form" id="admin-gate-form" autocomplete="off">
        <label>
          Password
          <input type="password" name="password" id="admin-gate-password" required placeholder="Password" />
        </label>
        <button type="submit" class="admin-gate-submit">Continue</button>
        <p id="admin-gate-error" class="admin-access-denied" hidden>Access denied</p>
      </form>
      <p class="muted"><a href="/" style="color:var(--orange)">← Back to marketplace</a></p>
    </main>
  `;
  const form = document.getElementById("admin-gate-form");
  const err = document.getElementById("admin-gate-error");
  form?.addEventListener("submit", (e) => {
    e.preventDefault();
    const input = document.getElementById("admin-gate-password");
    const val = input && "value" in input ? String(input.value) : "";
    if (val !== ADMIN_PASSWORD) {
      if (err) {
        err.hidden = false;
      }
      return;
    }
    sessionStorage.setItem(ADMIN_SESSION_KEY, "1");
    void init();
  });
}

async function init() {
  if (!root) {
    return;
  }
  if (!sessionStorage.getItem(ADMIN_SESSION_KEY)) {
    renderPasswordGate();
    return;
  }
  root.innerHTML = `${headerHtml()}<main class="admin-main"><p class="muted">Loading admin…</p></main>`;
  try {
    await renderDashboard();
  } catch (err) {
    root.innerHTML = `${headerHtml()}<main class="admin-main"><div class="admin-alert">${esc(
      err?.message || String(err)
    )}</div><p class="muted">Check <code>VITE_API_URL</code> and backend availability.</p></main>`;
  }
}

void init();
