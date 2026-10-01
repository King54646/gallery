// Renders index.html?render to an MP4 + still PNG at iPhone 17 Pro Max resolution.
// Usage: node tools/render.mjs [seconds=6] [outDir=.]
import { chromium } from 'playwright';
import { spawn } from 'node:child_process';
import { pathToFileURL } from 'node:url';
import path from 'node:path';

const W = 1320, H = 2868, FPS = 30;
const seconds = Number(process.argv[2]) || 6;
const outDir = path.resolve(process.argv[3] || '.');
const page_ = pathToFileURL(path.resolve(import.meta.dirname, '../index.html')).href + `?render&w=${W}&h=${H}`;

const browser = await chromium.launch({ executablePath: process.env.CHROMIUM || undefined });
const page = await browser.newPage({ viewport: { width: W, height: H }, deviceScaleFactor: 1 });
await page.goto(page_);
await page.evaluate(() => window.renderReady);

const ff = spawn('ffmpeg', ['-y', '-loglevel', 'error', '-f', 'image2pipe', '-framerate', String(FPS), '-i', '-',
  '-c:v', 'libx264', '-preset', 'slow', '-crf', '16', '-pix_fmt', 'yuv420p', '-movflags', '+faststart',
  path.join(outDir, 'matrix-red-iphone17promax.mp4')], { stdio: ['pipe', 'inherit', 'inherit'] });

const canvas = page.locator('#c');
for (let i = 0; i < seconds * FPS; i++) {
  await page.evaluate(() => window.renderFrame());
  const png = await canvas.screenshot({ type: 'png' });
  if (i === 0) await import('node:fs').then(fs => fs.writeFileSync(path.join(outDir, 'matrix-red-iphone17promax.png'), png));
  if (!ff.stdin.write(png)) await new Promise(r => ff.stdin.once('drain', r));
  if (i % 30 === 0) process.stdout.write(`frame ${i}/${seconds * FPS}\r`);
}
ff.stdin.end();
await new Promise(r => ff.on('close', r));
await browser.close();
console.log('\ndone');
