# Architecture

## Principles

1. **Thin AppDelegate** — orchestrates manager `start()` calls; owns no business logic. Keep under ~150 lines.
2. **MVVM-C in feature modules** — View (SwiftUI) + ViewModel + Coordinator. Views stay lightweight.
3. **Coordinators own presentations** — sheets, modals, alerts, confirmation dialogs. Views call explicit coordinator methods; coordinators own style, delegates, and dismissal.
4. **Concrete providers** — no `*Providing` protocols. Test via subclasses in `MockProviders.swift` (or equivalent).
5. **One class, one responsibility** — if a type exceeds ~5 responsibilities, split it.
6. **Explicit over implicit** — every event name, key, and method call is intentional.

## Module layout

```text
Modules/<Feature>/
  <Feature>Coordinator.swift
  View/
  ViewModel/
  Model/
  Service/          # feature-local prefs if needed
```

Shared cross-cutting types live under `Service/`, `Persistence/`, `Helper/`, or `Shared/` — not inside a random feature folder.

## Provider / Service / Coordinator

| Kind | Role |
|------|------|
| **Provider** | Core Data (or store) CRUD over domain models |
| **Service** | UserDefaults / lightweight prefs |
| **Coordinator** | Navigation + high-level presentation + orchestration |

Coordinators may hold a shared provider and pass it to child view models — avoid `SomeProvider()` at every call site.

## Presentation rules

- Do **not** drive feature-level sheets/alerts from `@State` in views.
- Do **not** use SwiftUI `.alert` / `.confirmationDialog` for app alerts — use `AlertPresenter` (SwapFoundationKit) from the coordinator.
- Navigation callbacks: typed **delegate protocol** via initializer — not mutable closure properties assigned after init.
- Add `// MARK: - ProtocolName` above protocol-conformance extensions.

## State-driven UI

When chrome varies by mode, step, or permission, drive it from an enum with computed properties. See [`cta-and-footers.md`](cta-and-footers.md). Prefer `switch` over `if`/`else if` chains.

## Previews

Every view needs a working `#Preview`. Use `*PreviewSupport` factories or VM inits with explicit dependencies — never parameterless inits that fabricate coordinators.

## Layout notes

- Prefer `.background`, `.overlay`, `.safeAreaInset` over default `ZStack` wrappers.
- Full-bleed horizontal chip rails own their own horizontal insets; use `.scrollClipDisabled()` when needed. Do not fake full-bleed with negative padding.

## File naming

- One primary declaration per file; filename matches the type (`AccountRowView.swift` → `AccountRowView`).
- Pragmatic exceptions: tiny adjacent-only enums; nested config enums in a central `Configuration` type.

## Bootstrap order

See [`../bootstrap/appdelegate-setup.md`](../bootstrap/appdelegate-setup.md). Typical order: lifecycle → Firebase (if used) → Pro → Analytics → Ads → other managers.

## AppDelegate: thin orchestrator

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

All services follow `Manager.shared.start()`, called from a single `setup()` — never scatter initialization.

## Coordinators

- **AppCoordinator** (singleton) owns the root window / split view. It should **not** conform to SFK's module `Coordinator` protocol.
- **Module coordinators** conform to SFK `Coordinator`, handle domain navigation, and are children of `AppCoordinator`.

```text
AppCoordinator (singleton)
├── HomeCoordinator
├── SettingsCoordinator
└── …
```

## Typical App/ tree

```text
App/
├── AppDelegate.swift
├── AppCoordinator.swift
├── AppLifecycleHandler.swift
├── AppAppearanceManager.swift
├── AppAdsManager.swift
├── NotificationManager.swift
├── ProManager.swift
└── Service/Analytics/   # AppAnalyticsManager, AppEvent, loggers
```

## Checklist

- [ ] AppDelegate is ≤150 lines and only orchestrates `setup()`
- [ ] Every manager follows `Manager.shared.start()` from a single `setup()`
- [ ] Feature modules follow Coordinator / View / ViewModel / Model
- [ ] Presentations live on coordinators; no SwiftUI `.alert` for app alerts
- [ ] Providers are concrete; shared instances injected where needed
- [ ] Enum-driven chrome for mode/step UI
- [ ] Previews compile without fabricating the full graph
- [ ] No single class has more than 5 responsibilities
- [ ] SFK-first decision recorded for reusable UI (`../stack/sfk-first.md`)
