# CTAs and Bottom Footers

## Principles

1. Primary actions use the design-system button (`SFKButton`), never a plain unstyled SwiftUI `Button`.
2. Save / confirm CTAs live in a **bottom action bar**, not in a toolbar `confirmationAction`.
3. Every CTA carries a stable `.accessibilityIdentifier(...)`.
4. When chrome varies by mode/step, drive titles and enabled state from an **enum + computed properties** — not inline ternaries in `body`.

## Design-system mapping (this stack)

| Role | Component |
|------|-----------|
| Primary / secondary / toolbar | `SFKButton` (`.primary`, `.secondary`, `.toolbar`) |
| Close / dismiss | `SFKCloseButton` |
| Content glass | `.glassEffectCompat(...)` |
| Bottom bar padding | `verticalPadding: 8` for compact action bars |

## Bottom bar pattern

Pin with `safeAreaInset(edge: .bottom)` (or a shared `AppBottomActionFooter`).

Disabled-state pattern: muted title color, reduced opacity, **no** haptic feedback when invalid.

## Enum-driven chrome

```swift
private var primaryCTATitle: String {
    switch viewModel.currentStep {
    case .welcome: return "Get Started".localized
    case .addAccount: return "Add account"
    default: return "Continue"
    }
}

private var secondaryCTATitle: String? {
    switch viewModel.currentStep {
    case .addAccount: return "I'll add accounts later".localized
    default: return nil
    }
}

private var primaryCTAAccessibilityIdentifier: String { "onboardingPrimaryCTA" }
```

In `body`, bind to those properties. Put actions in a dedicated method (`primaryCTAAction()`), not scattered closures.

## Don't

```swift
if viewModel.currentStep == .addAccount {
    SFKButton("I'll add accounts later", ...) { ... }
}
.navigationTitle(viewModel.mode == .create ? "New Tag".localized : "Edit Tag".localized)
```

## Checklist

- [ ] Primary CTAs use `SFKButton` (or the app's design-system equivalent)
- [ ] Save/confirm lives in a bottom safe-area bar
- [ ] Close uses `SFKCloseButton`
- [ ] Accessibility identifiers on every CTA
- [ ] Mode/step chrome driven by enum computed properties
- [ ] Invalid forms: muted, reduced opacity, no haptics
