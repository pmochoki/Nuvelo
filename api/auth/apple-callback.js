/**
 * POST /api/auth/apple-callback — Apple Sign In form_post return (mobile Safari).
 * Apple POSTs id_token here; we redirect to the SPA hash for signInWithIdToken.
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

    if (state !== "nuvelo-web" || !idToken) {
      res.statusCode = 400;
      return res.end("Invalid Apple sign-in response");
    }

    const hash = new URLSearchParams({
      id_token: idToken,
      state: "nuvelo-web"
    }).toString();
    res.statusCode = 303;
    res.setHeader("Location", `${base}/#${hash}`);
    return res.end();
  } catch (err) {
    console.error("[api/auth/apple-callback]", err);
    res.statusCode = 500;
    return res.end("Apple sign-in failed");
  }
};
