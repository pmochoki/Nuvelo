import { resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { defineConfig } from "vite";

const __dirname = fileURLToPath(new URL(".", import.meta.url));

const DEFAULT_ADMIN_SUPABASE_URL = "https://ahiujuljjbozmfwoqtli.supabase.co";

/** Bake VITE_SUPABASE_* into admin.html at build (Vercel env). Dev: use web/.env */
function injectAdminHtmlEnv() {
  return {
    name: "inject-admin-html-env",
    transformIndexHtml(html) {
      if (!html.includes("__ADMIN_VITE_SUPABASE_URL_JSON__")) {
        return html;
      }
      const url = process.env.VITE_SUPABASE_URL || DEFAULT_ADMIN_SUPABASE_URL;
      const anon = process.env.VITE_SUPABASE_ANON_KEY || "";
      return html
        .replaceAll("__ADMIN_VITE_SUPABASE_URL_JSON__", JSON.stringify(url))
        .replaceAll("__ADMIN_VITE_SUPABASE_ANON_JSON__", JSON.stringify(anon));
    }
  };
}

/** Vite injects the entry script in <head>; modules are deferred but resolving #app at top-level is safer after <body> exists. */
function moveModuleScriptToBody() {
  return {
    name: "move-module-script-to-body",
    apply: "build",
    transformIndexHtml(html) {
      const re =
        /<script type="module" crossorigin src="([^"]+)"><\/script>\s*/;
      const m = html.match(re);
      if (!m) {
        return html;
      }
      const full = m[0];
      const src = m[1];
      const stripped = html.replace(full, "");
      const tag = `<script type="module" crossorigin src="${src}"></script>`;
      return stripped.replace("</body>", `    ${tag}\n  </body>`);
    }
  };
}

function spaHistoryFallback() {
  return {
    name: "spa-history-fallback",
    configureServer(server) {
      server.middlewares.use((req, _res, next) => {
        const raw = req.url || "";
        const q = raw.indexOf("?");
        const pathOnly = (q >= 0 ? raw.slice(0, q) : raw) || "";
        const search = q >= 0 ? raw.slice(q) : "";
        if (
          pathOnly === "/" ||
          pathOnly === "" ||
          pathOnly.startsWith("/assets/") ||
          pathOnly.startsWith("/api") ||
          pathOnly.includes(".") ||
          pathOnly.endsWith(".html")
        ) {
          return next();
        }
        req.url = `/index.html${search}`;
        next();
      });
    }
  };
}

export default defineConfig({
  root: ".",
  publicDir: "public",
  plugins: [injectAdminHtmlEnv(), moveModuleScriptToBody(), spaHistoryFallback()],
  server: {
    proxy: {
      "/api": {
        target: "http://127.0.0.1:3000",
        changeOrigin: true
      }
    }
  },
  build: {
    outDir: "dist",
    emptyOutDir: true,
    rollupOptions: {
      input: {
        main: resolve(__dirname, "index.html"),
        admin: resolve(__dirname, "admin.html")
      }
    }
  }
});
