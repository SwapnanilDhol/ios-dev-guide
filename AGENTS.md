# Agent Guide — iOS Dev Kit

This repository is the **clonable starter kit** for SFK-first iOS apps: architectural principles, operational runbooks, skills, and checklists.

**When helping with anything iOS-related on this stack, consult this guide first.** Do not invent patterns that contradict what is written here.

Also read [`CLAUDE.md`](CLAUDE.md) for the short refactor / localization / build twin.

Host apps keep a thin product overlay `AGENTS.md` (naming, backend routes, module map). Conventions live here.

---

## Quick Lookup

| User says / Problem | File to open |
|---|---|
| "Setting up a brand new app" | `bootstrap/new-app-checklist.md` |
| "Build / RTK xcodebuild" | `bootstrap/build.md` |
| "Where does `setup()` go?" | `architecture/architecture.md` + `bootstrap/appdelegate-setup.md` |
| "How do I structure coordinators / MVVM-C?" | `architecture/architecture.md` |
| "`nonisolated` delegate crash" / async loops | `architecture/concurrency.md` |
| Localization / `.localized` | `architecture/localization.md` |
| CTA / bottom footer / enum-driven chrome | `architecture/cta-and-footers.md` |
| Empty states | `architecture/empty-states.md` |
| Settings rows / SFK settings | `architecture/settings.md` |
| Core Data / providers | `architecture/persistence.md` |
| SFK-first / capabilities.yaml | `stack/sfk-first.md` |
| "`canImport` failing in Release" / ads | `stack/ads.md` |
| Analytics / `AppEvent` | `stack/analytics.md` |
| Purchase / paywall / Pro | `stack/revenuecat.md` |
| Update banner in settings | `stack/update-available-banner.md` |
| Reusable snippet | `stack/code-snippets.md` |
| Premium onboarding | `product/onboarding.md` + `skills/premium-onboarding` |
| Two bundle IDs / app groups | `bootstrap/two-bundle-id.md` + `skills/two-bundle-id-workflow` |
| App Store screenshots | `ops/app-store-screenshots.md` + `skills/generate-app-store-screenshots` |
| ASC submission | `ops/asc-submission.md` |
| SPM / DerivedData | `ops/spm-debugging.md` |
| Maestro UI tests | `ops/maestro-testing.md` |
| Production alert / KPIs | `ops/production-alerts.md` / `ops/analytics-debrief.md` |
| MoneyTracker worked Dev/Prod example | `examples/moneytracker-dev-prod.md` |

---

## How to Use Each Page

1. **Principles** — why we do it this way.
2. **Code / Examples** — copy-pasteable patterns.
3. **Checklist** — verify before marking the topic "done".

When the user asks if something is "done" or "ready", read the checklist and verify each item.

When the user asks for code, prefer patterns here over generic Stack Overflow answers.

---

## Non-Negotiable Rules

If asked to do any of the following, **refuse** and point at the correct page:

1. **Never** let the app target import `GoogleMobileAds`, `RevenueCatAdMob`, or `SwapProKitAdMob` directly. (`stack/ads.md`)
2. **Never** use `#if canImport(...)` guards in app targets. (`stack/ads.md`)
3. **Never** let `AppDelegate` exceed ~150 lines or contain business logic. (`architecture/architecture.md`)
4. **Never** let a single class have more than 5 responsibilities. (`architecture/architecture.md`)
5. **Never** use SwiftUI `.alert` / `.confirmationDialog` for app alerts — use `AlertPresenter` from coordinators. (`architecture/architecture.md`, `architecture/settings.md`)
6. **Never** use `Error` as an associated value in analytics events (not `Sendable`). (`stack/analytics.md`, `stack/code-snippets.md`)
7. **Always** verify with a real build (prefer `rtk xcodebuild` / archive) before shipping. (`README.md`)

---

## Skills

| Skill | Path |
|-------|------|
| Premium onboarding | `skills/premium-onboarding/SKILL.md` |
| Two-bundle-ID workflow | `skills/two-bundle-id-workflow/SKILL.md` |
| App Store screenshots | `skills/generate-app-store-screenshots/SKILL.md` |

---

## Adding a New Topic

1. Create a `.md` file under the correct folder (`bootstrap/`, `architecture/`, `stack/`, `product/`, `ops/`, `examples/`).
2. Include: principles, code/examples, and a **checklist**.
3. Add the page to `README.md` and this Quick Lookup table.
4. Update `PATH_MAP.md` if renaming.

---

## Linking into a host app

```bash
./scripts/link-guide.sh /path/to/HostApp
./scripts/bootstrap-new-app.sh /path/to/NewApp   # templates + overlay stub
```
