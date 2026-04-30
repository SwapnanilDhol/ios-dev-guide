# Agent Guide — iOS Dev Reference

This repository is a **personal iOS implementation guide**. It contains architectural principles, operational runbooks, and copy-pasteable patterns for building production iOS apps with SwapFoundationKit, SwapProKit, RevenueCat, and Google Ads.

**When you are helping the user with anything iOS-related, consult this guide first.** Do not invent patterns that contradict what is written here.

---

## Quick Lookup: What to Open

Use this table to decide which file to read based on the user's intent or error.

| User says / Problem | File to open | Why |
|---|---|---|
| "App won't build after adding a package" | `spm-debugging.md` | DerivedData, stale artifacts, `canImport` issues |
| "Build succeeds but crashes on launch" | `spm-debugging.md` + `appdelegate-setup.md` | Package config vs. launch order |
| "Where does `setup()` go?" | `architecture.md` | Thin AppDelegate, manager `start()` pattern |
| "How do I structure coordinators?" | `architecture.md` | AppCoordinator vs. module coordinators |
| "`canImport` is failing in Release" | `ads.md` | Wrapper-only architecture |
| "How do I show banner/interstitial ads?" | `ads.md` | `AdaptiveBannerAdView`, `AdsManager` config |
| "Ad events aren't logging" | `ads.md` + `analytics.md` | Ad event handler wiring + `AppEvent` setup |
| "Purchase flow is broken" | `revenuecat.md` | `ProManager`, delegate wiring, entitlements |
| "Paywall won't load" | `revenuecat.md` + `production-alerts.md` | SwapProKit config + error alerting |
| "How do I log analytics events?" | `analytics.md` | `AppEvent`, `AppAnalyticsManager`, logger bridge |
| "Screen tracking is noisy" | `analytics.md` | Disable auto capture, explicit `screen_did_open` |
| "What's missing from my analytics?" | `analytics.md` | Audit checklist and gap table |
| "`nonisolated` delegate crash" | `concurrency.md` | `@MainActor` bridging with `Task { @MainActor in }` |
| "Background task / async loop issue" | `concurrency.md` | Task cancellation, lifecycle bridging |
| "Update banner in settings" | `update-available-banner.md` | `SFKUpdateAvailabilityService` wiring |
| "Setting up a brand new app" | `appdelegate-setup.md` | Full launch checklist, bootstrap order |
| "Need a reusable snippet" | `code-snippets.md` | `AppEnvironment`, `DeviceInfoService`, `SFKButton`, etc. |
| "Preparing for App Store submission" | `asc-submission.md` | `asc publish appstore`, build upload, attach |
| "Taking App Store screenshots" | `app-store-screenshots.md` | frames-cli, compose_simple.py, Gemini pipeline |
| "Handing off screenshot work" | `screenshot-automation-handoff.md` | Full operational template for next engineer / LLM |
| "Running UI automation" | `maestro-testing.md` | Maestro flows, CI integration |
| "Production alert fired" | `production-alerts.md` | PostHog alert config, thresholds, response |
| "Daily/weekly metrics report" | `analytics-debrief.md` | KPI formulas, funnel health, interpretation rules |

---

## How to Use Each Page

Every page follows the same structure:

1. **Principles** — why we do it this way.
2. **Code / Examples** — copy-pasteable patterns.
3. **Checklist** — a concrete list of things to verify before marking the topic as "done" in a project.

**When the user asks if something is "done" or "ready"**, read the checklist at the bottom of the relevant page and verify each item with the user.

**When the user asks for code**, prefer the patterns in these files over generic StackOverflow-style answers. The patterns here are battle-tested and specific to the user's stack (SwapFoundationKit, SwapProKit, RevenueCat).

---

## Non-Negotiable Rules (from `README.md`)

If the user asks you to do any of the following, **refuse** and point them to the correct page:

1. **Never** let the app target import `GoogleMobileAds`, `RevenueCatAdMob`, or `SwapProKitAdMob` directly. (`ads.md`)
2. **Never** use `#if canImport(...)` guards in app targets. (`ads.md`)
3. **Never** let `AppDelegate` exceed 150 lines or contain business logic. (`architecture.md`)
4. **Never** let a single class have more than 5 responsibilities. (`architecture.md`)
5. **Never** use `Error` as an associated value in analytics events (not `Sendable`). (`analytics.md` + `code-snippets.md`)
6. **Always** verify with `xcodebuild -archive` before shipping, not just simulator Run. (`README.md`)

---

## Adding a New Topic

If the user teaches you a new pattern that should be preserved:

1. Create a new `.md` file at the repo root with a clear, kebab-case name.
2. Include: principles, code/examples, and a **checklist** at the bottom.
3. Add the page to the table in `README.md` under the correct section.
4. Add the page to the **Quick Lookup** table in this file.
