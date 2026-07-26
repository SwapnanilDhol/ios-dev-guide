# iOS Dev Guide

**One-stop clonable starter kit** for production iOS apps on the SwapFoundationKit / SwapProKit / RevenueCat stack.

Clone this repo next to a new Xcode project, run the bootstrap script, and walk [`bootstrap/new-app-checklist.md`](bootstrap/new-app-checklist.md). Product-specific docs live in the app; conventions stay upstream here.

GitHub: https://github.com/SwapnanilDhol/ios-dev-guide

---

## Philosophy

This guide captures **architectural principles** and **checklists**, not one-off tutorials. Principles transfer across projects; procedures become stale.

Three rules:

1. **App targets never import third-party SDKs directly** — always through SwapFoundationKit wrappers
2. **One class, one responsibility** — if a class has more than 5 responsibilities, split it
3. **Explicit over implicit** — every event name, every key, every method call is intentional

Every page ends with a **checklist** of things to verify before marking that topic done in a new project.

---

## Start a new app

```bash
git clone https://github.com/SwapnanilDhol/ios-dev-guide.git ~/Desktop/iOS-Projects/ios-dev-guide
cd ~/Desktop/iOS-Projects/ios-dev-guide
./scripts/bootstrap-new-app.sh /path/to/NewApp
```

Or link agent entrypoints into an existing project:

```bash
./scripts/link-guide.sh /path/to/ExistingApp
```

Then open [`bootstrap/new-app-checklist.md`](bootstrap/new-app-checklist.md).

---

## Pages

### Bootstrap

| Page | What it covers |
|------|----------------|
| [New App Checklist](bootstrap/new-app-checklist.md) | Day-0 path for a brand-new app |
| [AppDelegate Setup](bootstrap/appdelegate-setup.md) | Launch order, packages, verification |
| [Two Bundle ID](bootstrap/two-bundle-id.md) | Dev vs Prod identity isolation |
| [Build Gate (RTK)](bootstrap/build.md) | Quiet `xcodebuild`, completion rule |

### Architecture

| Page | What it covers |
|------|----------------|
| [Architecture](architecture/architecture.md) | MVVM-C, thin AppDelegate, coordinators |
| [Concurrency](architecture/concurrency.md) | `@MainActor`, Task cancellation |
| [Localization](architecture/localization.md) | SwiftUI implicit vs `.localized` |
| [CTAs & Footers](architecture/cta-and-footers.md) | `SFKButton`, bottom bars, enum chrome |
| [Empty States](architecture/empty-states.md) | `SFKEmptyStateView` vs `ContentUnavailableView` |
| [Settings](architecture/settings.md) | Host-app SFK settings checklist |
| [Persistence](architecture/persistence.md) | Provider vs Service vs Core Data |

### Stack

| Page | What it covers |
|------|----------------|
| [SFK-First](stack/sfk-first.md) | `use_sfk` / `wrap_sfk` / `keep_custom` |
| [Ads](stack/ads.md) | Wrapper-only AdsManager |
| [Analytics](stack/analytics.md) | `AppEvent`, logger bridge |
| [RevenueCat](stack/revenuecat.md) | ProManager, entitlements |
| [Update Banner](stack/update-available-banner.md) | Settings update strip |
| [Code Snippets](stack/code-snippets.md) | Copy-pasteable helpers |

### Product

| Page | What it covers |
|------|----------------|
| [Premium Onboarding](product/onboarding.md) | Full playbook (Windfall as reference appendix) |

### Operations

| Page | What it covers |
|------|----------------|
| [App Store Screenshots](ops/app-store-screenshots.md) | Screenshot pipeline |
| [ASC Submission](ops/asc-submission.md) | ASC CLI publish flow |
| [Maestro Testing](ops/maestro-testing.md) | UI automation |
| [SPM Debugging](ops/spm-debugging.md) | DerivedData / `canImport` |
| [Production Alerts](ops/production-alerts.md) | PostHog alerts |
| [Analytics Debrief](ops/analytics-debrief.md) | KPI report format |
| [Screenshot Handoff](ops/screenshot-automation-handoff.md) | Ops handoff template |

### Skills

| Skill | Use when |
|-------|----------|
| [`skills/premium-onboarding`](skills/premium-onboarding/SKILL.md) | Implementing first-run onboarding |
| [`skills/two-bundle-id-workflow`](skills/two-bundle-id-workflow/SKILL.md) | Touching bundle IDs / app groups |
| [`skills/generate-app-store-screenshots`](skills/generate-app-store-screenshots/SKILL.md) | Capturing / composing ASC screenshots |

### Examples (optional)

| Page | What it covers |
|------|----------------|
| [MoneyTracker Dev/Prod](examples/moneytracker-dev-prod.md) | Worked two-bundle example |

Path rename map: [`PATH_MAP.md`](PATH_MAP.md).

---

## Golden Rules

### 1. Wrapper-Only for External SDKs

Never import `GoogleMobileAds`, `RevenueCatAdMob`, or `SwapProKitAdMob` in the app target. Use SwapFoundationKit wrappers. `canImport()` in app targets fails silently in Release — let SFK own conditional compilation. See [`stack/ads.md`](stack/ads.md).

### 2. Thin AppDelegate

AppDelegate orchestrates managers. It owns no logic. See [`architecture/architecture.md`](architecture/architecture.md).

### 3. `@MainActor` + `nonisolated` for Delegates

Bridge nonisolated delegate callbacks with `Task { @MainActor in }`. See [`architecture/concurrency.md`](architecture/concurrency.md).

### 4. `AppEvent` as Single Source of Truth

All analytics events live in one enum. Never log directly to Firebase from views. See [`stack/analytics.md`](stack/analytics.md).

### 5. Build Verification in Archive, Not Just Run

Test Release with `xcodebuild -archive` before shipping. Prefer:

```bash
rtk xcodebuild -scheme <Scheme> -destination 'platform=iOS Simulator,name=<Simulator>' -quiet build
```

Treat exit code as source of truth.

---

## Agent entrypoints

- [`AGENTS.md`](AGENTS.md) — quick lookup + non-negotiable rules
- [`CLAUDE.md`](CLAUDE.md) — short twin for Claude / Cursor

Host apps should keep a thin **product overlay** `AGENTS.md` (see `templates/AGENTS.product-overlay.template.md`) that points here and lists only product deltas.
