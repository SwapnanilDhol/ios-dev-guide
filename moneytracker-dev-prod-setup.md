# MoneyTracker Dev/Prod Build Setup

This document describes how MoneyTracker supports two side-by-side app installs — one for development/testing and one for production — using a single Xcode target with two build configurations.

---

## How It Works

| Aspect | Development (Debug) | Production (Release) |
|--------|---------------------|----------------------|
| **Bundle ID** | `com.swapnanildhol.MoneyTracker.dev` | `com.swapnanildhol.MoneyTracker` |
| **Display Name** | Windfall Dev | Windfall |
| **App Icon** | `AppIcon-Dev` | `AppIcon` |
| **App Group** | `group.com.swapnanildhol.MoneyTracker.dev` | `group.com.swapnanildhol.MoneyTracker` |
| **Data Store** | Isolated in dev container | Isolated in prod container |
| **Backups** | Stored in `data_dev/` | Stored in `data/` |

Because the bundle IDs are different, iOS treats them as completely separate apps. You can have **both on your home screen at the same time** with fully isolated Core Data, UserDefaults, and backups.

### In Practice

- **Hitting Run in Xcode** → builds **Debug** config → installs **"Windfall Dev"**
- **Archiving for TestFlight/App Store** → builds **Release** config → installs **"Windfall"**

---

## Architecture

```
Targets:
  └── MoneyTracker                    (single app target)
        Debug   → DebugConfig.xcconfig   → dev bundle ID
        Release → ReleaseConfig.xcconfig → prod bundle ID

Schemes:
  ├── MoneyTracker            (shared)
  └── MoneyTrackerWidgetExtension
```

There is no separate `MoneyTrackerDev` target. The two builds are produced from the same target using different build configurations.

---

## Configuration Files

| File | Purpose |
|------|---------|
| `MoneyTracker/Configuration/DebugConfig.xcconfig` | Dev build settings: dev bundle ID, dev entitlements, dev icon, `DEVELOPMENT` compiler flag |
| `MoneyTracker/Configuration/ReleaseConfig.xcconfig` | Prod build settings: prod bundle ID, prod entitlements, prod icon |
| `MoneyTracker/Configuration/Info/Info-Dev.plist` | Dev Info.plist (minimal, relies on generated keys for standard bundle values) |
| `MoneyTracker/Configuration/Info/Info.plist` | Prod Info.plist (full, explicit bundle keys) |
| `MoneyTracker/Configuration/Entitlements/MoneyTrackerDev.entitlements` | Dev app group |
| `MoneyTracker/Configuration/Entitlements/MoneyTracker.entitlements` | Prod app group |
| `MoneyTracker/Configuration/Entitlements/MoneyTrackerDevWidgetExtension.entitlements` | Dev widget app group |
| `MoneyTracker/Configuration/Entitlements/MoneyTrackerWidgetExtension.entitlements` | Prod widget app group |

---

## Runtime Configuration (`Configuration.swift`)

All runtime branching between dev and prod is done with compile-time `#if DEVELOPMENT` checks:

```swift
enum Configuration {
    static var isDevelopment: Bool {
        #if DEVELOPMENT
        return true
        #else
        return false
        #endif
    }

    static var appGroupIdentifier: String {
        #if DEVELOPMENT
        return "group.com.swapnanildhol.MoneyTracker.dev"
        #else
        return "group.com.swapnanildhol.MoneyTracker"
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

This is zero-cost at runtime and guaranteed to match the actual build because `DebugConfig.xcconfig` sets `SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEVELOPMENT`.

---

## Service Keys

Third-party service keys (TelemetryDeck, RevenueCat) are stored as constants in `Configuration.swift`, not in `Info.plist` or `.xcconfig`. This avoids unnecessary plist indirection since the values are the same across both builds and only consumed by your own code.

```swift
static let telemetryDeckAppID = "8B3139C3-0FB7-4E18-A62A-54A3010CF6A4"
static let revenueCatAppID = "appl_kadAwoaFtHcKmErhQDrVsjgiAtT"
```

### Different Keys for Dev vs Prod

If you ever need different keys for each build, use the same `#if DEVELOPMENT` pattern:

```swift
static let revenueCatAppID: String = {
    #if DEVELOPMENT
    return "appl_dev_sandbox_key_here"
    #else
    return "appl_kadAwoaFtHcKmErhQDrVsjgiAtT"
    #endif
}()
```

This keeps the branching compile-time safe and consistent with the rest of `Configuration.swift`.

---

## Per-Build Configuration Details

| Setting | Debug (Dev) | Release (Prod) |
|---------|-------------|----------------|
| `SWIFT_ACTIVE_COMPILATION_CONDITIONS` | `DEVELOPMENT` | *(empty)* |
| `PRODUCT_BUNDLE_IDENTIFIER` | `com.swapnanildhol.MoneyTracker.dev` | `com.swapnanildhol.MoneyTracker` |
| `PRODUCT_NAME` | `MoneyTrackerDev` | `MoneyTracker` |
| `DISPLAY_NAME` | `Windfall Dev` | `Windfall` |
| `INFOPLIST_FILE` | `MoneyTracker/Configuration/Info/Info-Dev.plist` | `MoneyTracker/Configuration/Info/Info.plist` |
| `CODE_SIGN_ENTITLEMENTS` | `MoneyTracker/Configuration/Entitlements/MoneyTrackerDev.entitlements` | `MoneyTracker/Configuration/Entitlements/MoneyTracker.entitlements` |
| `ASSETCATALOG_COMPILER_APPICON_NAME` | `AppIcon-Dev` | `AppIcon` |
| `APP_GROUP_IDENTIFIER` | `group.com.swapnanildhol.MoneyTracker.dev` | `group.com.swapnanildhol.MoneyTracker` |

---

## Building from Command Line

```bash
# Development build
xcodebuild -scheme MoneyTracker -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17'

# Production build
xcodebuild -scheme MoneyTracker -configuration Release -destination 'platform=iOS Simulator,name=iPhone 17'
```

---

## Adding This Setup to a New Project

If you're setting this up from scratch in a new project:

- [ ] Create two `.xcconfig` files (Debug and Release)
- [ ] Set `PRODUCT_BUNDLE_IDENTIFIER` to different values in each
- [ ] Set `SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEVELOPMENT` in the Debug config
- [ ] Create two `.entitlements` files with different app group IDs
- [ ] Point `CODE_SIGN_ENTITLEMENTS` to the correct one per config
- [ ] Use `#if DEVELOPMENT` in code to branch behavior
- [ ] Ensure `PRODUCT_NAME` differs so both apps can coexist

> **Key principle:** different bundle IDs = different apps = fully isolated data.
