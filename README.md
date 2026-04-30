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

## Pages

Every page below ends with a **checklist** of things to verify before marking that topic as done in a new project.

### Patterns

| Page | What it covers |
|------|---------------|
| [Architecture](architecture.md) | AppDelegate, coordinators, managers, file structure |
| [Concurrency](concurrency.md) | `@MainActor`, `nonisolated`, Task propagation, cancellation |
| [Ads](ads.md) | AdsManager, wrapper-only pattern, banner & interstitial setup |
| [Analytics](analytics.md) | Logger bridge, AppEvent, screen tracking, audit |
| [RevenueCat](revenuecat.md) | ProManager, SwapProDelegate wiring, entitlements |
| [Update Available Banner](update-available-banner.md) | Update checks + settings banner wiring |

### Reference

| Page | What it covers |
|------|---------------|
| [AppDelegate Setup](appdelegate-setup.md) | Launch setup checklist, bootstrap order, verification |
| [Code Snippets](code-snippets.md) | Common reusable snippets for every project |

### Operations

| Page | What it covers |
|------|---------------|
| [Analytics Debrief](analytics-debrief.md) | Daily/weekly report format and KPIs |
| [Production Alerts](production-alerts.md) | PostHog alert config and operating guidance |
| [App Store Screenshots](app-store-screenshots.md) | Screenshot pipeline runbook |
| [ASC Submission](asc-submission.md) | App Store Connect submission with the ASC CLI |
| [Maestro Testing](maestro-testing.md) | UI automation with Maestro |
| [SPM Debugging](spm-debugging.md) | SPM, DerivedData & package cache troubleshooting |
| [Screenshot Automation Handoff](screenshot-automation-handoff.md) | Full operational handoff template for screenshot work |

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

---

## Using This Guide in Other Projects

This repo includes a helper script so any AI agent working on your other iOS projects can automatically read `AGENTS.md` and follow the patterns here.

### Quick start

From inside any other project:

```bash
~/Desktop/ios-dev-guide/link-guide.sh
```

This symlinks `AGENTS.md` (and the common pages) into the current project. Agents that open the project will read `AGENTS.md` automatically and know which file to open for every problem.

### Manual symlink (one file only)

```bash
ln -s ~/Desktop/ios-dev-guide/AGENTS.md AGENTS.md
```

### Unlink when you don't need it

```bash
rm AGENTS.md ads.md analytics.md architecture.md concurrency.md revenuecat.md update-available-banner.md code-snippets.md appdelegate-setup.md spm-debugging.md
```

These are just symlinks — removing them does not touch the real files in `ios-dev-guide`.
