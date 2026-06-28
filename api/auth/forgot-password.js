const { applyCors } = require("../_cors");
const { readJsonBody } = require("../_readJsonBody");
const { getSupabaseAdmin } = require("../_supabaseAdmin");

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function normalizeEmail(raw) {
  return String(raw || "")
    .trim()
    .toLowerCase();
}

function recoveryRedirectUrl() {
  const explicit = process.env.VITE_AUTH_REDIRECT_URL || process.env.VITE_SITE_URL;
  const base = explicit ? String(explicit).replace(/\/$/, "") : "https://nuvelo.one";
  return `${base}/reset-password`;
}

/** POST /api/auth/forgot-password — registered users only; sends Supabase recovery email. */
module.exports = async (req, res) => {
  applyCors(req, res);
  if (req.method === "OPTIONS") {
    res.statusCode = 204;
    return res.end();
  }
  if (req.method !== "POST") {
    res.statusCode = 405;
    res.setHeader("Content-Type", "application/json");
    return res.end(JSON.stringify({ error: "Method not allowed" }));
  }

  const admin = getSupabaseAdmin();
  if (!admin) {
    res.statusCode = 503;
    res.setHeader("Content-Type", "application/json");
    return res.end(JSON.stringify({ error: "signin_down", code: "service_unavailable" }));
  }

  let body;
  try {
    body = await readJsonBody(req);
  } catch {
    res.statusCode = 400;
    res.setHeader("Content-Type", "application/json");
    return res.end(JSON.stringify({ error: "Invalid JSON body" }));
  }

  const email = normalizeEmail(body?.email);
  if (!email || !EMAIL_RE.test(email)) {
    res.statusCode = 400;
    res.setHeader("Content-Type", "application/json");
    return res.end(JSON.stringify({ error: "invalid_email", code: "invalid_email" }));
  }

  try {
    const { data: linkData, error: linkError } = await admin.auth.admin.generateLink({
      type: "recovery",
      email,
      options: { redirectTo: recoveryRedirectUrl() }
    });
    if (linkError) {
      const msg = String(linkError.message || "").toLowerCase();
      const status = linkError.status || linkError.code;
      if (
        status === 404 ||
        msg.includes("user not found") ||
        msg.includes("not found") ||
        msg.includes("no user") ||
        msg.includes("invalid email")
      ) {
        res.statusCode = 404;
        res.setHeader("Content-Type", "application/json");
        return res.end(JSON.stringify({ error: "not_registered", code: "not_registered" }));
      }
      console.error("[api/auth/forgot-password] generateLink:", linkError);
      res.statusCode = 502;
      res.setHeader("Content-Type", "application/json");
      return res.end(JSON.stringify({ error: "lookup_failed", code: "lookup_failed" }));
    }

    if (!linkData?.user?.id) {
      res.statusCode = 404;
      res.setHeader("Content-Type", "application/json");
      return res.end(JSON.stringify({ error: "not_registered", code: "not_registered" }));
    }

    const { error: resetError } = await admin.auth.resetPasswordForEmail(email, {
      redirectTo: recoveryRedirectUrl()
    });
    if (resetError) {
      console.error("[api/auth/forgot-password] resetPasswordForEmail:", resetError);
      res.statusCode = 502;
      res.setHeader("Content-Type", "application/json");
      return res.end(JSON.stringify({ error: resetError.message || "reset_failed", code: "reset_failed" }));
    }

    res.statusCode = 200;
    res.setHeader("Content-Type", "application/json");
    return res.end(JSON.stringify({ ok: true }));
  } catch (err) {
    console.error("[api/auth/forgot-password]", err);
    res.statusCode = 502;
    res.setHeader("Content-Type", "application/json");
    return res.end(JSON.stringify({ error: "Bad gateway", code: "reset_failed" }));
  }
};
