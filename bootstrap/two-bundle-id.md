# Two Bundle ID Workflow

Use two bundle IDs when you want development installs and production installs to coexist without sharing data.

The standard pattern is:

- `Debug` builds install a development app.
- `Release` builds install a production app.
- Both builds come from the same target and codebase.

Because the bundle IDs differ, iOS treats them as separate apps with separate containers, separate app groups, separate widget containers, and separate backups.

## Why This Exists

This workflow protects production data from development work.

It is useful when you want all of the following:

- side-by-side installs on the same device
- isolated `UserDefaults`, files, Core Data stores, and app-group data
- development widgets and extensions that do not attach to production state
- a clear visual distinction between the development build and the live build

## Core Structure

The pattern usually looks like this:

```text
One app target
  Debug   -> development identity
  Release -> production identity

Optional companion targets
  Widget / extension / watch target
    Debug   -> development companion identity
    Release -> production companion identity
```

There is no need for a separate "Dev" target if build configurations already carry the identity split.

## Typical Mapping

| Aspect | Development build | Production build |
|--------|-------------------|------------------|
| App bundle ID | `com.example.app.dev` | `com.example.app` |
| Display name | `App Dev` | `App` |
| App icon | `AppIcon-Dev` | `AppIcon` |
| App group | `group.com.example.app.dev` | `group.com.example.app` |
| Backup directory | `data_dev` | `data` |
| Compile flag | `DEVELOPMENT` | none |

The exact values can differ, but the separation rule should not.

## Files That Usually Define The Workflow

Most projects place the split across these layers:

- `Debug.xcconfig` or similar
- `Release.xcconfig` or similar
- per-configuration `Info.plist` files, if needed
- per-configuration entitlements files
- target build settings in the Xcode project
- a small runtime configuration layer that exposes environment-aware identifiers

## Coverage Matrix

When implementing this pattern, do not stop at bundle IDs alone. A complete setup usually touches all of these:

| Layer | What to verify |
|------|-----------------|
| Build configuration | `PRODUCT_BUNDLE_IDENTIFIER`, display name, icon name, entitlements path, plist path, compile flags |
| Main app entitlements | app-group value for debug and release |
| Companion target entitlements | widget, extension, watch, or share-target app-group values |
| Info.plist | `CFBundleIdentifier`, `CFBundleDisplayName`, and any derived identifiers |
| Generated Info settings | `INFOPLIST_KEY_*` values set in the target build settings |
| Derived plist identifiers | background task identifiers, URL schemes, or any value that should follow the current bundle ID |
| Runtime configuration | app group, defaults suite name, backup path, feature flags, environment checks |
| Shared storage helpers | app-group container access, widget sync, import/export, file storage |

If any one of these is left behind, the workflow can look correct while still leaking development state into production.

## Invariants

When maintaining this workflow, preserve these rules:

1. Debug and release must always use different `PRODUCT_BUNDLE_IDENTIFIER` values.
2. App-group identifiers must also be different across debug and release.
3. Any widget, extension, watch app, or companion target must follow the same split.
4. Shared storage and backup paths must stay environment-specific.
5. User-visible naming should come from bundle-driven configuration, not hardcoded strings.
6. Environment-aware branching should live in one configuration layer, not be scattered across the UI.

## Compile-Time Branching Pattern

The usual setup is to let the debug configuration define a compile flag:

```xcconfig
SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEVELOPMENT
```

Then expose environment-aware values from one runtime configuration type:

```swift
enum AppConfiguration {
    static var isDevelopment: Bool {
        #if DEVELOPMENT
        return true
        #else
        return false
        #endif
    }

    static var appGroupIdentifier: String {
        #if DEVELOPMENT
        return "group.com.example.app.dev"
        #else
        return "group.com.example.app"
        #endif
    }

    static var backupDirectoryName: String {
        #if DEVELOPMENT
        return "data_dev"
        #else
        return "data"
        #endif
    }
}
```

This keeps the behavior deterministic and aligned with the build that produced the binary.

## What To Check When Extending The Pattern

If you add a feature that depends on app identity or shared storage, verify all of these:

1. debug and release xcconfig values
2. app entitlements and extension entitlements
3. bundle-driven display name and icon wiring
4. shared-container helpers
5. backup/import/export locations
6. any extension or widget target that must stay paired with the matching app build

Examples:

- New widget: add separate debug and release bundle IDs plus matching entitlements.
- New shared storage: use the current app-group identifier, never a hardcoded production group.
- New environment-specific behavior: expose it from the configuration layer instead of branching ad hoc in views.

## Plist And Derived Identifier Notes

`Info.plist` is often where incomplete implementations slip through.

Things to watch for:

- `CFBundleIdentifier` should usually point to `$(PRODUCT_BUNDLE_IDENTIFIER)` rather than a hardcoded string.
- `CFBundleDisplayName` should usually come from a build setting or per-configuration plist value.
- background task identifiers should usually be derived from `$(PRODUCT_BUNDLE_IDENTIFIER)` so debug and production do not share task names.
- custom URL schemes and other identity-sensitive keys should be reviewed to decide whether they should be shared or split.

Example:

```xml
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>

<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER).refresh</string>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER).sync</string>
</array>
```

This pattern keeps the plist aligned with the active build configuration instead of forcing a second round of manual updates.

## Rollout Checklist

1. Create separate debug and release identity values.
2. Give the development build a distinct display name and icon.
3. Split app groups and entitlements the same way as bundle IDs.
4. Make companion targets follow the same split.
5. Route environment-aware values through one configuration type.
6. Verify that development and production can both be installed at once.

## Key Principle

> Different bundle IDs mean different app containers. That container split is what prevents development work from contaminating production data.
