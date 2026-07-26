---
name: generate-app-store-screenshots
description: Generate deterministic, App Store Connect-ready marketing screenshots from authentic transparent framed iPhone captures. Use when capturing, composing, regenerating, localizing, resizing, reviewing, or validating App Store screenshots and widget showcases at exact Apple-supported dimensions.
---

# Generate App Store Screenshots

Use the bundled deterministic compositor. Preserve captured app UI pixel-for-pixel;
never redraw product UI with an image model.

Read `app_store/automation/app_store_workflow.json` first for the app name, scheme,
bundle identifier, locales, output paths, and capture capabilities. Read
`references/app-store-sizes.md` before changing the size preset.

## Render

Render one transparent framed capture:

```bash
python3 skills/generate-app-store-screenshots/scripts/render.py \
  --device-image app_store/screenshots/framed/en-US/01-feature_framed.png \
  --headline "A Truthful Feature Claim" \
  --emphasis "Feature Claim" \
  --subtitle "Short supporting copy that matches the visible UI." \
  --output app_store/screenshots/generated/en-US/01-feature.png
```

Render a localized manifest and create the mandatory review sheet:

```bash
python3 skills/generate-app-store-screenshots/scripts/render_set.py \
  --manifest app_store/aso/screenshots/en-US.json

python3 skills/generate-app-store-screenshots/scripts/review_set.py \
  --manifest app_store/aso/screenshots/en-US.json \
  --output /tmp/app-store-screenshot-review.png
```

Defaults:

- Canvas: `1320x2868`, an accepted 6.9-inch iPhone portrait size.
- Atmospheric background: `assets/asc-screenshot-bg.png`, blended at `0.8`
  opacity over white.
- Atmospheric composition: centered framed phone in the lower three quarters,
  near-black copy, and a pink-to-orange emphasis underline.
- Editorial composition: white canvas, faint rounded outline, centered gray
  eyebrow, large centered SF Rounded Bold headline with tight line spacing, and
  a fully contained centered phone.
- Output: opaque RGB PNG without alpha.

For the clean editorial layout, pass `--style editorial --eyebrow "Short Context"`.
Editorial mode intentionally omits background art, subtitle, underline, and other
decoration. Keep eyebrows short and omit terminal punctuation. Use SF Rounded for
Latin locales, Hiragino Sans for Japanese, and Apple SD Gothic Neo for Korean.
Japanese copy wraps by character when spaces are unavailable.

## Manifest contract

Store repeatable copy, ordering, provenance, and output paths in
`app_store/aso/screenshots/<locale>.json`. Required top-level fields are `locale`,
`size`, `style`, and a non-empty `screenshots` array. Orders must be contiguous
starting at one.

Each item contains:

- `order`, `slug`, `feature`, `status`;
- `deviceImage`, `headline`, `subtitle`, `output`;
- optional `emphasis`, `eyebrow`, `style`, `phoneWidthRatio`,
  `phoneTopRatio`, `sourceImage`, `sourceCredit`, and `captureBrief`.

Use `"status": "needs-capture"` when no authentic framed capture exists.
Batch rendering skips it rather than inventing UI. Use `"ready"` only after
visual verification.

## Fresh-launch authenticity

When the user explicitly requests fresh, current-build, or per-launch screenshots,
do not reuse an existing raw or framed capture:

1. build and launch the current app;
2. reset or seed the deterministic feature state;
3. capture live Simulator UI;
4. frame the new raw capture;
5. update manifest provenance;
6. run the marketing compositor.

Ordinary layout regeneration and localization may reuse the latest approved
authentic capture. Never describe a reused capture as fresh.

Prefer production deep links, documented launch arguments, deterministic fixtures,
and explicit query data over manual navigation. Screenshot mode should suppress
ads, analytics side effects, network-dependent startup, onboarding, permission
prompts, and nondeterministic sample data without changing Release behavior.

