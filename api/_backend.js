/**
 * Upstream listings API (Render or self-hosted). Vercel: set `LISTINGS_BACKEND_URL` or
 * `NUVELO_API_URL` so `/api/*` routes can proxy; default is the public Render demo host.
 */
function backendBase() {
  const raw =
    process.env.LISTINGS_BACKEND_URL ||
    process.env.NUVELO_API_URL ||
    "https://nuvelo-backend.onrender.com";
  return String(raw).replace(/\/+$/, "");
}

/**
 * @param {import("http").IncomingMessage} req
 * @param {string} pathname e.g. "/listings" or "/auth/login"
 */
function queryStringFromReq(req) {
  const q = req.query || {};
  const params = { ...q };
  delete params.path;
  delete params.slug;
  delete params.id;
  const usp = new URLSearchParams();
  for (const [k, v] of Object.entries(params)) {
    if (v === undefined || v === null) {
      continue;
    }
    if (Array.isArray(v)) {
      v.forEach((item) => usp.append(k, String(item)));
    } else {
      usp.set(k, String(v));
    }
  }
  const s = usp.toString();
  return s ? `?${s}` : "";
}

module.exports = { backendBase, queryStringFromReq };
