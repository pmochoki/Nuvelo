/**
 * POST /api/auth/apple-callback — Apple Sign In form_post return (mobile).
 * Apple POSTs id_token here; we forward it to the SPA via sessionStorage + redirect.
 */
const SITE = process.env.VITE_AUTH_REDIRECT_URL || process.env.VITE_SITE_URL || "https://nuvelo.one";

async function readFormBody(req) {
  if (req.body && typeof req.body === "object" && !Buffer.isBuffer(req.body)) {
    return req.body;
  }
  const raw = await new Promise((resolve, reject) => {
    const chunks = [];
    req.on("data", (chunk) => chunks.push(chunk));
    req.on("end", () => resolve(Buffer.concat(chunks).toString("utf8")));
    req.on("error", reject);
  });
  if (!raw) {
    return {};
  }
  return Object.fromEntries(new URLSearchParams(raw));
}

function parseAppleState(state) {
  const value = String(state || "");
  if (!value.startsWith("nuvelo-web")) {
    return { ok: false };
  }
  const parts = value.split(":");
  if (parts.length >= 2 && parts[1]) {
    return { ok: true, nonce: parts.slice(1).join(":") };
  }
  return { ok: true, nonce: "" };
}

function htmlRedirectPage(targetUrl, sessionPayloadB64) {
  const safeUrl = JSON.stringify(targetUrl);
  const safePayload = JSON.stringify(sessionPayloadB64);
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Signing in…</title>
</head>
<body>
  <p style="font-family:system-ui,sans-serif;text-align:center;margin-top:2rem">Signing you in…</p>
  <script>
    try {
      sessionStorage.setItem("nuvelo_apple_return", ${safePayload});
    } catch (e) {}
    location.replace(${safeUrl});
  </script>
</body>
</html>`;
}

/** @param {import("http").IncomingMessage} req @param {import("http").ServerResponse} res */
module.exports = async (req, res) => {
  if (req.method !== "POST") {
    res.statusCode = 405;
    res.setHeader("Allow", "POST");
    return res.end("Method Not Allowed");
  }

  try {
    const fields = await readFormBody(req);
    const idToken = fields.id_token;
    const state = fields.state;
    const error = fields.error;
    const errorDescription = fields.error_description || "";
    const base = String(SITE).replace(/\/$/, "");

    if (error) {
      const params = new URLSearchParams({
        apple_error: error,
        ...(errorDescription ? { apple_error_description: errorDescription } : {})
      });
      res.statusCode = 303;
      res.setHeader("Location", `${base}/?${params.toString()}`);
      return res.end();
    }

    const parsedState = parseAppleState(state);
    if (!parsedState.ok || !idToken) {
      res.statusCode = 400;
      return res.end("Invalid Apple sign-in response");
    }

    const payload = Buffer.from(
      JSON.stringify({ idToken, nonce: parsedState.nonce || "" }),
      "utf8"
    ).toString("base64url");

    res.statusCode = 200;
    res.setHeader("Content-Type", "text/html; charset=utf-8");
    res.setHeader("Cache-Control", "no-store");
    return res.end(htmlRedirectPage(`${base}/?apple_return=1`, payload));
  } catch (err) {
    console.error("[api/auth/apple-callback]", err);
    res.statusCode = 500;
    return res.end("Apple sign-in failed");
  }
};
