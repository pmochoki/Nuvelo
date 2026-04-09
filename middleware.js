/**
 * Vercel Routing Middleware (Edge) — Prerender.io for search/social crawlers.
 * Set PRERENDER_TOKEN in Vercel (server-side only; do not use VITE_ prefix).
 *
 * @see https://docs.prerender.io/docs/11-best-practices
 */
const BOTS = [
  "googlebot",
  "bingbot",
  "yandexbot",
  "duckduckbot",
  "slurp",
  "baiduspider",
  "facebookexternalhit",
  "twitterbot",
  "linkedinbot",
  "whatsapp",
  "telegrambot",
  "slackbot",
  "discordbot",
  "rogerbot",
  "embedly",
  "showyoubot",
  "outbrain",
  "pinterest",
  "vkshare",
  "w3c_validator",
  "prerender"
];

function isBot(ua) {
  const s = (ua || "").toLowerCase();
  return BOTS.some((b) => s.includes(b));
}

export const config = {
  matcher: ["/((?!api/|.*\\..*).*)"]
};

export default async function middleware(request) {
  const ua = request.headers.get("user-agent") || "";
  const token = process.env.PRERENDER_TOKEN;

  if (!isBot(ua) || !token) {
    return fetch(request);
  }

  const target = `https://service.prerender.io/${encodeURIComponent(request.url)}`;
  let res;
  try {
    res = await fetch(target, {
      headers: {
        "X-Prerender-Token": token
      },
      redirect: "manual"
    });
  } catch (e) {
    console.error("[prerender] fetch failed", e);
    return fetch(request);
  }

  const headers = new Headers(res.headers);
  if (!headers.has("content-type")) {
    headers.set("Content-Type", "text/html; charset=utf-8");
  }

  return new Response(res.body, {
    status: res.status,
    statusText: res.statusText,
    headers
  });
}
