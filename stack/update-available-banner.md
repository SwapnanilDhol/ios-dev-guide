# Update Available Banner Pattern

Use `SFKSettingsScreen` + `UpdateAvailableKit` through `SwapFoundationKit`'s
`SFKUpdateAvailabilityService` for production-safe update prompts.

## Why this pattern

- Keeps update-checking logic out of feature view models.
- Gives a single shared source of truth for update availability.
- Works with `SFKUpdateAvailableBannerView` in a top safe-area inset.
- Allows debug-only forced banner states without polluting production behavior.

## App startup

Start update checks once during app setup:

```swift
import SwapFoundationKit

private func setup() {
    // ...
    SFKUpdateAvailabilityService.shared.start()
}
```

## Settings usage

In settings UI, bind banner version from the shared service.

```swift
import SwapFoundationKit

@ObservedObject private var updateAvailability = SFKUpdateAvailabilityService.shared
@StateObject var viewModel: SettingsViewModel

private var updateBannerVersionBinding: Binding<String?> {
    Binding(
        get: {
            #if DEBUG
            if let debugForcedVersion = viewModel.debugForcedUpdateBannerVersion {
                return debugForcedVersion
            }
            #endif
            return updateAvailability.bannerVersion
        },
        set: { newValue in
            guard newValue == nil else { return }
            viewModel.clearDebugForcedUpdateBannerVersion()
            updateAvailability.dismissBanner()
        }
    )
}
```

Then pass it to `SFKSettingsScreen`:

```swift
SFKSettingsScreen(
    // ...
    updateBannerVersion: updateBannerVersionBinding,
    updateBannerAppStoreID: AppMetadataLink.appID.value,
    onItemTap: { item in
        viewModel.performAction(for: item)
    }
)
```

## Debug-only manual trigger

If you need a debug menu action for screenshots/demos, only set a forced version
in DEBUG builds:

```swift
#if DEBUG
debugForcedUpdateBannerVersion = "2.1.0"
#endif
```

Never use the debug forced state for production checks.

---

## Checklist

Before marking the update banner as done in a new project:

- [ ] `SFKUpdateAvailabilityService.shared.start()` is called during app setup
- [ ] Settings UI binds `updateBannerVersion` to `SFKUpdateAvailabilityService.shared.bannerVersion`
- [ ] `updateBannerAppStoreID` is passed correctly to `SFKSettingsScreen`
- [ ] Debug-only forced banner versions are wrapped in `#if DEBUG`
- [ ] Banner dismissal updates the shared service state
