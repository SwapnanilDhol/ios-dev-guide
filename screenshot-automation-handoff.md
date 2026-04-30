# SubscriptionTracker Screenshot Automation Handoff

This is a full operational handoff for `SubscriptionTracker` screenshot generation and UI automation work done on Apr 24, 2026.

Repo path:
- `/Users/swapnanildhol/Desktop/iOS-Projects/SubscriptionTracker`

Primary goal reached:
- Build + run latest app on simulator
- Home-first Maestro automation (skip onboarding for demo)
- Clean status bar captures
- Framed output generation (both compose.py pipeline and `frames-cli`)
- Gemini image edits working (with quota caveats)

---

## 1) Tooling Installed and Verified

### Core tools
- `maestro` (verified, version `2.3.0`)
- `axe` CLI (installed and working)
- `xcodebuild` (used for compile/install)
- `simctl` (status bar + install/launch)
- Python venv for screenshot skill: `.venv-aso`
- `Pillow` installed in `.venv-aso` and user Python

### Skills / repos
- ASO screenshot skill cloned to:
  - `~/.claude/skills/aso-appstore-screenshots`
- Note: `claude install-skill ...` command did not work in this environment; manual clone was used.

### Frames CLI
- Installed from:
  - `https://github.com/viticci/frames-cli`
- Local clone:
  - `/Users/swapnanildhol/Desktop/tools/frames-cli`
- Symlinked binary:
  - `~/.local/bin/frames`
- Verified:
  - `frames v1.2.7`

---

## 2) Critical Configurations

### Gemini MCP config
Updated in:
- `~/.cursor/mcp.json`

Server entry added:
- `"gemini": { "command": "/opt/homebrew/bin/gemini-mcp", "env": { "GEMINI_API_KEY": "..." } }`

Important:
- Quota and billing are per **Google project**, not just key.
- 429 errors seen until billing/key/project aligned.

### Frames assets path fix
Error encountered:
- `NewFrames.json not found ...`

Fix:
- point frames assets to folder containing `NewFrames.json`.
- final working path:
  - `~/.config/frames/FramesAssets/Frames`

Verification:
- `frames doctor` reports:
  - assets OK
  - version v4
  - frame PNGs present

---

## 3) Simulator and Build Workflow (Known Good)

Simulator used:
- `iPhone 17 Pro`
- UDID: `B364C1C5-49D3-49A9-9EE0-997F8BA95DC7`

### Build and install latest app
Used repeatedly:

1. Build:
- `xcodebuild -project "SubscriptionTracker.xcodeproj" -scheme "SubscriptionTracker" -destination "platform=iOS Simulator,id=B364C1C5-49D3-49A9-9EE0-997F8BA95DC7" build`

2. Resolve app path from build settings and install:
- `xcrun simctl install ... SubscriptionTracker.app`

3. Launch:
- `xcrun simctl launch ... com.SwapnanilDhol.SubscriptionTracker`

### Clean App Store status bar
Used:
- `xcrun simctl status_bar <UDID> override --time "9:41" --dataNetwork wifi --wifiBars 3 --cellularBars 4 --batteryState charged --batteryLevel 100`

---

## 4) Maestro Suite Refactor (Home-First)

Old suite was wiped and rebuilt minimal.

Key current files:
- `MaestroTests/flows/00_launch_home.yaml`
- `MaestroTests/flows/01_add_subscription.yaml`
- `MaestroTests/flows/02_view_subscription_detail.yaml`
- `MaestroTests/flows/03_open_settings.yaml`
- `MaestroTests/flows/11_seed_five_robust.yaml`
- `MaestroTests/smoke.yaml`

### Home-first launch flow (important)
`00_launch_home.yaml` uses:
- `clearState: true`
- `clearKeychain: true`
- launch arguments:
  - `isNotFirstTime: "true"`
  - `isProEnabled: "true"`
  - `TEST_SEED_FIXTURE: "subscriptions_seed"`
  - `TEST_FORCE_PRO: "true"`

Purpose:
- skip onboarding
- seed demo data
- try to force pro mode for screenshot demos

### Current behavior note
- Despite pro forcing, user still reported seeing `Upgrade` button in screenshots.
- This may indicate `isProEnabled` launch arg is not the effective key for all UI paths.

---

## 5) AXe Usage and Known UI Behavior

Used for:
- `axe describe-ui` to inspect failing states
- `axe screenshot` for deterministic captures

Observed issue during older 5-seed flows:
- after first save in add subscription flow, AX tree sometimes collapsed to app-only node.
- this made multi-add automation unreliable.

Then switched to demo/home-first orientation instead of strict 5-create flow.

---

## 6) Screenshot Generation Pipelines Used

### A) Deterministic scaffold (`compose.py`)
Script:
- `~/.claude/skills/aso-appstore-screenshots/compose.py`

Produces 1290x2796 framed marketing image with headline + phone comp.

Example output files generated:
- `screenshots/generated/demo_hero_scaffold.png`
- `screenshots/generated/demo_hero_scaffold_contrast_fix.png`
- `screenshots/generated/demo_hero_scaffold_clean_frame.png`
- `screenshots/generated/demo_home_seeded_clean_for_frames_scaffold.png`

