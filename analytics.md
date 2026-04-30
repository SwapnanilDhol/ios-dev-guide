# Analytics Patterns

## Architecture: Logger Bridge

The analytics system uses a **multi-logger bridge** pattern. Multiple loggers are registered with `AnalyticsManager`; all events fan out simultaneously.

```
┌─────────────────────────────────────────────────┐
│              AppAnalyticsManager                │
│               (singleton facade)                │
│                                                 │
│  start() → AnalyticsManager.addLogger() × N     │
│  logEvent() → AnalyticsManager.logEvent()      │
└─────────────────────────────────────────────────┘
                          │
            ┌─────────────┴─────────────┐
            │   AnalyticsManager        │
            │    (SwapFoundationKit)     │
            └─────────────┬─────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
  ┌─────┴─────┐    ┌──────┴──────┐   ┌─────┴─────┐
  │ Firebase  │   │ Telemetry   │   │  Your     │
  │ Logger    │   │ Logger      │   │  Logger   │
  └───────────┘   └─────────────┘   └───────────┘
```

---

## AppEvent: Single Source of Truth

All events live in one enum conforming to `AnalyticsEvent`. Views and coordinators call `AppAnalyticsManager.shared.logEvent(event: .xxx)` — never log directly to individual loggers.

```swift
import SwapFoundationKit

public enum AppEvent: AnalyticsEvent {

    // Screen events
    case screenDidOpen(screenName: String)

    // Purchase events
    case purchaseCompleted(reason: String)
    case purchaseFailed(reason: String)
    case restoreCompleted(reason: String)

    // Ad events
    case didRecordBannerAdImpressions
    case didRecordFullScreenAdImpressions

    // Error events
    case proScreenLoadFailed(errorCategory: String, errorMessage: String)

    // MARK: - AnalyticsEvent conformance

    public var rawValue: String {
        switch self {
        case .screenDidOpen:             return "screen_did_open"
        case .purchaseCompleted:         return "purchase_completed"
        case .purchaseFailed:            return "purchase_failed"
        case .restoreCompleted:          return "restore_completed"
        case .didRecordBannerAdImpressions: return "banner_ad_impressions"
        case .didRecordFullScreenAdImpressions: return "full_screen_ad_impressions"
        case .proScreenLoadFailed:        return "pro_screen_load_failed"
        }
    }

    public var parameters: [String: String]? {
        switch self {
        case .screenDidOpen(let name):
            return ["screen_name": name]
        case .purchaseCompleted(let reason), .purchaseFailed(let reason):
            return ["reason": reason]
        case .restoreCompleted(let reason):
            return ["reason": reason]
        case .proScreenLoadFailed(let category, let message):
            return ["error_category": category, "error_message": message]
        default:
            return nil
        }
    }
}
```

**Rules**:
- `rawValue`: Always explicitly return kebab-case strings. No `default` fallbacks.
- `parameters`: Return `nil` for events with no associated values.
- **Sendable Rule**: Never use `Error` as an associated value — convert to `String`.

---

## Screen Tracking Strategy (SwiftUI)

For SwiftUI apps, do not rely on automatic PostHog screen capture. It produces framework-level names like `UIHostingController<...>` that are noisy and not business-usable.

Use this pattern:

1. Disable automatic screen capture in PostHog setup.
2. Emit explicit `screen_viewed` / `screen_did_open` events from app code.
3. Standardize screen names in snake_case (`home`, `settings`, `paywall`, `subscription_detail`, etc.).
4. Include a `source` field (`coordinator_start`, `tab_bar`, `deep_link`, `onboarding`, etc.).

```swift
let config = PostHogConfig(apiKey: apiKey, host: host)
config.captureScreenViews = false
PostHogSDK.shared.setup(config)
```

```swift
AppAnalyticsManager.shared.logEvent(
    event: .screenViewed(screenName: "settings", source: "tab_bar")
)
```

Minimum surface coverage for navigation-based apps:

- Root tabs (home, calendar, settings)
- Onboarding container + key onboarding steps
- Paywall
- Detail screen
- Add/Edit screen
- Import/Export screen
- Pro sheet open event (`pro_screen_opened`) and load error event (`pro_screen_load_failed`)

---

## SwapPro Error Taxonomy

Wire `SwapProDelegate.didThrowError` into a dedicated structured event so dashboards can distinguish paywall failures from transaction failures.

```swift
case proScreenLoadFailed(errorCategory: String, errorMessage: String)
```

```swift
extension ProManager: SwapProDelegate {
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

This enables critical alerts like "fire if `pro_screen_load_failed` count > 0 hourly."

---

## Analytics Audit Checklist

Perform a periodic audit to identify gaps:

### Step 1: Map the user journey
1. **Acquisition** — How did the user get to the app?
2. **Onboarding** — Did they complete setup?
3. **Core action** — What is the primary thing the app does?
4. **Conversion** — Did they upgrade? See an ad?
5. **Retention** — Did they come back?

### Step 2: Check every screen
For each screen, verify a `screen_did_open` event exists.

### Step 3: Check every conversion point
- Did they tap the purchase button? → `purchase_flow_started`
- Did they complete the purchase? → `purchase_completed` / `purchase_failed`
- Did they see the pro paywall? → `pro_screen_opened`
- Did they restore purchases? → `restore_completed` / `restore_failed`

### Step 4: Identify missing events

| Missing event | Why it matters |
| --- | --- |
| `pro_paywall_dismissed` | Understand drop-off at paywall |
| `onboarding_skipped` | Quantify how many users skip setup |
| `feature_gate_shown` | Measures demand for pro features |
| `notification_permission_granted` | Tracks opt-in rate |
| `deep_link_opened` | Tracks which channels bring users back |

**Rule**: Every `switch` that branches on user choice should likely have a corresponding analytics event.

---

## Adding a New Event

1. Add the case to `AppEvent` with any associated values needed
2. Add the `case` clause in `rawValue` returning a kebab-case string
3. Add the `case` clause in `parameters` returning associated values as a `String` dictionary (or `nil`)
4. Call it via `AppAnalyticsManager.shared.logEvent(event: .yourEvent(...))`

---

## Checklist

Before marking analytics as done in a new project:

- [ ] `AppEvent` enum exists with `AnalyticsEvent` conformance
- [ ] `rawValue` explicitly returns kebab-case strings for every case (no `default` fallback)
- [ ] `parameters` returns `[String: String]?` for every case (or `nil`)
- [ ] No `Error` types are used as associated values (converted to `String`)
- [ ] `AppAnalyticsManager` registers at least `FirebaseLogger` and `TelemetryLogger`
- [ ] Automatic screen capture is disabled in PostHog (or equivalent)
- [ ] Every major screen emits an explicit `screen_did_open` event
- [ ] `SwapProDelegate.didThrowError` is wired to `proScreenLoadFailed`
- [ ] All conversion points (purchase, restore, ad impressions) have corresponding events
- [ ] A periodic analytics audit is scheduled to find gaps
