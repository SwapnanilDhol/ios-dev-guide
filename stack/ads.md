# Ad Integration Patterns

> **Core principle**: App targets never import GoogleMobileAds, RevenueCatAdMob, or SwapProKitAdMob directly. All ad logic lives in SwapFoundationKit's conditional compilation blocks. App code only touches `AdsManager` and `AdaptiveBannerAdView`.

---

## Why Wrapper-Only Architecture

`canImport()` in app targets is unreliable across build configurations:

- `canImport(SwapProKitAdMob)` returns `false` in Release builds even when the module exists
- The app target has no direct dependency on those modules — Swift's module system can't resolve them at compile time
- Build succeeds with no errors → entire ad system is compiled out → zero ad revenue
- RevenueCat ad attribution (purchases-ios-admob) also silently disabled

```
App Target                    SwapFoundationKit
─────────────                ─────────────────
AdsManager.shared.start()  → #if canImport(GoogleMobileAds)
                              // real impl
                              #else
                              // stub impl
                              #endif
```

`AdsManager` handles unavailability gracefully. No `#if canImport(...)` guards needed in app code.

---

## AppAdsManager Setup

```swift
import UIKit
import SwapFoundationKit

final class AppAdsManager {
    static let shared = AppAdsManager()

    private init() {}

    func start() {
        let configuration = AdsConfiguration(
            provider: .google(GoogleAdsConfiguration()),
            adUnits: AdUnitConfiguration(
                banner: AppConstants.AppId.bannerAdUnit,
                interstitial: AppConstants.AppId.interstitialAdUnit,
                rewarded: AppConstants.AppId.rewardedAdUnit
            ),
            preloadOnStart: [.interstitial],
            isEligibleToShowAds: {
                !ProManager.shared.isProEnabled
            },
            presentingViewController: {
                UIApplication.topViewController()
            },
            eventHandler: { event in
                switch event {
                case .impression(.banner):
                    AppAnalyticsManager.shared.logEvent(event: .didRecordBannerAdImpressions)
                case .click(.banner):
                    AppAnalyticsManager.shared.logEvent(event: .didRecordBannerAdClick)
                case .impression(.interstitial), .impression(.rewarded):
                    AppAnalyticsManager.shared.logEvent(event: .didRecordFullScreenAdImpressions)
                case .click(.interstitial), .click(.rewarded):
                    AppAnalyticsManager.shared.logEvent(event: .didRecordFullScreenAdClick)
                case .loaded, .failed, .dismissed:
                    break
                }
            }
        )
        Task { @MainActor in
            await AdsManager.shared.start(with: configuration)
        }
    }
}
```

---

## Ad Eligibility

Always gate ads behind pro status:

```swift
isEligibleToShowAds: {
    !ProManager.shared.isProEnabled
}
```

Pro users never see ads. Non-pro users see ads based on runtime availability.

---

## Banner Ads in SwiftUI

Use `AdaptiveBannerAdView` from SwapFoundationKit:

```swift
import SwapFoundationKit

struct MyView: View {
    var body: some View {
        VStack {
            // content
            AdaptiveBannerAdView()
        }
    }
}
```

For preview environments, wrap in a conditional:

```swift
var body: some View {
    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
        // Preview placeholder
        Color.clear.frame(height: 50)
    } else {
        AdaptiveBannerAdView()
    }
}
```

---

## Interstitial Presentation

```swift
// Before adding a color/item
_ = await AdsManager.shared.presentInterstitial()
```

`AdsManager` checks `isEligibleToShowAds` before presenting. If the user is pro or the ad isn't loaded, it returns silently.

---

## AdPresentationResult

`presentInterstitial()` and `presentRewarded()` return `AdPresentationResult`:

```swift
public enum AdPresentationResult: Sendable, Equatable {
    case shown
    case skippedIneligible
    case unavailable
    case failed
}
```

Check for `.shown`, **not** `.presented`:

```swift
// CORRECT
if result != .shown {
    showProSheet(for: reason)
}

// WRONG — does not compile
if result != .presented { ... }
```

---

## Migration: Removing Direct SDK Imports

If the app target has direct imports of `GoogleMobileAds` or `SwapProKitAdMob` with `#if canImport(...)` guards:

1. **Remove guard blocks** — `AdsManager` handles unavailability, no need to check
2. **Remove imports** — delete `import GoogleMobileAds` and `import SwapProKitAdMob` from app target
3. **Replace banner view structs** — any inline `UIViewControllerRepresentable` wrappers for `BannerView` become `AdaptiveBannerAdView()` from SwapFoundationKit
4. **Replace rewarded/interstitial calls** — any `RewardedAd.swapProLoadAndTrack()` calls in app target become `AdsManager.shared.preload([.rewarded])` + `AdsManager.shared.presentRewarded()`
5. **Verify** — both Debug and Release builds succeed. Release failure on `canImport` means migration is incomplete

---

## Key Rules

1. App targets never directly import GoogleMobileAds, RevenueCatAdMob, or SwapProKitAdMob
2. App targets never use `#if canImport(...)` guards
3. All third-party SDK logic lives in SwapFoundationKit's `#if` blocks
4. `AdsManager` and `AdaptiveBannerAdView` are always callable from app code
5. `AdsManager.shared.start()` must be called on the main actor

---

## Checklist

Before marking ad integration as done in a new project:

- [ ] No app target file imports `GoogleMobileAds`, `RevenueCatAdMob`, or `SwapProKitAdMob`
- [ ] `AppAdsManager` exists and configures `AdsConfiguration` with correct ad unit IDs
- [ ] `isEligibleToShowAds` gates ads behind `!ProManager.shared.isProEnabled`
- [ ] `preloadOnStart` includes at least `[.interstitial]`
- [ ] Banner ads use `AdaptiveBannerAdView()` from SwapFoundationKit
- [ ] Interstitial presentation uses `await AdsManager.shared.presentInterstitial()` before add/create actions
- [ ] Ad events (impression, click) are wired to `AppAnalyticsManager`
- [ ] Both Debug and Release builds archive successfully without `canImport` errors
