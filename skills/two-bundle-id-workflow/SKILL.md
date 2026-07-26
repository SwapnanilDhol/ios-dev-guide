---
name: two-bundle-id-workflow
description: >-
  Generic two-bundle-ID workflow for keeping development installs and
  production installs isolated. Use when changing bundle identifiers, build
  configurations, app groups, entitlements, widgets/extensions, display names,
  app icons, or any feature that could accidentally mix development data with
  live app data.
---

# Two Bundle ID Workflow

Read `bootstrap/two-bundle-id.md` in this kit, then any host-app example under `examples/`.
For implementation work, also read [references/implementation-checklist.md](references/implementation-checklist.md) before editing files.

Use this skill whenever the task touches any of these:

- `PRODUCT_BUNDLE_IDENTIFIER`
- `.xcconfig` build configuration wiring
- app groups or entitlements
- widget or extension bundle IDs
- debug vs production display names or app icons
- environment-aware storage, backups, or shared containers

## Goal

Preserve the app's safety rule:

- Development work must never share the same app identity or shared container as the production install.

## Reference Mapping

| Aspect | Debug / Dev | Release / Prod |
|--------|-------------|----------------|
| App bundle ID | `com.example.app.dev` | `com.example.app` |
| Display name | `App Dev` | `App` |
| App group | `group.com.example.app.dev` | `group.com.example.app` |
| Backup directory | `data_dev` | `data` |
| Compile flag | `DEVELOPMENT` | none |

## Common Source Files

- `Debug.xcconfig` and `Release.xcconfig`
- app and extension entitlements
- app and extension target build settings
- `Info.plist` or per-configuration plist files
- a central runtime configuration type
- shared-container helpers
- widget or extension container helpers

## Invariants

1. Debug and release bundle IDs must stay different.
2. Debug and release app groups must stay different.
3. Extensions/widgets must follow the same split as the main app.
4. Environment-dependent app behavior should branch through `Configuration` and `#if DEVELOPMENT`.
5. User-visible naming should come from bundle-driven configuration, not hardcoded app names.
6. Any new shared storage or backup path must be checked for dev/prod isolation.

## Workflow

1. Identify every place app identity is defined: xcconfig, entitlements, Info.plist, project target settings, extension target settings, runtime config helpers, and any strings derived from bundle ID.
2. Read `references/implementation-checklist.md` and follow the file-by-file change list.
3. Make paired debug and release changes together. Never update only one side unless the task explicitly removes the split.
4. Confirm runtime helpers still return the correct app group, bundle-derived name, and storage paths.
5. If adding a new extension or shared container, wire both dev and prod variants before considering the task complete.
6. Update the local workflow documentation if the file layout or rules change.
7. Verify that the development and production installs remain isolated.

## Expected Edits

In a normal implementation, expect to inspect or change all of these:

- debug and release `PRODUCT_BUNDLE_IDENTIFIER`
- debug and release `CODE_SIGN_ENTITLEMENTS`
- debug and release `INFOPLIST_FILE`
- debug and release display-name wiring
- app-group arrays inside entitlements
- extension target bundle identifiers
- extension target entitlements
- Info.plist values that derive from the bundle identifier
- runtime configuration helpers for app group, backup path, suite name, URL base, or feature gating
- widget/shared-container helpers that infer environment from bundle identity

## Output Standard

When this skill is used for a real implementation, the resulting change should leave behind:

- a working debug identity
- a working production identity
- matching companion target identities, if they exist
- a single runtime configuration layer for environment-aware values
- updated documentation of the workflow

## Review Checklist

- Does the debug build still install side-by-side with production?
- Could any app-group, widget, or backup path accidentally point at production from debug?
- Did any user-facing string hardcode the app name instead of using bundle-driven naming?
- If the task added a new target or extension, did it get both debug and release identity wiring?
