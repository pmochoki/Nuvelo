const { applyCors } = require("./_cors");
const { backendBase } = require("./_backend");

/** GET /api/health → backend /health */
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
  const target = `${backendBase()}/health`;
  try {
    const upstream = await fetch(target);
    const text = await upstream.text();
    res.statusCode = upstream.status;
    res.setHeader("Content-Type", upstream.headers.get("content-type") || "application/json");
    return res.end(text);
  } catch (err) {
    res.statusCode = 502;
    return res.end(JSON.stringify({ error: "Bad gateway", message: err?.message }));
  }
};
