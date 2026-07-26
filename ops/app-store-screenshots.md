# App Store Screenshots — Pipeline Runbook

## Overview

Screenshots pipeline: fresh screenshots → frame with frames-cli → scaffold with compose_simple.py → enhance with Gemini → crop/resize.

## Key Learnings (Debugged)

### Problem: frames-cli outputs have transparent background outside device

frames-cli wraps screenshots in an iPhone frame with transparent pixels around the device. When Pillow's `alpha_composite` composites these, transparent areas become black.

**Fix:** Before any compositing, fill all transparent pixels with the background color:
```python
def fill_transparent_with_bg(img, bg_rgb):
    if img.mode != 'RGBA':
        img = img.convert('RGBA')
    bg = Image.new('RGBA', img.size, (*bg_rgb, 255))
    result = Image.alpha_composite(bg, img)
    return result
```

### Problem: Phone taking entire canvas (no vertical positioning)

Phone was scaled to fill entire canvas width, leaving no space for headline text above it.

**Fix:** Explicit sizing and positioning:
```python
PHONE_SCALE = 0.82      # Phone takes 82% of canvas width (not full)
PHONE_TOP = 650          # Phone top edge at y=650 (text ends ~600, so ~50px gap)
```

### Problem: Text overflowing past safe margins

Long headlines like "SEE YOUR SPENDING" exceeded canvas width at large font sizes.

**Fix:** Constrain text to 70% of canvas width (15% margin each side):
```python
MAX_TEXT_W = int(CANVAS_W * 0.70)
MAX_VERB_W = int(CANVAS_W * 0.70)
# Pass max_w to BOTH verb and description draw calls
```

### Problem: Double framing

Original compose.py tried to overlay a device_frame.png template on top of already-framed screenshots from frames-cli.

**Fix:** Use `compose_simple.py` for pre-framed screenshots — it only adds text and background, no extra frame.

### Breakout elements

Pop-out UI panels require Gemini enhancement stage — the scaffold is a flat composite and cannot create depth/shadow effects. Add breakout instructions in enhancement prompts.

## Working Constants

```
PHONE_SCALE = 0.82
PHONE_TOP = 650
MAX_TEXT_W = 70% of canvas
Canvas: 1290 × 2796 (iPhone 6.7" App Store dimensions)
Brand color: #6D28D9 (Vibrant Purple)
```

## Pipeline Steps

1. **Fresh screenshots** → put in `screenshots/` with clean names (no spaces)
2. **Frame** → `frames frame <screenshot> --device "iPhone 17 Pro Portrait" --color "Deep Blue" --output screenshots/<name>_framed`
3. **Scaffold** → `python3 compose_simple.py --bg "#6D28D9" --verb "TRACK" --desc "ALL YOUR SUBSCRIPTIONS" --screenshot screenshots/home_framed/home_framed.png --output screenshots/01-track/scaffold.png`
4. **Enhance** → Gemini with breakout instructions for widgets/notification/app-intents
5. **Crop/resize** → `TARGET_W=1290 TARGET_H=2796` then sips crop + resize

## Files

- `compose_simple.py` — working scaffold generator (no extra frame overlay)
- frames-cli — pre-frames screenshots before scaffolding
- frames output: ~1350×2760 (frames-cli adds device frame padding)
- Original simulator screenshots: 1206×2622

## Tips

- Filenames with spaces break frames-cli — rename to remove spaces first
- Always create output directories before running compose_simple.py
- Scaffold is RGB PNG at 1290×2796 — ready for Gemini enhancement

---

## Checklist

Before marking the screenshot pipeline as done:

- [ ] Fresh simulator screenshots are captured at the correct resolution (1290×2796 for 6.7")
- [ ] Clean status bar override is applied (`simctl status_bar override`)
- [ ] frames-cli is installed and `frames doctor` reports OK
- [ ] `compose_simple.py` produces scaffolds with readable text and correct phone positioning
- [ ] Transparent pixels are filled with the background color before compositing
- [ ] Gemini enhancement prompt includes breakout instructions if needed
- [ ] Final exports are cropped and resized to exact App Store dimensions
- [ ] All screenshot filenames have no spaces