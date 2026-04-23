# Concurrency Patterns

## @MainActor Classes

If an entire class is main-actor isolated (like `ProManager`, `AdsCoordinator`, `AppCoordinator`), mark it `@MainActor` and mark all methods accordingly. This avoids needing `Task { @MainActor in }` inside every method.

```swift
@MainActor
final class ProManager {
    private let hapticsHelper = HapticsHelper()

    func setup() { ... }
}
```

---

## nonisolated + Task Propagation for Delegate Callbacks

When a class conforms to a delegate protocol with nonisolated requirements (like `SwapProDelegate` or `PurchasesDelegate`), the delegate methods are called on *any* thread. Since your class is `@MainActor`, bridge back explicitly:

```swift
@MainActor
final class ProManager: SwapProDelegate {

    nonisolated func purchaseDidComplete(
        package: RevenueCat.Package,
        customerInfo: RevenueCat.CustomerInfo,
        reason: String?
    ) {
        Task { @MainActor in
            updateProEnabled(from: customerInfo)
            AppAnalyticsManager.shared.logEvent(event: .purchaseCompleted(reason: reason ?? "NA"))
            hapticsHelper.successNotification()
            UIApplication.topViewController()?.dismiss(animated: true)
        }
    }

    nonisolated func purchaseDidFail(
        package: RevenueCat.Package,
        error: Error?,
        userCancelled: Bool
    ) {
        Task { @MainActor in
            syncAppGroupProStatus()

            guard !userCancelled else {
                AppAnalyticsManager.shared.logEvent(event: .purchaseFailed(reason: "User Cancelled"))
                _ = await AdsManager.shared.presentInterstitial()
                return
            }

            hapticsHelper.errorNotification()
            AppAnalyticsManager.shared.logEvent(event: .purchaseFailed(reason: reason))
        }
    }

    nonisolated func didThrowError(error: Error) {
        Task { @MainActor in
            AppAnalyticsManager.shared.logEvent(
                event: .proScreenLoadFailed(
                    errorCategory: (error as? SwapProError)?.analyticsCategory ?? "unknown",
                    errorMessage: error.localizedDescription
                )
            )
        }
    }
}
```

**Rule**: Never call main-actor-isolated code directly from a `nonisolated` context. Always use `Task { @MainActor in }`.

---

## nonisolated for Lifecycle Methods

For `UIApplicationDelegate` methods like `applicationWillTerminate` and `applicationDidEnterBackground`, mark the handler method `nonisolated` and propagate:

```swift
nonisolated func handleWillTerminate(_ application: UIApplication) {
    Task { @MainActor in
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
}

nonisolated func handleDidEnterBackground(_ application: UIApplication) {
    Task { @MainActor in
        backupService.performBackup()
    }
}
```

**Rule**: Never run expensive work in `handleWillTerminate` — iOS may kill the app at any point after backgrounding. Use `handleDidEnterBackground` for backup and state preservation.

---

## Task Cancellation in Async Loops

When using `Task` in async loops, always check `Task.isCancelled`:

```swift
func timeline(for configuration: WidgetConfiguration, in context: Context) async -> Timeline<Entry> {
    return makeTimeline { item in
        if Task.isCancelled { return nil }
        WidgetEntry(date: Date(), item: item)
    }
}
```

---

## Debounce Notification Observers

When observing `NotificationCenter` in ViewModels, debounce to avoid redundant work:

```swift
NotificationCenter.default.publisher(for: .init(CDChangeNotification))
    .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
    .sink { [weak self] _ in
        self?.fetchData()
    }
    .store(in: &cancellables)
```
