const { applyCors } = require("./_cors");
const store = require("./_listingsStore");
const { isListingsDbEnabled } = require("./_supabaseAdmin");
const { listListings } = require("./_listingsDb");

const SITE = "https://nuvelo.one";

function escXml(s) {
  return String(s || "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

module.exports = async (req, res) => {
  applyCors(req, res);
  if (req.method === "OPTIONS") {
    res.statusCode = 204;
    return res.end();
  }
  if (req.method !== "GET") {
    res.statusCode = 405;
    return res.end();
  }
  try {
    let rows = [];
    if (isListingsDbEnabled()) {
      rows = await listListings({});
    } else {
      rows = store.getAll().filter((l) => !l.status || l.status === "approved");
    }
    const urls = rows.map((l) => {
      const id = escXml(l.id);
      return `  <url>
    <loc>${SITE}/listing/${id}</loc>
    <changefreq>weekly</changefreq>
    <priority>0.6</priority>
  </url>`;
    });
    const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls.join("\n")}
</urlset>`;
    res.setHeader("Content-Type", "application/xml; charset=utf-8");
    res.setHeader("Cache-Control", "public, s-maxage=3600, stale-while-revalidate=86400");
    res.statusCode = 200;
    return res.end(xml);
  } catch (e) {
    console.error("[sitemap-listings]", e);
    res.statusCode = 500;
    return res.end("");
  }
};