### B) Gemini image edit pass
Tool used via MCP:
- `user-gemini` -> `edit_image`

Working outputs:
- `screenshots/generated/demo_hero_gemini_v1.png`
- `screenshots/generated/demo_hero_gemini_v2.png`
- `screenshots/generated/demo_hero_gemini_clean_frame_v1.png`

Failures seen:
- `429 RESOURCE_EXHAUSTED` (quota/billing mismatch)
- one `400 INVALID_ARGUMENT` when trying certain model/resolution combinations

### C) frames-cli official bezel framing
Command used successfully after setup:
- `frames --device "iPhone 17 Pro Portrait" --color "Black" <input.png>`

Example output:
- `screenshots/captured/demo_home_seeded_icons_fixed_framed.png`

---

## 7) UI Changes Made in Code

### File: `SubscriptionTracker/Modules/Home/View/SubscriptionItemView.swift`
Changes made across iterations:
- Increased card tint to full color for stronger contrast (`opacity 1.0` path)
- Progress bar tint fallback for dark mode to avoid invisible dark bars
- Removed icon “container” (background plate + border) per user request
- Removed broken `.buttonModifier` usage that caused build failure

Build error fixed:
- `value of type 'some View' has no member 'buttonModifier'`

### File: `SubscriptionTracker/Modules/Home/View/Header/SubscriptionHeaderView.swift`
Adjusted tab/page container visual chrome:
- `.indexViewStyle(.page(backgroundDisplayMode: .never))`
- `.background(Color.clear)`

Goal:
- reduce gray page indicator/background container look in header area.

### File: `MaestroTests/flows/00_launch_home.yaml`
Added/adjusted launch args for demo capture mode and pro forcing.

---

## 8) Latest Outputs to Review

Most relevant latest captures:
- `screenshots/captured/demo_home_seeded_clean_for_frames.png`
- `screenshots/captured/demo_home_seeded_icons_fixed.png`
- `screenshots/captured/demo_home_seeded_icons_fixed_framed.png`

Earlier comparison points:
- `screenshots/captured/demo_home_seeded_post_ui_fixes.png`
- `screenshots/captured/demo_home_seeded_full_tint.png`

---

## 9) Open Issues from User (Not Fully Resolved Yet)

1. `Notion Plus` color disliked
- Needs explicit remap/tuning of that category tint or icon asset.

2. `Upgrade` button still visible in screenshot state
- Even after screenshot launch args intended to force pro.
- Needs deeper check in `ProManager` state source and toolbar condition in `HomeView`.

3. Ensure icon contrast is “perfect” on final screenshots
- Icon container removed; may need per-icon treatment if certain logos still low contrast.

---

## 10) Fast Next-Step Plan (for next LLM)

1. Verify pro state source of truth:
- Check `ProManager` + persistence key used by `isProEnabled`.
- Ensure screenshot launch path writes the exact key before `HomeView` renders.
- Confirm with AX/screenshot that `upgradeButton` disappears.

2. Tune Notion card color:
- Locate category/icon color mapping (`SubscriptionProxy` / category palette model).
- Override Notion tint to stronger/darker/lower-luminance variant.

3. Capture final:
- Build/install latest
- apply clean status bar override
- run `MaestroTests/flows/00_launch_home.yaml`
- `axe screenshot ...`
- `frames ... --device "iPhone 17 Pro Portrait" --color "Black"`

4. Optional final polish:
- one Gemini edit only after visual sign-off to minimize credit burn.

---

## 11) Quick Command Cheat Sheet

Build:
- `xcodebuild -project "SubscriptionTracker.xcodeproj" -scheme "SubscriptionTracker" -destination "platform=iOS Simulator,id=B364C1C5-49D3-49A9-9EE0-997F8BA95DC7" build`

Status bar:
- `xcrun simctl status_bar B364C1C5-49D3-49A9-9EE0-997F8BA95DC7 override --time "9:41" --dataNetwork wifi --wifiBars 3 --cellularBars 4 --batteryState charged --batteryLevel 100`

Home demo launch flow:
- `maestro test "MaestroTests/flows/00_launch_home.yaml"`

AX screenshot:
- `axe screenshot --udid B364C1C5-49D3-49A9-9EE0-997F8BA95DC7 --output "screenshots/captured/<name>.png"`

frames doctor:
- `frames doctor`

Frame screenshot:
- `frames --device "iPhone 17 Pro Portrait" --color "Black" "screenshots/captured/<name>.png"`

---

## Checklist

Before marking a screenshot automation handoff as done:

- [ ] All tooling is installed and versions are documented (Maestro, frames-cli, axe CLI)
- [ ] Simulator UDID and model are recorded
- [ ] Build and install commands are copy-pasteable and tested
- [ ] Status bar override command is documented
- [ ] Maestro flows are committed and run from a clean state
- [ ] Screenshot output paths and naming conventions are defined
- [ ] Known UI issues (pro state, colors, contrast) are listed with next steps
- [ ] A fast next-step plan is written for the next engineer or LLM session

