/**
 * CORS for browser calls from nuvelo.one / Vercel previews / local dev.
 * @param {import("http").IncomingMessage} req
 * @param {import("http").ServerResponse} res
 */
function applyCors(req, res) {
  const origin = req.headers.origin;
  const allowed =
    !origin ||
    origin === "https://nuvelo.one" ||
    origin === "https://www.nuvelo.one" ||
    /^https:\/\/[\w-]+\.vercel\.app$/.test(origin) ||
    /^http:\/\/localhost:\d+$/.test(origin) ||
    /^http:\/\/127\.0\.0\.1:\d+$/.test(origin);

  res.setHeader(
    "Access-Control-Allow-Origin",
    allowed && origin ? origin : "*"
  );
  res.setHeader("Vary", "Origin");
  res.setHeader(
    "Access-Control-Allow-Methods",
    "GET, POST, PUT, PATCH, DELETE, OPTIONS"
  );
  res.setHeader(
    "Access-Control-Allow-Headers",
    "Content-Type, Authorization, X-Requested-With"
  );
  res.setHeader("Access-Control-Max-Age", "86400");
}

module.exports = { applyCors };