For camera or photo-library features, a DEBUG-only fixture loader may read a
licensed local image copied into the installed app's Documents directory. Compile
the loader out of Release builds, never bundle the fixture in the app, and record
source, creator, license, download date, and selection rationale beside the source
asset. Wait for sampling/rendering to settle and verify the visible result before
capture.

## Mandatory Simulator presentation preflight

Immediately before every fresh app, widget, Home Screen, Lock Screen, or App Clip
capture, run:

```bash
.agents/skills/generate-app-store-screenshots/scripts/prepare_simulator.sh <SIMULATOR_UDID>
```

The helper first clears inherited status-bar overrides, then forces:

- time `9:41`;
- battery `100%`, state `discharging`;
- Wi-Fi active with three bars;
- cellular active with four bars;
- data network Wi-Fi;
- empty operator name;
- Light appearance, applied after status-bar normalization.

Capture a verification screenshot. Reject Dark appearance, stale permission
dialogs, incomplete loading, visible debug chrome, or a dirty status bar.

## Source and framing requirements

- Require a transparent framed-device PNG. Stop when the source lacks alpha;
  otherwise its background will obscure the template.
- Preserve the captured screen and device frame exactly.
- Keep marketing claims truthful to the visible feature.
- Use the current repo's approved framing tool. If Frames CLI is configured:

```bash
FRAMES_ASSETS="$HOME/.config/frames/Frames" \
  <frames-python> <frames-cli> \
  -c Silver \
  -o app_store/screenshots/framed/en-US \
  app_store/screenshots/raw/en-US/01-feature.png
```

- Record the source build/version, capture state, fixture provenance, and any
  rejected alternatives in `captureBrief`.

## Widget showcase

Only use this flow when the app ships configurable widgets.

- Keep a dedicated, manually verified template Simulator shut down.
- Arrange the approved widget sizes and kinds on one uncluttered page.
- Choose vivid, distinct data that proves each widget's purpose.
- Reject dark, muddy, duplicated, empty, stale, or error states.
- Do not cover widget artwork with a dark name scrim. A subtle text shadow is
  acceptable.
- Rebuild the template when widget kinds, App Intent schemas, selected entity
  identifiers, or layout changes.

For a fresh current-build capture:

```bash
APP_BUNDLE_ID="<bundle-id>" \
APP_LAUNCH_ARGUMENTS="<optional space-separated arguments>" \
.agents/skills/generate-app-store-screenshots/scripts/capture_widget_showcase.sh \
  <shutdown-template-udid> \
  <current-debug-app-path> \
  app_store/screenshots/raw/en-US/widgets.png
```

The helper clones the template, boots it, installs the current build, launches the
app, applies the mandatory preflight, returns Home, navigates to the configured
widget page, captures, and deletes the disposable clone. Set
`KEEP_WIDGET_CAPTURE_SIMULATOR=1` only for debugging. Set
`WIDGET_PAGE_SWIPE_DIRECTION=left`, `right`, or `none` when the widget page differs
from the default. Installing over the clone preserves system-owned widget placement
and App Intent selections while rendering live WidgetKit output from the supplied
build.

Do not force reseeding when it replaces entity UUIDs used by saved widget
configuration. This template approach avoids repeated widget-gallery clicks while
remaining an authentic live WidgetKit capture.

## Validate

The renderer validates PNG format, exact dimensions, RGB mode, no output alpha,
source transparency, and a 4.5:1 minimum text contrast ratio. Also visually inspect
every output for:

- correct current UI and device frame;
- readable, unclipped, naturally wrapped copy;
- centered and balanced composition;
- full phone visibility in editorial mode;
- no invented UI, extra logos, badges, debug controls, or stale system state;
- truthful localization and feature claims;
- consistent size across the locale set.

If copy overflows, shorten it before shrinking below the renderer's minimum type
sizes. Store the reviewed contact sheet with temporary artifacts, not in App Store
upload folders.
