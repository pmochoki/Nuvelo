const { applyCors } = require("../_cors");
const store = require("../_listingsStore");

/** GET /api/listings/:id — single listing from local store */
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

  const listing = store.getById(id);
  if (!listing) {
    res.statusCode = 404;
    return res.end(JSON.stringify({ error: "Listing not found" }));
  }

  res.statusCode = 200;
  res.setHeader("Content-Type", "application/json");
  return res.end(JSON.stringify(listing));
};
