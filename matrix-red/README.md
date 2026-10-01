# Red Matrix Rain — iPhone 17 Pro Max wallpaper

Red "digital rain" sized for the iPhone 17 Pro Max screen (1320 × 2868).

| File | What it is |
| --- | --- |
| `matrix-red-iphone17promax.mp4` | 8 s, 30 fps **seamless loop** — the last frame flows straight into the first |
| `matrix-red-iphone17promax.png` | Still frame for a static wallpaper |
| `index.html` | The live animation; loops forever full screen in Safari |
| `tools/render.mjs` | Re-renders the MP4 + PNG with headless Chromium + ffmpeg |

## Set it as a moving wallpaper

iOS can't use an MP4 directly as a wallpaper, but it can use a Live Photo:

1. Save the MP4 to Photos.
2. Convert it to a Live Photo with a free app such as **intoLive** or **VideoToLive**.
3. Settings → Wallpaper → Add New Wallpaper → Photos → pick the Live Photo,
   then tap the Live Photo (▶︎) button so it moves.

Note: iOS plays a Live Photo wallpaper once, for a few seconds, each time the
lock screen wakes. It can't play nonstop. To keep it moving forever, open
`index.html` in Safari (Share → Add to Home Screen opens it full screen),
or set the MP4 to repeat in any player.

## Re-render

```sh
ln -s "$(npm root -g)" node_modules   # needs playwright installed
node tools/render.mjs . 1             # output dir, times to repeat the loop
```

URL options for `index.html`: `?seed=1234` (a different pattern) and `?cols=24` (bigger glyphs).
