const { applyCors } = require("./_cors");
const { isListingsDbEnabled } = require("./_supabaseAdmin");

/** GET /api/health — liveness + whether Supabase listings DB is configured */
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
  res.statusCode = 200;
  res.setHeader("Content-Type", "application/json");
  return res.end(
    JSON.stringify({
      status: "ok",
      listingsDb: isListingsDbEnabled(),
      at: new Date().toISOString()
    })
  );
};
