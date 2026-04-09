const { applyCors } = require("../../../_cors");
const { backendBase } = require("../../../_backend");

/** POST /api/admin/listings/:id/status → backend /admin/listings/:id/status */
module.exports = async (req, res) => {
  applyCors(req, res);
  if (req.method === "OPTIONS") {
    res.statusCode = 204;
    return res.end();
  }
  if (req.method !== "POST") {
    res.statusCode = 405;
    return res.end(JSON.stringify({ error: "Method not allowed" }));
  }

  const id = req.query?.id;
  if (!id || typeof id !== "string") {
    res.statusCode = 400;
    return res.end(JSON.stringify({ error: "Missing listing id" }));
  }

  const backend = backendBase();
  const target = `${backend}/admin/listings/${encodeURIComponent(id)}/status`;

  try {
    const upstream = await fetch(target, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(req.body ?? {})
    });
    const text = await upstream.text();
    res.statusCode = upstream.status;
    res.setHeader("Content-Type", upstream.headers.get("content-type") || "application/json");
    return res.end(text);
  } catch (err) {
    console.error("[api/admin/listings/[id]/status] proxy error:", err);
    res.statusCode = 502;
    return res.end(
      JSON.stringify({
        error: "Bad gateway",
        message: err?.message || "Could not reach admin API"
      })
    );
  }
};
