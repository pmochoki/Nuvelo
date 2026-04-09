const { applyCors } = require("../_cors");
const { backendBase, queryStringFromReq } = require("../_backend");

/**
 * GET /api/listings?…  → backend /listings
 * POST /api/listings   → backend /listings
 */
module.exports = async (req, res) => {
  applyCors(req, res);
  if (req.method === "OPTIONS") {
    res.statusCode = 204;
    return res.end();
  }

  if (req.method !== "GET" && req.method !== "POST") {
    res.statusCode = 405;
    return res.end(JSON.stringify({ error: "Method not allowed" }));
  }

  const backend = backendBase();
  const search = req.method === "GET" ? queryStringFromReq(req) : "";
  const target = `${backend}/listings${search}`;

  try {
    const headers = { "Content-Type": "application/json" };
    const init = {
      method: req.method,
      headers
    };
    if (req.method === "POST") {
      init.body = JSON.stringify(req.body ?? {});
    }

    const upstream = await fetch(target, init);
    const text = await upstream.text();
    res.statusCode = upstream.status;
    res.setHeader("Content-Type", upstream.headers.get("content-type") || "application/json");
    return res.end(text);
  } catch (err) {
    console.error("[api/listings] proxy error:", err);
    res.statusCode = 502;
    return res.end(
      JSON.stringify({
        error: "Bad gateway",
        message: err?.message || "Could not reach listings backend",
        hint: "Set LISTINGS_BACKEND_URL on Vercel if the default Render URL is down."
      })
    );
  }
};
