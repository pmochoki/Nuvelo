const { applyCors } = require("../_cors");
const { backendBase } = require("../_backend");

/** POST /api/auth/login → backend /auth/login */
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

  const backend = backendBase();
  const target = `${backend}/auth/login`;

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
    console.error("[api/auth/login] proxy error:", err);
    res.statusCode = 502;
    return res.end(
      JSON.stringify({
        error: "Bad gateway",
        message: err?.message || "Could not reach auth backend"
      })
    );
  }
};
