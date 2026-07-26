# CLAUDE.md — iOS Dev Guide

Short twin of `AGENTS.md` for Claude / Cursor agents. Prefer the linked page checklists for depth.

## Stack

SwapFoundationKit-first iOS apps: SwiftUI, MVVM-C, SwapProKit, RevenueCat, RTK builds, optional two-bundle-ID Dev/Prod split.

## Refactoring

- **One declaration per file** (struct / enum / protocol / class). Filename matches the type.
- **Enums drive UI state** (modes, steps, permissions) via computed properties — not inline ternaries in `body`.
- **Minimal abstraction** — concrete providers; test subclasses instead of `*Providing` protocols.
- Prefer `switch` over `if`/`else if` chains, especially for type-casting existentials.

## Architecture

- MVVM-C in feature modules. Coordinators own sheets, modals, alerts (`AlertPresenter` — no SwiftUI `.alert`).
- Views are lightweight; ViewModels own logic; typed delegate inits for navigation callbacks.
- Preview factories: `*PreviewSupport` enums — never parameterless VM inits that fabricate coordinators.
- See `architecture/architecture.md`, `architecture/cta-and-footers.md`, `architecture/settings.md`.

## Localization

- SwiftUI string literals: implicit localization — **no** `.localized`.
- `.localized` only for plain `String` APIs (`SFKButton`, UIKit, settings trailing strings).
- See `architecture/localization.md`.

## Testing

- Prefer Swift Testing (`@Testing`, `#expect`) for new tests.
- Descriptive names: `test<Foo>_<behavior>`.

## SFK-first

Check `SwapFoundationKit/Docs/capabilities.yaml` → `use_sfk_directly` / `wrap_sfk` / `keep_custom`. See `stack/sfk-first.md`.

## Build gate

```bash
rtk xcodebuild -scheme <Scheme> -destination 'platform=iOS Simulator,name=<Simulator>' -quiet build
```

Treat exit code as source of truth. Code is not done until it compiles. Prefer archive verification before shipping.

## New app

Start at `bootstrap/new-app-checklist.md`. For onboarding, use `product/onboarding.md` + `skills/premium-onboarding`.
