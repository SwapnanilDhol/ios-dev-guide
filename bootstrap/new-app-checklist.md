# New App Checklist

Day-0 path for a brand-new SFK-first iOS app. Walk this list in order. Each item links to the page whose **checklist** must pass before you mark the topic done.

## 0. Clone this kit

1. Clone or submodule [`ios-dev-guide`](https://github.com/SwapnanilDhol/ios-dev-guide) next to the Xcode project.
2. From the kit: `./scripts/bootstrap-new-app.sh /path/to/NewApp`
3. Or link agent entrypoints: `./scripts/link-guide.sh /path/to/NewApp`

## 1. Bootstrap

- [ ] Thin AppDelegate + launch order — [`appdelegate-setup.md`](appdelegate-setup.md)
- [ ] Two-bundle-ID isolation (if you want side-by-side Dev/Prod) — [`two-bundle-id.md`](two-bundle-id.md) + skill `skills/two-bundle-id-workflow`
- [ ] Build gate documented — [`build.md`](build.md)
- [ ] SPM packages resolve; archive smoke test — [`../ops/spm-debugging.md`](../ops/spm-debugging.md)

## 2. Architecture

- [ ] Module layout (MVVM-C), coordinators own presentations — [`../architecture/architecture.md`](../architecture/architecture.md)
- [ ] Concurrency (`@MainActor`, cancellation) — [`../architecture/concurrency.md`](../architecture/concurrency.md)
- [ ] Localization rules — [`../architecture/localization.md`](../architecture/localization.md)
- [ ] CTA / bottom footers — [`../architecture/cta-and-footers.md`](../architecture/cta-and-footers.md)
- [ ] Empty states — [`../architecture/empty-states.md`](../architecture/empty-states.md)
- [ ] Settings shell — [`../architecture/settings.md`](../architecture/settings.md)
- [ ] Persistence / provider split (if using Core Data) — [`../architecture/persistence.md`](../architecture/persistence.md)

## 3. Stack

- [ ] SFK-first decision model — [`../stack/sfk-first.md`](../stack/sfk-first.md)
- [ ] RevenueCat / Pro — [`../stack/revenuecat.md`](../stack/revenuecat.md)
- [ ] Analytics / `AppEvent` — [`../stack/analytics.md`](../stack/analytics.md)
- [ ] Ads (if monetized with ads) — [`../stack/ads.md`](../stack/ads.md)
- [ ] Update-available banner — [`../stack/update-available-banner.md`](../stack/update-available-banner.md)
- [ ] Snippets as needed — [`../stack/code-snippets.md`](../stack/code-snippets.md)

## 4. Product surfaces

- [ ] Premium onboarding (when shipping a first-run flow) — [`../product/onboarding.md`](../product/onboarding.md) + skill `skills/premium-onboarding`

## 5. Ops (before first TestFlight / App Store)

- [ ] Screenshots — [`../ops/app-store-screenshots.md`](../ops/app-store-screenshots.md) + skill `skills/generate-app-store-screenshots`
- [ ] ASC submission — [`../ops/asc-submission.md`](../ops/asc-submission.md)
- [ ] Maestro smoke (optional) — [`../ops/maestro-testing.md`](../ops/maestro-testing.md)
- [ ] Production alerts / analytics debrief — [`../ops/production-alerts.md`](../ops/production-alerts.md), [`../ops/analytics-debrief.md`](../ops/analytics-debrief.md)

## 6. Build gate

Before marking any implementation task complete:

```bash
rtk xcodebuild -scheme <Scheme> -destination 'platform=iOS Simulator,name=<Simulator>' -quiet build
```

Treat **exit code** as source of truth. Prefer archive verification before shipping (`xcodebuild -archive`).

## Checklist

- [ ] Bootstrap script or `link-guide.sh` has been run
- [ ] Product overlay `AGENTS.md` exists in the app repo (deltas only)
- [ ] `Docs/architecture.md` stub exists and will be filled as modules land
- [ ] Every stack topic you enabled has its page checklist green
