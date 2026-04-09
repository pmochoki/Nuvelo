const { applyCors } = require("../../_cors");
const { backendBase, queryStringFromReq } = require("../../_backend");

/** GET /api/admin/listings?… → backend /admin/listings */
module.exports = async (req, res) => {
  applyCors(req, res);
  if (req.method === "OPTIONS") {
    res.statusCode = 204;
    return res.end();
  }
  if (req.method !== "GET") {
    res.statusCode = 405;
    return res.end(JSON.stringify({ error: "Method not allowed" }));
  }

  const backend = backendBase();
  const search = queryStringFromReq(req);
  const target = `${backend}/admin/listings${search}`;

  try {
    const upstream = await fetch(target, { method: "GET" });
    const text = await upstream.text();
    res.statusCode = upstream.status;
    res.setHeader("Content-Type", upstream.headers.get("content-type") || "application/json");
    return res.end(text);
  } catch (err) {
    console.error("[api/admin/listings] proxy error:", err);
    res.statusCode = 502;
    return res.end(
      JSON.stringify({
        error: "Bad gateway",
        message: err?.message || "Could not reach admin API"
      })
    );
  }
};
