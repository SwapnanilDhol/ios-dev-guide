# Architecture Patterns

## AppDelegate: Thin Orchestrator

Keep `AppDelegate` as a pure orchestrator. It calls `setup()` once and delegates everything to dedicated classes.

```swift
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        setup()
        return true
    }

    private func setup() {
        AppLifecycleHandler.shared.start()
        FirebaseApp.configure()
        ProManager.shared.start()
        AppAnalyticsManager.shared.start()
        setupAds()
        NotificationManager.shared.start(delegate: self)
        AppAppearanceManager.shared.start()
    }
}
```

### Manager `start()` Pattern

All app services follow `Manager.shared.start()`:

| Manager | Method | Notes |
| --- | --- | --- |
| `AppLifecycleHandler.shared` | `.start()` | Lifecycle hook |
| `ProManager.shared` | `.start()` | RevenueCat + SwapProKit |
| `AppAnalyticsManager.shared` | `.start()` | Register all loggers |
| `AppAdsManager.shared` | `.start()` | Configure AdsManager |
| `NotificationManager.shared` | `.start(delegate:)` | Set UNUserNotificationCenter delegate |
| `AppAppearanceManager.shared` | `.start()` | Navigation bar, tint |

**Rules**:
- Managers that need config receive it via `start()` parameters
- Managers that are static-only (e.g., `SubscriptionCoreDataManager.start()`) don't need `.shared`
- Call all `start()` methods from a single `setup()` method — never scatter initialization

---

## Coordinators

### AppCoordinator (Singleton)

`AppCoordinator` is a singleton that owns the root window and `UISplitViewController` (iPad). It should NOT conform to the `Coordinator` protocol from SwapFoundationKit — that protocol is for module-level coordinators.

```swift
@MainActor
final class AppCoordinator {
    static let shared = AppCoordinator()
    var window: UIWindow?
    private(set) var splitViewController: UISplitViewController?

    private init() { }

    func setup(in application: UIApplication) {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        window = UIWindow(windowScene: scene!)
        window?.rootViewController = makeRootViewController()
        window?.makeKeyAndVisible()
    }
}
```

### Module Coordinators

Each feature module has its own coordinator conforming to `Coordinator` from SwapFoundationKit. These handle navigation within their domain and are children of `AppCoordinator`.

```
AppCoordinator (singleton)
├── HomeCoordinator
├── SettingsCoordinator
├── BucketCoordinator
└── ...
```

### Coordinator Protocol

```swift
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}
```

---

## AppAppearanceManager (Optional)

Encapsulates all UI appearance configuration:

```swift
@MainActor
final class AppAppearanceManager {
    static let shared = AppAppearanceManager()
    private init() { }

    func start() { configureNavigationBar() }

    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.scrollEdgeAppearance?.configureWithTransparentBackground()
        appearance.standardAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = appearance.standardAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance.scrollEdgeAppearance
    }
}
```

---

## NotificationManager

Thin wrapper that sets the `UNUserNotificationCenter` delegate:

```swift
final class NotificationManager {
    static let shared = NotificationManager()
    private init() { }

    func start(delegate: UNUserNotificationCenterDelegate) {
        UNUserNotificationCenter.current().delegate = delegate
    }
}
```

Keep notification scheduling logic in domain-specific services, not here.

---

## File Structure

```
App/
├── AppDelegate.swift              ← Thin orchestrator
├── AppCoordinator.swift           ← Root window, singleton
├── AppLifecycleHandler.swift      ← Lifecycle events + backup
├── AppAppearanceManager.swift     ← Navigation bar styling
├── AppAdsManager.swift            ← AdsConfiguration wrapper
├── NotificationManager.swift     ← UNUserNotificationCenter delegate
├── ProManager.swift               ← RevenueCat + SwapProKit
├── Service/
│   └── Analytics/
│       ├── AnalyticsManager.swift ← AppAnalyticsManager facade
│       ├── AppEvent.swift         ← All event definitions
│       └── Loggers/
│           ├── FirebaseLogger.swift
│           └── TelemetryLogger.swift
└── Utilities/
    ├── AppEnvironment.swift       ← debug/release/testing flags
    └── DeviceInfoService.swift    ← Analytics global params
```
