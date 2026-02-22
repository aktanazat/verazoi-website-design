import { chromium } from "playwright";
import { execSync } from "child_process";
import { mkdirSync, readdirSync, unlinkSync, rmdirSync } from "fs";
import { join } from "path";

const FRAMES_DIR = join(process.cwd(), "_frames");
const OUTPUT = join(process.cwd(), "demo.gif");
const WIDTH = 1280;
const HEIGHT = 800;
const SCROLL_PAUSE = 60; // ms between frames
const SCROLL_STEP = 6; // px per frame
const HOLD_FRAMES = 40; // frames to hold at top before scrolling

// clean up old frames
try {
  readdirSync(FRAMES_DIR).forEach((f) => unlinkSync(join(FRAMES_DIR, f)));
  rmdirSync(FRAMES_DIR);
} catch {}
mkdirSync(FRAMES_DIR, { recursive: true });

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: WIDTH, height: HEIGHT } });

await page.goto("http://localhost:3000", { waitUntil: "networkidle" });
// let mount animations finish
await page.waitForTimeout(2000);

// get total scrollable height
const totalHeight = await page.evaluate(() => document.body.scrollHeight);
const maxScroll = totalHeight - HEIGHT;

let frame = 0;
const pad = (n) => String(n).padStart(5, "0");

// hold at the top
for (let i = 0; i < HOLD_FRAMES; i++) {
  await page.screenshot({ path: join(FRAMES_DIR, `frame_${pad(frame++)}.png`) });
}

// smooth scroll down
let scrollY = 0;
while (scrollY < maxScroll) {
  scrollY = Math.min(scrollY + SCROLL_STEP, maxScroll);
  await page.evaluate((y) => window.scrollTo(0, y), scrollY);
  await page.waitForTimeout(SCROLL_PAUSE);
  await page.screenshot({ path: join(FRAMES_DIR, `frame_${pad(frame++)}.png`) });
}

// hold at the bottom
for (let i = 0; i < HOLD_FRAMES; i++) {
  await page.screenshot({ path: join(FRAMES_DIR, `frame_${pad(frame++)}.png`) });
}

await browser.close();

console.log(`Captured ${frame} frames. Converting to GIF...`);

// use ffmpeg to create a high-quality GIF
execSync(
  `ffmpeg -y -framerate 16 -i "${FRAMES_DIR}/frame_%05d.png" ` +
    `-vf "scale=${WIDTH}:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=128:stats_mode=diff[p];[s1][p]paletteuse=dither=bayer:bayer_scale=3" ` +
    `"${OUTPUT}"`,
  { stdio: "inherit" }
);

console.log(`Done! GIF saved to: ${OUTPUT}`);

// clean up frames
readdirSync(FRAMES_DIR).forEach((f) => unlinkSync(join(FRAMES_DIR, f)));
rmdirSync(FRAMES_DIR);
