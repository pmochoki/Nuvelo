import { resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { defineConfig } from "vite";

const __dirname = fileURLToPath(new URL(".", import.meta.url));

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

export default defineConfig({
  root: ".",
  publicDir: "public",
  plugins: [moveModuleScriptToBody()],
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
