# SFK-First Workflow

Before building or refactoring reusable UI, utilities, or app infrastructure in a host app, check SwapFoundationKit first.

## Discovery order

1. Read `SwapFoundationKit/Docs/capabilities.yaml`.
2. Read `SwapFoundationKit/Docs/development/feature-discovery.md` and the linked domain guide.
3. Decide with the model below before writing custom host-app code.

## Decision model

| Decision | When |
|----------|------|
| `use_sfk_directly` | SFK already provides the needed public API |
| `wrap_sfk` | SFK provides the primitive; the host needs app-specific logic on top |
| `keep_custom` | SFK does not fit, or the app intentionally diverges |

Especially important for: settings, buttons, onboarding, pickers, alerts, sync/shared storage, empty states, and generic utilities.

## Keep in the host app

Even when SFK provides building blocks, keep these in the host:

- Product / domain logic
- Navigation and coordinator orchestration
- Monetization product rules (what to gate, when)
- Feature module state machines

## Wrapper-only third-party SDKs

App targets never import Google Mobile Ads / RevenueCat AdMob wrappers directly — SFK owns `#if canImport`. See [`ads.md`](ads.md).

## Implementation summaries

When finishing work, state which SFK domain(s) were checked and why SFK was used or skipped.

## Checklist

- [ ] `capabilities.yaml` consulted for the domain
- [ ] Decision recorded as use / wrap / keep_custom
- [ ] No direct third-party ad SDK imports in the app target
- [ ] Host still owns product orchestration
