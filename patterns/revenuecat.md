# RevenueCat + SwapProKit Patterns

## ProManager Overview

`ProManager` encapsulates all RevenueCat + SwapProKit setup in a single `@MainActor` singleton. It handles:

- `Purchases` configuration with the RevenueCat API key
- `SwapProManager` configuration with entitlement name and UserDefaults key
- Pro state persistence and App Group sync
- `SwapProDelegate` callbacks (purchase, restore, error)
- `PurchasesDelegate` callbacks (subscription state updates)
- Bridging all purchase lifecycle events to `AppAnalyticsManager`

---

## ProManager Implementation

```swift
import UIKit
import RevenueCat
import SwapProKit
import SwapFoundationKit

@MainActor
final class ProManager: NSObject {

    static let shared = ProManager()

    private override init() { }
    private let hapticsHelper = HapticsHelper()

    func start() {
        #if DEBUG
        Purchases.logLevel = .debug
        #endif
        let configuration = Configuration.Builder(withAPIKey: AppConstants.ServiceKeys.revenueCatAppID)
        Purchases.configure(with: configuration)
        Purchases.shared.attribution.setAttributes(DeviceInfoService.properties())
        Purchases.shared.delegate = self

        setupSwapPro()

        Task {
            guard let customerInfo = try? await Purchases.shared.customerInfo() else { return }
            updateProEnabled(from: customerInfo)
        }
    }

    public var isProEnabled: Bool {
        UserDefaults.shared.bool(for: UserDefaultsKey.isProEnabled)
    }

    private func setupSwapPro() {
        SwapProManager.shared.delegate = self  // set BEFORE start()
        let configuration = SwapProConfiguration(
            entitlement: "proAccess",  // must match App Store Connect exactly
            userDefaultsKey: UserDefaultsKey.isProEnabled.rawValue
        )
        SwapProManager.shared.start(with: configuration)
    }

    private func updateProEnabled(from customerInfo: CustomerInfo) {
        let isProEnabled = !customerInfo.entitlements.active.isEmpty
        UserDefaults.standard.set(isProEnabled, for: UserDefaultsKey.isProEnabled)
        UserDefaults.shared.set(isProEnabled, for: UserDefaultsKey.isProEnabled)  // App Group
    }
}
```

**Key rules**:
- `SwapProManager.shared.delegate` must be set **before** calling `SwapProManager.shared.start()`
- Always dual-write to both `UserDefaults.standard` and `UserDefaults.shared` (App Group) for widget/watch access

---

## SwapProDelegate

All delegate methods are `nonisolated` — they can be called on any thread. Use `Task { @MainActor in }` to bridge back:

```swift
extension ProManager: SwapProDelegate {

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

    nonisolated func restoreDidComplete(
        customerInfo: RevenueCat.CustomerInfo,
        reason: String?
    ) {
        Task { @MainActor in
            // No active entitlements — show error, stay on paywall
            guard !customerInfo.entitlements.all.isEmpty else {
                hapticsHelper.errorNotification()
                return
            }

            updateProEnabled(from: customerInfo)
            AppAnalyticsManager.shared.logEvent(event: .restoreCompleted(reason: reason ?? "NA"))
            hapticsHelper.successNotification()
            UIApplication.topViewController()?.dismiss(animated: true)
        }
    }

    nonisolated func restoreDidFail(error: Error) {
        Task { @MainActor in
            hapticsHelper.errorNotification()
            syncAppGroupProStatus()
            _ = await AdsManager.shared.presentInterstitial()
            AppAnalyticsManager.shared.logEvent(event: .restoreFailed(error: reason))
        }
    }

    nonisolated func proViewDidPresent(reason: String) {
        Task { @MainActor in
            hapticsHelper.mediumImpact()
            AppAnalyticsManager.shared.logEvent(event: .proScreenOpened(reason: reason))
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

---

## PurchasesDelegate

Use `PurchasesDelegate` to receive subscription state updates when the user changes subscriptions outside the app:

```swift
extension ProManager: PurchasesDelegate {
    nonisolated func purchases(
        _ purchases: Purchases,
        receivedUpdated customerInfo: CustomerInfo
    ) {
        Task { @MainActor in
            updateProEnabled(from: customerInfo)
        }
    }
}
```

---

## Entitlement Requirements

- The entitlement name (e.g., `"proAccess"`) must match **exactly** what is configured in App Store Connect — case-sensitive
- If using an App Group for widgets/watch, sync `isProEnabled` to `UserDefaults.shared` (App Group suite)
