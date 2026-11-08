# Accountless App Attest and RevenueCat: Windfall decisions

Recorded 2026-09-08. Accepted product direction implemented and locally verified for Windfall in issue #128; not yet deployed or validated as the distributed TestFlight v2 binary. Other apps must explicitly choose their own identity assurance requirements. This note is an alternative to the purchase-binding model in app-attestation.md, not evidence that other implementations have changed.

- App Attest authenticates an installation; RevenueCat supplies the server-side Pro entitlement decision. Promotional Pro is legitimate without an Apple purchase JWS.
- An installation-to-RevenueCat mapping based on the ID supplied at first attested registration accepts a compromised-client first-claim risk. It prevents ordinary unauthenticated API calls but does not independently prove customer ownership. Binding the ID into a challenge proves the claim was signed, not that RevenueCat assigned that identity.
- Use attested keys, not a permanent hardware device ID. Reinstall, migration, and restore can require a new key. Anonymous RevenueCat IDs can also change. Restoring purchases recovers entitlement through RevenueCat policy without guaranteeing the same literal ID.
- Refresh customer state after restore and handle authenticated identity reconciliation explicitly. Never accept arbitrary per-request identity replacement. Verify alias/transfer behavior against the project's actual RevenueCat settings.
- Promotional-only access cannot be recovered from an Apple receipt that never existed. Windfall accepts support regranting it after anonymous identity loss; other apps may prefer account recovery.
- Preserve local functionality and valid cached sessions during outages. Use bounded retries; distinguish temporary provider failures from entitlement denial. Optional enforcement allows legacy access. Mandatory enforcement cannot promise successful remote requests without valid credentials, and must not silently fail open.
- A short-lived bearer can be replayed outside the app if stolen until expiration/revocation. App Attest is not a guarantee that every bearer-bearing request originated inside the app.
- Keep protected private data and stored OAuth connections behind independently justified ownership checks. Do not casually extend first-claim entitlement mapping to existing private customer resources.
- Release with observation first. Windfall's `off` plus shadow validation is the non-blocking stage; `optional_required` enforces on participating clients and is a different stage. Require adoption and real-device evidence before mandatory activation.
- Measure session success separately from entitlement success. Test free users, purchased Pro, promotional Pro, expired/revoked grants, restore/reinstall, identity mismatch, provider outages, and older clients. Installing a local Release build does not verify the TestFlight binary or guarantee TestFlight transaction availability.

## Implementation review lessons

- Reconcile identity with a fresh App Attest assertion, not an unrestricted bearer-only rebinding endpoint. Associate the one-time server challenge with the intended identity and protocol. This authenticates the installation's claim; it still does not independently prove RevenueCat customer ownership.
- Give bindings a generation and sessions an immutable identity/generation snapshot. Changing identity must revoke old authorization, including across an A→B→A cycle. A null session identity is meaningful; never replace it with the key's later identity when authenticating.
- A D1 batch is transactional, but a conditional UPDATE that affects zero rows is not an exception and does not roll back later statements. Gate every dependent mutation or use generation-checked issuance so a losing concurrent request cannot delete the winning session.
- Version only the cached bearer namespace when moving to a new session protocol. Keep the attestation key and enrollment metadata stable; apply bearer migration to staging and development origins too.
- Treat malformed successful RevenueCat responses as provider failures, not evidence that Pro expired. Do not cache an unexpected response schema as entitlement denial.
- Readiness means the installation-session path succeeded. Never label a mapping Apple-verified merely because the app's local Pro flag is true.

References: https://www.revenuecat.com/docs/customers/identifying-customers ; https://www.revenuecat.com/docs/projects/restore-behavior ; https://www.revenuecat.com/docs/dashboard-and-metrics/customer-profile ; https://developer.apple.com/documentation/DeviceCheck/establishing-your-app-s-integrity
