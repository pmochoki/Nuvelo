import { cpSync, existsSync, rmSync, writeFileSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const webRoot = resolve(here, "..");
const src = resolve(webRoot, "..", "api");
const dest = resolve(webRoot, "api");

if (!existsSync(src)) {
  console.warn("[sync-api] repo-root api/ not found — keeping web/api as-is");
  process.exit(0);
}

rmSync(dest, { recursive: true, force: true });
cpSync(src, dest, { recursive: true });
writeFileSync(resolve(dest, "package.json"), JSON.stringify({ type: "commonjs" }, null, 2) + "\n");
console.log("[sync-api] copied ../api → web/api");
