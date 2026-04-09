const { applyCors } = require("../_cors");
const { backendBase, queryStringFromReq } = require("../_backend");

/** GET /api/listings/:id → backend /listings/:id */
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

  const id = req.query?.id;
  if (!id || typeof id !== "string") {
    res.statusCode = 400;
    return res.end(JSON.stringify({ error: "Missing listing id" }));
  }

  const backend = backendBase();
  const search = queryStringFromReq(req);
  const target = `${backend}/listings/${encodeURIComponent(id)}${search}`;

  try {
    const upstream = await fetch(target, { method: "GET" });
    const text = await upstream.text();
    res.statusCode = upstream.status;
    res.setHeader("Content-Type", upstream.headers.get("content-type") || "application/json");
    return res.end(text);
  } catch (err) {
    console.error("[api/listings/[id]] proxy error:", err);
    res.statusCode = 502;
    return res.end(
      JSON.stringify({
        error: "Bad gateway",
        message: err?.message || "Could not reach listings backend"
      })
    );
  }
};
