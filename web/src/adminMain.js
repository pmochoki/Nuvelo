import "./admin.css";
import { supabase } from "./lib/supabase.js";

const root = document.getElementById("admin-root");

const esc = (s) => {
  const d = document.createElement("div");
  d.textContent = s ?? "";
  return d.innerHTML;
};

const headerHtml = () => `
  <header class="admin-header">
    <h1>Nuvelo moderation</h1>
    <p>Approve listings, toggle visibility, and manage featured ads (Supabase).</p>
  </header>
`;

async function renderLogin() {
  root.innerHTML = `
    ${headerHtml()}
    <main class="admin-main">
      <div class="card">
        <h2 style="margin-top:0;color:var(--purple);text-transform:none">Sign in</h2>
        <p class="muted" style="color:#4b5563">Use an account that has <code>role = admin</code> in <code>public.profiles</code>.</p>
        <p class="muted" style="color:#4b5563">Add <code>${esc(window.location.origin)}/admin.html</code> to Supabase → Authentication → URL configuration → Redirect URLs.</p>
        <form id="admin-login-form" class="admin-form">
          <label>
            Email
            <input name="email" type="email" required autocomplete="email" placeholder="you@example.com" />
          </label>
          <button type="submit">Send magic link</button>
        </form>
        <p id="admin-login-msg" style="color:#4b5563;min-height:1.5em"></p>
        <p><a href="/" style="color:var(--orange)">← Back to marketplace</a></p>
      </div>
    </main>
  `;
  document.getElementById("admin-login-form")?.addEventListener("submit", async (e) => {
    e.preventDefault();
    const fd = new FormData(e.target);
    const email = String(fd.get("email") || "").trim();
    const msg = document.getElementById("admin-login-msg");
    msg.textContent = "";
    const { error } = await supabase.auth.signInWithOtp({
      email,
      options: {
        emailRedirectTo: `${window.location.origin}/admin.html`
      }
    });
    if (error) {
      msg.textContent = error.message;
      return;
    }
    msg.textContent = "Check your email for the sign-in link, then return here.";
  });
}

async function renderAccessDenied(userId, role) {
  root.innerHTML = `
    ${headerHtml()}
    <main class="admin-main">
      <div class="card">
        <h2 style="margin-top:0;color:#b91c1c;text-transform:none">Access denied</h2>
        <p style="color:#4b5563">Your profile role is <strong>${esc(role || "unknown")}</strong>. Promote this user in the Supabase SQL editor:</p>
        <pre style="background:#1a1432;color:#e9d5ff;padding:16px;border-radius:8px;overflow:auto">update public.profiles
set role = 'admin'
where id = '${esc(userId)}';</pre>
        <button type="button" id="admin-signout" class="secondary">Sign out</button>
        <p style="margin-top:16px"><a href="/" style="color:var(--orange)">← Marketplace</a></p>
      </div>
    </main>
  `;
  document.getElementById("admin-signout")?.addEventListener("click", async () => {
    await supabase.auth.signOut();
    location.reload();
  });
}

async function loadCounts() {
  const totalQ = supabase.from("listings").select("*", { count: "exact", head: true });
  const activeQ = supabase.from("listings").select("*", { count: "exact", head: true }).eq("is_active", true);
  const inactiveQ = supabase.from("listings").select("*", { count: "exact", head: true }).eq("is_active", false);
  const usersQ = supabase.from("profiles").select("*", { count: "exact", head: true });

  const [total, active, inactive, users] = await Promise.all([totalQ, activeQ, inactiveQ, usersQ]);
  return {
    total: total.count ?? 0,
    active: active.count ?? 0,
    inactive: inactive.count ?? 0,
    users: users.count ?? 0
  };
}

async function loadListings() {
  const { data, error } = await supabase
    .from("listings")
    .select("id, title, category, location, is_active, is_featured, created_at, user_id")
    .order("created_at", { ascending: false })
    .limit(150);

  if (error) {
    throw error;
  }
  return data || [];
}

function metricCard(label, value) {
  return `<div class="card"><strong>${esc(label)}</strong><p style="margin:8px 0 0;font-size:1.5rem">${esc(String(value))}</p></div>`;
}

