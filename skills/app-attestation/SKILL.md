---
name: app-attestation
description: Implement or review App Attest-backed authenticated sessions for iOS apps using SwapFoundationKit, SwapProKit, RevenueCat, and a backend Worker.
---

# App Attestation

Use this skill when adding or reviewing App Attest, authenticated backend sessions, RevenueCat purchase binding, or the rollout of those protections in an SFK-first iOS app.

Read [`../../stack/app-attestation.md`](../../stack/app-attestation.md) before changing code. It is the canonical implementation playbook and contains the ownership split, API contract, security model, configuration, rollout, and checklist.

## Operating rules

- Put App Attest mechanics in SwapFoundationKit and purchase-proof extraction in SwapProKit. Keep app-specific session and entitlement policy in the host app.
- Treat the bearer session as the credential. Never authorize from `X-App-User-ID` or client-side Pro state alone.
- Verify attestation, app ID, nonce, environment, assertion counter, token expiry, and RevenueCat transaction correlation on the server.
- Store App Attest keys and session tokens in device-only secure storage. Never log secrets, bearer tokens, attestation objects, or purchase JWS values.
- Keep development attestation isolated from production. Do not enable production enforcement until the updated app is released and real-device smoke tests pass.
- Avoid per-request assertions: enroll once, issue short-lived sessions, and refresh only near expiry or after purchase binding.
- Preserve existing users during rollout by deploying with `AUTH_ENFORCE_SESSIONS=false`, then enabling it in a separate deployment after adoption is acceptable.

## Workflow

1. Inspect the host's package revisions, bundle IDs, entitlements, API header provider, RevenueCat entitlement configuration, Worker config, and D1 migrations.
2. Check SwapFoundationKit capabilities before adding host-side primitives; check SwapProKit before reimplementing purchase proof extraction.
3. Implement the smallest host adapter needed for lifecycle orchestration and app-specific policy.
4. Add or update Worker auth routes, persistence, verifier configuration, and migration without changing unrelated endpoints.
5. Add tests for replay, expiry, identity mismatch, key rebind, assertion counter, and purchase-correlation failures.
6. Validate Worker typecheck/tests and an iOS Simulator build; validate App Attest and StoreKit behavior on a real device before enforcement.
7. Report the deployment order and whether enforcement is currently enabled. Do not deploy or merge unless the user explicitly asks.

## Required handoff

Summarize:

- which code belongs in SFK, SwapProKit, the host app, and the Worker;
- what secrets, entitlements, migrations, and bundle IDs are required;
- the current enforcement flag and safe rollout step;
- tests/builds run and any real-device validation still pending.

