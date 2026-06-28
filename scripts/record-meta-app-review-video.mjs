#!/usr/bin/env node
/**
 * Record a short screen demo for Meta App Review (Reviewer instructions → optional upload).
 *
 * Shows: nuvelo.one → Sign in → Continue with Facebook → Facebook OAuth screen.
 * Does not log in (no credentials stored). Reviewers see the integration entry point.
 *
 * Usage:
 *   npm install
 *   npx playwright install chromium
 *   npm run record:meta-review
 *
 * Output: docs/meta-review-assets/nuvelo-meta-app-review-demo.mp4
 */

import { mkdir, readdir, rename, unlink } from "node:fs/promises";
import { spawnSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");
const OUT_DIR = path.join(ROOT, "docs/meta-review-assets");
const OUT_MP4 = path.join(OUT_DIR, "nuvelo-meta-app-review-demo.mp4");
const SITE = process.env.NUVELO_SITE_URL || "https://nuvelo.one";
const PAUSE_MS = Number(process.env.META_REVIEW_PAUSE_MS || 1800);

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

async function resolveFfmpeg() {
  try {
    const mod = await import("@ffmpeg-installer/ffmpeg");
    const bin = mod.default?.path ?? mod.path ?? mod.default;
    if (typeof bin === "string") return bin;
  } catch {
    /* optional dependency may be missing on some platforms */
  }
  const which = spawnSync("which", ["ffmpeg"], { encoding: "utf8" });
  if (which.status === 0 && which.stdout.trim()) {
    return which.stdout.trim();
  }
  return null;
}

function convertWebmToMp4(ffmpeg, webmPath, mp4Path) {
  const args = [
    "-y",
    "-i",
    webmPath,
    "-c:v",
    "libx264",
    "-pix_fmt",
    "yuv420p",
    "-movflags",
    "+faststart",
    "-an",
    mp4Path
  ];
  const r = spawnSync(ffmpeg, args, { encoding: "utf8" });
  if (r.status !== 0) {
    throw new Error(r.stderr || "ffmpeg conversion failed");
  }
}

async function findLatestWebm(dir) {
  const names = await readdir(dir);
  const webms = names.filter((n) => n.endsWith(".webm"));
  if (!webms.length) return null;
  return path.join(dir, webms[webms.length - 1]);
}

async function main() {
  let chromium;
  try {
    ({ chromium } = await import("playwright"));
  } catch {
    console.error(
      "Playwright not installed. Run:\n  npm install\n  npx playwright install chromium"
    );
    process.exit(1);
  }

  await mkdir(OUT_DIR, { recursive: true });
  const videoDir = path.join(OUT_DIR, ".playwright-videos");
  await mkdir(videoDir, { recursive: true });

  console.log(`Recording Meta App Review demo (${SITE})…`);

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 },
    recordVideo: { dir: videoDir, size: { width: 1280, height: 720 } },
    locale: "en-US"
  });
  const page = await context.newPage();

  try {
    await page.goto(SITE, { waitUntil: "networkidle", timeout: 60000 });
    await sleep(PAUSE_MS);

    await page.locator("#auth-btn").click({ timeout: 15000 });
    await sleep(PAUSE_MS);

    await page.locator("#auth-fb-stub").waitFor({ state: "visible", timeout: 10000 });
    await sleep(800);
    await page.locator("#auth-fb-stub").click();

    try {
      await page.waitForURL(/facebook\.com/i, { timeout: 20000 });
      await sleep(PAUSE_MS * 2);
    } catch {
      console.warn(
        "Did not reach facebook.com (app may be Unpublished). Keeping modal/error in recording."
      );
      await sleep(PAUSE_MS * 2);
    }
  } finally {
    await context.close();
    await browser.close();
  }

  const webmPath = await findLatestWebm(videoDir);
  if (!webmPath) {
    console.error("No video file produced.");
    process.exit(1);
  }

  const ffmpeg = await resolveFfmpeg();
  if (ffmpeg) {
    try {
      convertWebmToMp4(ffmpeg, webmPath, OUT_MP4);
      await unlink(webmPath).catch(() => {});
      console.log(`\nSaved MP4 for Meta upload:\n  ${OUT_MP4}`);
    } catch (err) {
      const fallback = path.join(OUT_DIR, "nuvelo-meta-app-review-demo.webm");
      await rename(webmPath, fallback);
      console.warn(`MP4 conversion failed (${err.message}). WebM saved:\n  ${fallback}`);
      console.warn("Meta accepts .mp4 or .mov — convert with QuickTime or ffmpeg, then upload.");
    }
  } else {
    const fallback = path.join(OUT_DIR, "nuvelo-meta-app-review-demo.webm");
    await rename(webmPath, fallback);
    console.log(`\nSaved WebM (install ffmpeg for auto MP4):\n  ${fallback}`);
  }

  console.log(`
Upload in Meta Developer Portal:
  App Review → your submission → Reviewer instructions → documents-web-1
  Drag and drop: nuvelo-meta-app-review-demo.mp4
`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