async function renderDashboard() {
  let counts;
  let rows;
  try {
    [counts, rows] = await Promise.all([loadCounts(), loadListings()]);
  } catch (e) {
    root.innerHTML = `
      ${headerHtml()}
      <main class="admin-main">
        <div class="admin-alert">
          Could not load data: ${esc(e?.message || String(e))}. Check that admin RLS policies are installed (see <code>supabase/admin_policies.sql</code>).
        </div>
        <p><button type="button" id="admin-retry">Retry</button>
        <button type="button" id="admin-signout2" class="secondary">Sign out</button></p>
        <p><a href="/" style="color:var(--orange)">← Marketplace</a></p>
      </main>
    `;
    document.getElementById("admin-retry")?.addEventListener("click", () => renderDashboard());
    document.getElementById("admin-signout2")?.addEventListener("click", async () => {
      await supabase.auth.signOut();
      location.reload();
    });
    return;
  }

  const tableRows = rows
    .map((r) => {
      const id = r.id;
      return `<tr data-id="${esc(id)}">
        <td>${esc(r.title)}</td>
        <td>${esc(r.category || "")}</td>
        <td>${esc(r.location || "")}</td>
        <td>${r.is_active ? "Yes" : "<strong>No</strong>"}</td>
        <td>${r.is_featured ? "Yes" : "No"}</td>
        <td>${esc(String(r.created_at || "").slice(0, 16))}</td>
        <td>
          <button type="button" data-act="active" data-val="true">Show</button>
          <button type="button" data-act="active" data-val="false" class="secondary">Hide</button>
          <button type="button" data-act="feat">Feature</button>
          <button type="button" data-act="del" class="danger">Delete</button>
        </td>
      </tr>`;
    })
    .join("");

  root.innerHTML = `
    ${headerHtml()}
    <main class="admin-main">
      <div class="admin-toolbar">
        <button type="button" id="admin-refresh">Refresh</button>
        <button type="button" id="admin-signout3" class="secondary">Sign out</button>
        <a href="/" style="margin-left:12px;color:var(--orange);align-self:center">← Marketplace</a>
      </div>
      <section>
        <h2>Snapshot</h2>
        <div class="card-grid">
          ${metricCard("Total listings", counts.total)}
          ${metricCard("Active (public)", counts.active)}
          ${metricCard("Hidden", counts.inactive)}
          ${metricCard("Profiles", counts.users)}
        </div>
      </section>
      <section>
        <h2>Listings</h2>
        <p class="muted" style="margin-bottom:12px">Hidden listings are not visible on the public site. Use Show/Hide to moderate.</p>
        <div class="admin-table-wrap">
          <table class="admin-listings">
            <thead>
              <tr>
                <th>Title</th>
                <th>Category</th>
                <th>Location</th>
                <th>Active</th>
                <th>Featured</th>
                <th>Created</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>${tableRows || `<tr><td colspan="7">No listings yet.</td></tr>`}</tbody>
          </table>
        </div>
      </section>
    </main>
  `;

  document.getElementById("admin-refresh")?.addEventListener("click", () => renderDashboard());
  document.getElementById("admin-signout3")?.addEventListener("click", async () => {
    await supabase.auth.signOut();
    location.reload();
  });

  root.querySelectorAll("tbody button[data-act]").forEach((btn) => {
    btn.addEventListener("click", async () => {
      const tr = btn.closest("tr");
      const listingId = tr?.getAttribute("data-id");
      if (!listingId) {
        return;
      }
      const act = btn.getAttribute("data-act");
      btn.disabled = true;
      try {
        if (act === "active") {
          const v = btn.getAttribute("data-val") === "true";
          const { error } = await supabase.from("listings").update({ is_active: v }).eq("id", listingId);
          if (error) {
            throw error;
          }
        } else if (act === "feat") {
          const { data: cur } = await supabase.from("listings").select("is_featured").eq("id", listingId).single();
          const next = !cur?.is_featured;
          const { error } = await supabase.from("listings").update({ is_featured: next }).eq("id", listingId);
          if (error) {
            throw error;
          }
        } else if (act === "del") {
          if (!window.confirm("Delete this listing permanently?")) {
            btn.disabled = false;
            return;
          }
          const { error } = await supabase.from("listings").delete().eq("id", listingId);
          if (error) {
            throw error;
          }
        }
        await renderDashboard();
      } catch (e) {
        window.alert(e?.message || String(e));
        btn.disabled = false;
      }
    });
  });
}

async function init() {
  if (!root) {
    return;
  }

  const {
    data: { session }
  } = await supabase.auth.getSession();

  if (!session) {
    await renderLogin();
    return;
  }

  const { data: prof, error: pErr } = await supabase
    .from("profiles")
    .select("role, display_name")
    .eq("id", session.user.id)
    .maybeSingle();

  if (pErr) {
    root.innerHTML = `${headerHtml()}<main class="admin-main"><div class="admin-alert">${esc(pErr.message)}</div></main>`;
    return;
  }

  if (prof?.role !== "admin") {
    await renderAccessDenied(session.user.id, prof?.role);
    return;
  }

  await renderDashboard();
}

void init();
