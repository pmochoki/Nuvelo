import "./admin.css";

function getApiBase() {
  const raw = import.meta.env.VITE_API_URL;
  if (raw == null || String(raw).trim() === "") {
    return "/api";
  }
  return String(raw).trim().replace(/\/+$/, "");
}

const root = document.getElementById("admin-root");

const esc = (s) => {
  const d = document.createElement("div");
  d.textContent = s ?? "";
  return d.innerHTML;
};

const headerHtml = () => `
  <header class="admin-header">
    <h1>Nuvelo moderation</h1>
    <p>Approve or reject pending listings using backend admin endpoints.</p>
  </header>
`;

async function apiFetch(path, options = {}) {
  const base = getApiBase();
  const pathPart = path.startsWith("/") ? path : `/${path}`;
  const url = base.startsWith("http") ? `${base}${pathPart}` : `${base}${pathPart}`;
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
  const data = txt ? JSON.parse(txt) : null;
  if (!res.ok) {
    throw new Error(data?.error || `Request failed (${res.status})`);
  }
  return data;
}

function cardHtml(title, value) {
  return `<div class="card"><strong>${esc(title)}</strong><p style="margin:8px 0 0;font-size:1.5rem">${esc(
    String(value)
  )}</p></div>`;
}

async function renderDashboard() {
  const [all, pending] = await Promise.all([
    apiFetch("/admin/listings"),
    apiFetch("/admin/listings?status=pending")
  ]);
  const counts = {
    total: all.length,
    pending: pending.length,
    approved: all.filter((x) => x.status === "approved").length
  };

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
      <div class="admin-toolbar">
        <button type="button" id="admin-refresh">Refresh</button>
        <a href="/" style="margin-left:12px;color:var(--orange);align-self:center">← Marketplace</a>
        <a href="${getApiBase().startsWith("http") ? `${getApiBase()}/health` : "/api/health"}" target="_blank" rel="noopener noreferrer" style="margin-left:12px;align-self:center;font-size:0.85rem">API health</a>
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
      try {
        await apiFetch(`/admin/listings/${encodeURIComponent(id)}/status`, {
          method: "POST",
          body: JSON.stringify({ status })
        });
        await init();
      } catch (err) {
        window.alert(err?.message || String(err));
        btn.disabled = false;
      }
    });
  });
}

async function init() {
  if (!root) {
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
