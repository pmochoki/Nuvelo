#!/usr/bin/env node
/**
 * Upload Meta App Review demo MP4 (Reviewer instructions → documents-web-1).
 *
 * Uses a persistent browser profile so you stay logged into Meta between runs.
 * First run: log in when the Meta window opens, then the script continues.
 *
 *   npm run upload:meta-review
 */

import { chromium } from "playwright";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");
const PROFILE = path.join(ROOT, ".playwright-meta-profile");
const MP4 = path.join(ROOT, "docs/meta-review-assets/nuvelo-meta-app-review-demo.mp4");
const SUBMISSION_URL =
  "https://developers.facebook.com/apps/4426473634349036/app-review/submissions/?submission_id=4426473721015694&business_id=1785335622642235";

async function gotoReviewerInstructions(page) {
  await page.goto(SUBMISSION_URL, { waitUntil: "domcontentloaded", timeout: 120000 });
  await page.waitForTimeout(3000);

  for (let attempt = 0; attempt < 5; attempt++) {
    if ((await page.locator("#documents-web-1").count()) > 0) {
      return;
    }
    await page.evaluate(() => {
      const go = [...document.querySelectorAll("button")].find((b) =>
        /Go to reviewer instructions/i.test(b.innerText || "")
      );
      if (go) {
        go.click();
        return;
      }
      const link = [...document.querySelectorAll("a")].find((a) =>
        a.innerText?.includes("Reviewer instructions")
      );
      link?.click();
    });
    await page.waitForTimeout(2500);
  }

  await page.waitForSelector("#documents-web-1", { timeout: 120000 });
}

async function waitForMetaLogin(page) {
  const needsLogin = await page.evaluate(
    () =>
      Boolean(document.querySelector('input[name="email"], input[name="pass"]')) &&
      !document.getElementById("documents-web-1")
  );
  if (!needsLogin) {
    return;
  }
  console.log("\nLog into Meta in the Playwright browser window (up to 5 minutes)…");
  console.log("After login, the script will open Reviewer instructions and upload the MP4.\n");
  await page.waitForFunction(
    () =>
      Boolean(document.getElementById("documents-web-1")) ||
      !document.querySelector('input[name="email"], input[name="pass"]'),
    { timeout: 300000 }
  );
  if ((await page.locator("#documents-web-1").count()) === 0) {
    await gotoReviewerInstructions(page);
  }
}

async function main() {
  const context = await chromium.launchPersistentContext(PROFILE, {
    headless: false,
    viewport: { width: 1280, height: 720 },
    locale: "en-US"
  });

  const page = context.pages()[0] || (await context.newPage());

  try {
    await gotoReviewerInstructions(page);
    await waitForMetaLogin(page);

    console.log("Uploading demo MP4…");
    const [fileChooser] = await Promise.all([
      page.waitForEvent("filechooser", { timeout: 30000 }),
      page.locator("#js_5v").click()
    ]);
    await fileChooser.setFiles(MP4);
    await page.waitForTimeout(5000);

    const uploaded = await page.evaluate(() =>
      document.body.innerText.includes("nuvelo-meta-app-review-demo")
    );

    if (uploaded) {
      console.log("Upload confirmed — file name visible on page.");
    } else {
      console.log("File chooser completed; verify upload in Meta UI (thumbnail / filename).");
    }

    console.log("\nLeave the window open to confirm, then close it when done.");
    await page.waitForTimeout(8000);
  } finally {
    await context.close();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
