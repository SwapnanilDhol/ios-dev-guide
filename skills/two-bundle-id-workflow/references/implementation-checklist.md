# Implementation Checklist

Use this checklist when creating or auditing a two-bundle-ID workflow.

## 1. Build Configurations

Confirm there are at least two build configurations:

- `Debug`
- `Release`

Typical requirements:

- `Debug` defines a development identity
- `Release` defines a production identity
- both configurations map to the same app target unless the project intentionally uses separate targets

## 2. xcconfig Or Target Build Settings

Check each configuration for these settings:

| Setting | Development example | Production example | Why it matters |
|--------|----------------------|--------------------|----------------|
| `PRODUCT_BUNDLE_IDENTIFIER` | `com.example.app.dev` | `com.example.app` | Defines app identity and container split |
| `DISPLAY_NAME` or `INFOPLIST_KEY_CFBundleDisplayName` | `App Dev` | `App` | Makes the install visually distinct |
| `ASSETCATALOG_COMPILER_APPICON_NAME` | `AppIcon-Dev` | `AppIcon` | Prevents confusion on-device |
| `CODE_SIGN_ENTITLEMENTS` | `AppDev.entitlements` | `App.entitlements` | Points each build at the correct app-group file |
| `INFOPLIST_FILE` | `Info-Dev.plist` or shared plist | `Info.plist` or shared plist | Keeps identity-sensitive plist values aligned |
| `SWIFT_ACTIVE_COMPILATION_CONDITIONS` | `DEVELOPMENT` | empty or production defaults | Drives compile-time branching |

If there are extension targets, also check their per-configuration:

- `PRODUCT_BUNDLE_IDENTIFIER`
- `CODE_SIGN_ENTITLEMENTS`
- `INFOPLIST_FILE`
- `INFOPLIST_KEY_CFBundleDisplayName`, if set in build settings

## 3. Entitlements

Every target that participates in shared storage must have matched debug and release entitlements.

Typical app-group split:

```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.example.app.dev</string>
</array>
```

and

```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.example.app</string>
</array>
```

Check:

- main app entitlements
- widget entitlements
- share extension entitlements
- watch app / watch extension entitlements

The most common mistake is updating the main app but forgetting the companion target.

## 4. Info.plist And Generated Info Settings

Check whether the app uses:

- explicit plist keys inside `Info.plist`
- generated plist values from target build settings
- or a mix of both

Identity-sensitive keys to inspect:

- `CFBundleIdentifier`
- `CFBundleDisplayName`
- `CFBundleName`
- `BGTaskSchedulerPermittedIdentifiers`
- URL types or custom schemes
- extension point identifiers and NSExtension metadata where applicable

Important pattern:

If a plist key should vary by build, prefer referencing a build setting instead of hardcoding.

Example:

```xml
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
```

Example of a derived identifier that should stay dynamic:

```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER).refresh</string>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER).sync</string>
</array>
```

That way the debug app and production app automatically get different task identifiers.

## 5. Companion Targets

If the app has widgets, extensions, or watch targets, treat them as part of the workflow.

Check all of these for each companion target:

- bundle identifier split
- entitlements split
- display-name expectations
- shared-container alignment with the matching app build

Recommended shape:

- app debug -> extension debug
- app release -> extension release

Never point a debug extension at a production app group.

## 6. Runtime Configuration Layer

Add or verify a single runtime configuration type that exposes environment-aware values such as:

- `isDevelopment`
- `appGroupIdentifier`
- `userDefaultsSuiteName`
- `backupDirectoryName`
- `baseURL`, if environments differ
- feature flags that should only exist in development

Preferred pattern:

```swift
enum AppConfiguration {
    static var isDevelopment: Bool {
        #if DEVELOPMENT
        return true
        #else
        return false
        #endif
    }
}
```

Do not scatter app-group strings, backup directory names, or environment checks across random files.

## 7. Bundle-Derived User-Facing Naming

If the development install should present itself as `App Dev`, the UI should usually read the bundle-driven display name rather than hardcode the app name.

Check places like:

- share text
- settings/about copy
- onboarding
- notifications
- widget titles or configuration strings

## 8. Shared Storage And Data Isolation

Search for:

- `UserDefaults(suiteName:)`
- app-group identifiers
- backup folder names
- file paths in app-group containers
- widget sync helpers
- extension sync helpers

Confirm all of them use the environment-aware identifier rather than a hardcoded production value.

## 9. Audit Queries

Useful search terms when applying this workflow:

- `PRODUCT_BUNDLE_IDENTIFIER`
- `CODE_SIGN_ENTITLEMENTS`
- `INFOPLIST_FILE`
- `CFBundleDisplayName`
- `CFBundleIdentifier`
- `BGTaskSchedulerPermittedIdentifiers`
- `UserDefaults(suiteName:`
- `application-groups`
- `group.`
- `widget`
- `extension`
- `SWIFT_ACTIVE_COMPILATION_CONDITIONS`

## 10. Completion Criteria

The workflow is not complete until all of these are true:

1. Debug and release have different app bundle IDs.
2. Debug and release have different app groups.
3. Companion targets follow the same split.
4. plist-derived identifiers are dynamic where needed.
5. Runtime helpers return environment-correct values.
6. User-facing naming does not accidentally hide the distinction between development and production.
7. Documentation explains the workflow so future edits do not collapse the split.
