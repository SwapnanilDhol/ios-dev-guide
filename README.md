# iOS Implementation Guide

A structured reference for building production iOS apps with SwapFoundationKit, SwapProKit, RevenueCat, and Google Ads.

---

## Philosophy

This guide captures **architectural principles**, not step-by-step tutorials. Principles transfer across projects; procedures become stale.

Three rules:
1. **App targets never import third-party SDKs directly** — always through a wrapper in SwapFoundationKit
2. **One class, one responsibility** — if a class has more than 5 responsibilities, split it
3. **Explicit over implicit** — every event name, every key, every method call is intentional

---

## Directory Structure

```
ios-dev-guide/
├── README.md                    ← You are here
├── patterns/                    ← Architectural principles
│   ├── architecture.md          ← AppDelegate, coordinators, managers
│   ├── concurrency.md           ← @MainActor, nonisolated, Task propagation
│   ├── ads.md                   ← AdsManager, wrapper-only pattern
│   ├── analytics.md             ← Logger bridge, AppEvent, audit
│   └── revenuecat.md            ← ProManager, SwapProDelegate wiring
├── reference/                   ← Copy-pasteable snippets
│   ├── appdelegate-checklist.md ← Launch setup checklist
│   └── snippets.md              ← Common code patterns
└── ops/                         ← Operational runbooks (app-specific)
    ├── debrief.md               ← Daily/weekly report format
    ├── alerts-passmaker.md      ← PostHog alert config (PassMaker)
    ├── maestro-testing.md       ← UI automation with Maestro
    └── spm-debugging.md        ← SPM/DerivedData troubleshooting
```

---

## Golden Rules

### 1. Wrapper-Only for External SDKs

Never import GoogleMobileAds, RevenueCatAdMob, or SwapProKitAdMob directly in the app target. Use the wrappers in SwapFoundationKit:

```swift
// App code — correct
import SwapFoundationKit
AdsManager.shared.start(with: configuration)
AdaptiveBannerAdView()

// App code — wrong
import GoogleMobileAds
import SwapProKitAdMob
#if canImport(SwapProKitAdMob)
// ...
#endif
```

**Why**: `canImport()` in app targets fails silently in Release builds — the build succeeds but entire feature branches are compiled out. Let SwapFoundationKit handle conditional compilation.

### 2. Thin AppDelegate

AppDelegate orchestrates managers. It owns no logic:

```swift
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(...) -> Bool {
        setup()
        return true
    }

    private func setup() {
        AppLifecycleHandler.shared.start()
        FirebaseApp.configure()
        ProManager.shared.start()
        AppAnalyticsManager.shared.start()
        setupAds()
        // ...
    }
}
```

### 3. @MainActor + nonisolated for Delegates

Any delegate protocol with nonisolated requirements (SwapProDelegate, PurchasesDelegate) needs `Task { @MainActor in }` to bridge back:

```swift
@MainActor
final class ProManager: SwapProDelegate {
    nonisolated func purchaseDidComplete(...) {
        Task { @MainActor in
            updateProEnabled(from: customerInfo)
        }
    }
}
```

### 4. AppEvent as Single Source of Truth

All analytics events live in one enum. Views and coordinators call `AppAnalyticsManager.shared.logEvent(event: .xxx)` — never log directly to Firebase or other loggers.

### 5. Build Verification in Archive, Not Run

Test Release builds with `xcodebuild -archive` before shipping. Debug builds and simulator runs can pass while Release builds fail silently (e.g., from `canImport` issues).

---

## Quick Reference: Module Imports

| Type | Required Import |
| --- | --- |
| `AdsManager`, `AdsConfiguration`, `AdaptiveBannerAdView` | `SwapFoundationKit` |
| `SwapProManager`, `SwapProConfiguration`, `SwapProDelegate` | `SwapProKit` |
| `Purchases`, `CustomerInfo`, `Package` | `RevenueCat` |
| `AnyCancellable` | `Combine` |
| `SFKButton`, `GlassEffectContainer`, `ToastManager` | `SwapFoundationKit` |
| `HapticsHelper`, `Logger`, `AppLinkOpener` | `SwapFoundationKit` |
| `AppEnvironment`, `DeviceInfoService` | App-defined |
