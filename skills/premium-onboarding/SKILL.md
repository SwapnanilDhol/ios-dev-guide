---
name: premium-onboarding
description: >-
  Implement or evolve a premium multi-step onboarding flow for SFK-first SwiftUI
  apps. Use when adding first-run setup, marketing → personalize → demo →
  permission → paywall sequences, onboarding progress flags, shared footers,
  or enum-driven onboarding CTAs.
---

# Premium Onboarding

## When to use

- Building or refactoring first-run / resume onboarding
- Designing step order, shared footer CTAs, or presentation vs progress flags
- Wiring notifications / paywall steps after value is shown
- Porting the narrative shape to a new product

## Non-goals

- Dumping Windfall/MoneyTracker source files into another app
- Replacing SFK onboarding primitives with one-off progress UI
- Product copy that belongs only in the host app's module doc

## Read in order

1. **SFK primitives** — `SwapFoundationKit/Docs/capabilities.yaml` (`onboarding` domain) and `SwapFoundationKit/Docs/guides/onboarding.md`
2. **This kit's playbook** — [`../../product/onboarding.md`](../../product/onboarding.md)
3. Host app module map (if it exists), e.g. `Docs/modules/onboarding.md`

Decision: prefer `wrap_sfk` — SFK owns progress/typography/cards/buttons; the host owns the story and state machine.

## Invariants

1. Narrative shape: Attract → Personalize → Validate → Demonstrate → Ask → Deliver
2. Enum is the single source of truth for step order, scroll vs fixed layout, shared footer, CTA titles
3. Presentation flags ≠ progress flags (launch / resume / debug / preview)
4. Coordinators own sheets (account entry, system settings, pro paywall)
5. Shared footer via bottom safe-area bar + `SFKButton`; specialized steps may own their own CTA
6. Ask for notifications / purchase only after value is visible
7. Previews use `*PreviewSupport` with explicit deps — no fake coordinator inits
8. Full-screen onboarding exits through one opaque hosting surface; animated child
   views never bypass the coordinator with production environment dismissal

## Workflow

1. Check SFK onboarding domain; reuse progress, typography, cards, buttons.
2. Define `OnboardingStep` (or equivalent) with computed chrome properties.
3. Implement dual flags + presentation intent matrix from the playbook.
4. Build the shared setup shell + footer; specialize only when permission/monetization/timing differ.
5. Wire coordinator delegate methods for complete / dismiss / nested entry / pro sheet.
6. Add the single-layer hosting-controller dismissal pattern from playbook §7.1
   when the flow contains continuously rendered or UIKit-backed content.
7. Add analytics funnel events and accessibility identifiers.
8. Walk the playbook migration checklist and definition of done.

## Checklist

Use the checklists at the bottom of [`product/onboarding.md`](../../product/onboarding.md)
(migration + DoD sections). Verify final and marketing-only dismissal frame by frame;
an accessibility-tree transition alone cannot detect orphaned render layers. Do not
mark onboarding done until those checks pass.
