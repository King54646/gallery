// Renders index.html?render to a seamlessly looping MP4 + still PNG at
// iPhone 17 Pro Max resolution.
// Usage: node tools/render.mjs [outDir=.] [repeats=1]
//   repeats > 1 concatenates the loop that many times into a longer video.
import { chromium } from 'playwright';
import { spawn } from 'node:child_process';
import { pathToFileURL } from 'node:url';
import fs from 'node:fs';
import path from 'node:path';

const W = 1320, H = 2868, FPS = 30;
const outDir = path.resolve(process.argv[2] || '.');
const repeats = Number(process.argv[3]) || 1;
const url = pathToFileURL(path.resolve(import.meta.dirname, '../index.html')).href + `?render&w=${W}&h=${H}`;

const browser = await chromium.launch({ executablePath: process.env.CHROMIUM || undefined });
const page = await browser.newPage({ viewport: { width: W, height: H }, deviceScaleFactor: 1 });
await page.goto(url);
await page.evaluate(() => window.renderReady);
const loop = await page.evaluate(() => window.LOOP_FRAMES);
const canvas = page.locator('#c');
const frame = async t => { await page.evaluate(t => window.renderFrame(t), t); return canvas.screenshot({ type: 'png' }); };

await frame(0);                                      // warm-up: the first draw rasterizes the font
const frames = [];
for (let t = 0; t < loop; t++) {
  frames.push(await frame(t));
  if (t % 30 === 0) process.stdout.write(`frame ${t}/${loop}\r`);
}
// Sanity check: the frame after the last must be identical to the first.
if (!(await frame(loop)).equals(frames[0])) throw new Error('animation does not loop seamlessly');
fs.writeFileSync(path.join(outDir, 'matrix-red-iphone17promax.png'), frames[0]);
await browser.close();

const ff = spawn('ffmpeg', ['-y', '-loglevel', 'error', '-f', 'image2pipe', '-framerate', String(FPS), '-i', '-',
  '-c:v', 'libx264', '-preset', 'slow', '-crf', '16', '-pix_fmt', 'yuv420p', '-movflags', '+faststart',
  path.join(outDir, 'matrix-red-iphone17promax.mp4')], { stdio: ['pipe', 'inherit', 'inherit'] });
for (let r = 0; r < repeats; r++)
  for (const png of frames) if (!ff.stdin.write(png)) await new Promise(res => ff.stdin.once('drain', res));
ff.stdin.end();
await new Promise(res => ff.on('close', res));
console.log(`\ndone: ${loop} frame loop x${repeats}`);
