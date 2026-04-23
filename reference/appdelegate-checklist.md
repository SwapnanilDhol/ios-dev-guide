# AppDelegate Launch Checklist

Use this checklist when setting up a new iOS app or auditing an existing one.

## Project Structure

- [ ] `Delegates/` directory created
- [ ] AppDelegate is ≤150 lines — slim to orchestrator pattern from day 1
- [ ] Separate coordinator classes for distinct responsibilities
- [ ] No single class has more than 5 responsibilities

## App Group (if using widgets/watch)

- [ ] App Group created in Xcode (**Signing & Capabilities** → **App Groups**)
- [ ] App Group ID pattern: `bundleID.appGroup`
- [ ] App Group suite name stored in `AppConstants.AppGroup.suiteName`
- [ ] `AppConstants.swift` in `PBXFileSystemSynchronizedBuildFileExceptionSet` for all sync-enabled targets
- [ ] Test: `UserDefaults(suiteName: AppConstants.AppGroup.suiteName)` returns non-nil

## Dependencies (via SPM)

- [ ] SwapFoundationKit added (AdsManager, Analytics, CoreDataManager, etc.)
- [ ] SwapProKit added (remote SPM)
- [ ] RevenueCat added
- [ ] GoogleMobileAds added
- [ ] Firebase added
- [ ] TelemetryDeck added

## RevenueCat + SwapProKit

- [ ] `SwapProConfiguration` created with correct `entitlement` name (matches App Store Connect)
- [ ] `SwapProManager.shared.delegate` set before calling `start()`
- [ ] `AppConstants.ServiceKeys.revenueCatAppID` set
- [ ] `UserDefaultsKey.isProEnabled` matches `userDefaultsKey` in config
- [ ] All `SwapProDelegate` methods wired (purchase, restore, error)

## Launch Bootstrap Order

```swift
private func setup() {
    // 1. Lifecycle
    AppLifecycleHandler.shared.start()

    // 2. Analytics infrastructure
    FirebaseApp.configure()           // direct, no abstraction
    AppAnalyticsManager.shared.start()

    // 3. Core business
    ProManager.shared.start()

    // 4. Ads
    setupAds()

    // 5. Notifications
    NotificationManager.shared.start(delegate: self)

    // 6. UI appearance
    AppAppearanceManager.shared.start()

    // 7. App Group sync (after data is available)
    Task { @MainActor in
        let items = try? await CoreDataManager.shared.allItems()
        await SyncManager.initialSync(items: items ?? [])
    }
}
```

## iOS Version Considerations

- [ ] Remove `#available(iOS X, *)` guards for iOS 18+ minimum target
- [ ] Guard `tabBarMinimizeBehavior` with `#available(iOS 26.0, *)`
- [ ] Use `containerBackground(Color.clear, for: .widget)` for widget backgrounds

## Concurrency

- [ ] `@MainActor` on delegate classes where appropriate
- [ ] `nonisolated` + `Task { @MainActor in }` for all delegate callbacks
- [ ] `Task.isCancelled` checked in async loops
- [ ] `.debounce` on notification observers in ViewModels

## Build Verification

- [ ] Build succeeds with no errors
- [ ] Archive build succeeds (not just simulator Run)
- [ ] App launches on simulator and shows home screen
- [ ] Pro purchase/restore flow works (test in sandbox)
- [ ] Ads display for non-pro users
- [ ] Deep links open correct screen
