import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const DEFAULT_BACKEND = "https://nuvelo-backend.onrender.com";

Deno.serve(async () => {
  const base = (
    Deno.env.get("LISTINGS_BACKEND_URL") ||
    Deno.env.get("NUVELO_API_URL") ||
    DEFAULT_BACKEND
  ).replace(/\/+$/, "");
  const tryUrls = [`${base}/health`, base];
  let lastStatus = 0;
  let lastBody = "";
  for (const url of tryUrls) {
    try {
      const res = await fetch(url, { method: "GET" });
      lastStatus = res.status;
      lastBody = await res.text();
      console.log(`[keep-alive] ${url} -> ${lastStatus}`);
      if (res.ok || lastStatus < 500) {
        break;
      }
    } catch (e) {
      console.error(`[keep-alive] ${url}`, e);
    }
  }
  return new Response(JSON.stringify({ ok: true, status: lastStatus, snippet: lastBody.slice(0, 200) }), {
    status: 200,
    headers: { "Content-Type": "application/json" }
  });
});
