# Localization

## Principles

1. Prefer **implicit** SwiftUI localization via `LocalizedStringKey`.
2. Use `.localized` only when the API takes a plain `String`.
3. Keep one-off copy out of a central `L10n` enum unless it is reused widely.
4. Brand display names come from the bundle (`AppConstants.App.name` or equivalent), not hardcoded product strings.

## SwiftUI (preferred)

String literals in `Text`, `Label`, `navigationTitle`, `TextField`, `Picker`, `Section` headers/footers, and alert titles localize implicitly — **do not** append `.localized`.

```swift
Text("No budgets yet")
.navigationTitle("Settings")
```

## When to use `.localized`

APIs that take `String` (not `LocalizedStringKey`):

- `SFKButton("Save".localized, …)`
- UIKit alerts / mail compose subjects
- Computed `String` properties fed into SFK settings rows / trailing values

## L10n.swift

Optional. Reserve for strings reused across many files. Do not route one-off screen copy through `L10n`.

## App Intents

- Do **not** use `.localized` on `AppIntent` parameter titles (raw English strings).
- Use raw string literals for `LocalizedStringResource` types.

## Catalog

Keep `Localizable.xcstrings` as the catalog. Typical locales for this stack: `de`, `es`, `ja`, `zh-Hans`, `zh-Hant` (add per product).

## Checklist

- [ ] SwiftUI literals omit `.localized`
- [ ] `SFKButton` / UIKit / plain-`String` APIs use `.localized` where required
- [ ] No one-off strings forced through `L10n`
- [ ] User-visible app name reads from bundle display name
- [ ] App Intent titles are raw strings
