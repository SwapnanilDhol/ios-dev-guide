# Architecture

High-level map for this host app. Shared MVVM-C / coordinator / SFK conventions live in the sibling **ios-dev-guide** kit (`architecture/architecture.md`).

## Modules

| Module | Doc | Coordinator |
|--------|-----|-------------|
| <!-- Feature --> | `Docs/modules/feature.md` | `FeatureCoordinator` |

## Data flow

Service / Provider → ViewModel → View. Coordinators own presentations.

## SFK integration

List SFK domains used (`buttons`, `settings`, `onboarding`, …) and any intentional `keep_custom` decisions.

## Last updated

YYYY-MM-DD
