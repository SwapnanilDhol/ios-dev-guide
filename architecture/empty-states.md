# Empty States

Host apps use two empty-state patterns. Choose from the **content context**, not from a feature accent color.

## Primary screen empty state

Use `SFKEmptyStateView` (SwapFoundationKit) when a screen or feature collection has no content yet. The component provides:

- one monochrome SF Symbol;
- a concise title and one explanatory sentence;
- an optional primary `SFKButton` action;
- a compact inline layout that sits naturally beneath the screen's existing heading or controls.

Pass the app's primary accent for CTAs. Primary empty screens suppress decorative feature auras — the action is the only accent-colored element. Do not enclose the state in a card: a bounded surface exaggerates unused space. Keep content near the existing heading or controls rather than vertically centering it in a large blank area.

## Contextual empty result

Use SwiftUI `ContentUnavailableView` when only a subsection is empty or a search/filter has no matches. Keep surrounding context visible (selected date, chart range, active filters). Contextual actions should resolve the state directly (clear search / filters).

## Copy and accessibility

- State what is missing in the title.
- Explain what will make content appear in one sentence.
- Include an action only when it is the obvious next step.
- Localize titles and messages with `LocalizedStringKey`; localize `SFKButton` titles as plain strings (`.localized`).
- Give every actionable empty state a stable accessibility identifier.

## Checklist

- [ ] Primary collection empties use `SFKEmptyStateView`
- [ ] Search/filter/subsection empties use `ContentUnavailableView`
- [ ] No card chrome around primary empty states
- [ ] CTA uses design-system button + accessibility identifier
- [ ] Copy follows title + one-sentence guidance
