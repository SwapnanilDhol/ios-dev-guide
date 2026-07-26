# AGENTS.md — product overlay

Shared conventions live in the iOS Dev Guide:

`{{IOS_DEV_GUIDE_PATH}}`

Read that kit's `AGENTS.md`, `CLAUDE.md`, and topic pages first. This file lists **product deltas only**.

## Product vs target naming

- **Display name** — user-facing (`DISPLAY_NAME` / App Store). Use bundle display name in UI copy.
- **Target / module** — Xcode target, module, repo folder, bundle ID stem.

## Backend / monetization deltas

<!-- Example: every Workers request must send X-App-User-ID via AppUserID.headerValue -->

## Module documentation

See `Docs/architecture.md` and `Docs/modules/`. Update module docs when refactoring a feature.

## Build

```bash
rtk xcodebuild -scheme <Scheme> -destination 'platform=iOS Simulator,name=<Simulator>' -quiet build
```

Treat exit code as source of truth. Do not mark tasks complete until the app compiles.
