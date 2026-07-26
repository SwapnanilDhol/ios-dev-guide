> **Note:** This page may include worked examples from a specific app (e.g. PassMaker). Treat IDs/event names as templates — replace with the host app's PostHog project and funnel.

# PassMaker PostHog Alert Configuration

Two production-critical alerts are configured in PostHog project `PassMaker` (`387590`).

---

## Alert 1: Pro Screen Load Failures

- **Alert name**: `CRITICAL: Pro screen load failures > 0 (hourly)`
- **Insight**: `Critical: Pro screen load failures (hourly)` (`dliz5FWV`)
- **Trigger**: hourly check; fire if `pro_screen_load_failed` count > 0
- **Purpose**: catch SwapProKit metadata decode errors / offering or package load failures that block users from seeing plans

**Implementation notes**:
- `proScreenLoadFailed(errorCategory:errorMessage)` event in `PassMaker/Service/Analytics/AppEvent.swift`
- Wired `SwapProDelegate.didThrowError` → `proScreenLoadFailed` in `PassMaker/Service/ProManager.swift`
- `error_category` field enables alert threshold

---

## Alert 2: Backend Pass Creation Failures

- **Alert name**: `CRITICAL: Backend pass creation failures > 2 (hourly)`
- **Insight**: `Critical: Backend pass creation failures (hourly)` (`aNidzB5S`)
- **Trigger**: hourly check; fire if `passCreationFailed` where `error_category = backend_error` exceeds 2
- **Purpose**: catch sustained backend generation failures

**Implementation notes**:
- `error_category` added to `passCreationFailed` payload in `PassMaker/Service/Analytics/AppEvent.swift`
- `PassEditorViewModel.swift` classifies errors:
  - validation path → `validation_error`
  - nil generation path → `generation_nil`
  - thrown runtime/backend path → `backend_error`

---

## Operating Guidance

- Keep both alerts enabled at all times
- If alert volume is too noisy, tune thresholds only after one full week of production data
- Do not rename `error_category` in event payloads — alerts depend on it

---

## Adding New Alerts

When adding new events that need monitoring:

1. Add event to `AppEvent` with descriptive `error_category` field if applicable
2. Create PostHog insight for the event
3. Create PostHog alert on the insight with appropriate threshold
4. Subscribe owning engineer/channel
5. Document in this file: event name, insight short ID, alert ID, subscribed users

---

## Checklist

Before marking production alerts as done for an app:

- [ ] At least one critical alert is configured for paywall / pro screen load failures
- [ ] At least one critical alert is configured for backend / core feature failures
- [ ] Alerts use a structured `error_category` field for threshold targeting
- [ ] Alert thresholds have been validated against one full week of production data
- [ ] Owning engineer or channel is subscribed to alert notifications
- [ ] Every alert is documented with event name, insight ID, alert ID, and subscribers
- [ ] Alert volume is reviewed monthly and tuned to reduce noise
