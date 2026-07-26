# Settings (Host App)

Canonical SFK patterns live in SwapFoundationKit:

- `SwapFoundationKit/Docs/guides/settings-patterns.md`
- `SwapFoundationKit/Docs/guides/settings.md`

This page is the **host-app checklist** for wiring those primitives.

## Principles

1. Every settings row is `SFKSettingsRow` / `SFKSettingsToggle` — never hand-rolled `Button` + `HStack` rows.
2. Trailing values use `SFKSettingsTrailing` (`.value("text")`), not `AnyView(Text(...))`.
3. Tap routing is a single `switch` with `case let item as SomeType:` — no `if let … else if let` chains.
4. No SwiftUI `.alert` / `.confirmationDialog` — use `AlertPresenter` from the coordinator.
5. No `@State` for sheets/modals/alerts — presentation lives on the ViewModel or coordinator.
6. No business logic in the view (`UIPasteboard`, `UserDefaults`, `Purchases`, haptics belong in the VM).

## Shell shape

```swift
SFKSettingsScreen(
    theme: theme,
    header: { /* optional pro banner */ },
    customSections: [ /* toggles / mixed custom rows */ ],
    sections: [
        SFKSettingsSectionConfiguration(title: "App Settings", items: …),
        SFKSettingsSectionConfiguration(title: "Data", items: …),
    ],
    rowTrailingBuilder: { item in
        switch item {
        case let info as SFKInformationItem where info == .version:
            return .value(versionString)
        default:
            return nil
        }
    },
    onItemTap: { item in
        switch item {
        case let appItem as SFKAppSettingsItem: handle(appItem)
        case let dataItem as SFKDataHandlingItem: handle(dataItem)
        default: break
        }
    }
)
```

## Section rules

- **One section per logical group** — never two sections with the same title.
- When a group mixes toggles and tappable rows, use one `SFKSettingsCustomSection`.
- **Debug** section is last, gated behind `Configuration.showDebugUtilities` (or equivalent).
- Dangerous ops (delete all data, reset prefs, stress tests) live only in Debug.

## Update banner

Use `.withUpdateBanner(version:appStoreID:)` — see [`../stack/update-available-banner.md`](../stack/update-available-banner.md).

## Checklist

- [ ] Rows are SFK components only
- [ ] Trailing values use `SFKSettingsTrailing`
- [ ] Tap routing is exhaustive `switch` type-casts
- [ ] Alerts via `AlertPresenter` from coordinator
- [ ] No presentation `@State` in the settings view
- [ ] Debug gated and at the bottom
- [ ] SFK `settings-patterns.md` consulted before custom work
