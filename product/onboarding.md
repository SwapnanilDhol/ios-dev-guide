# Premium Onboarding Implementation Playbook

Canonical playbook for SFK-first SwiftUI apps in this kit. It is a product, design, motion, architecture, analytics, accessibility, testing, and rollout guide—not a source-code copy exercise.

Agent entry: [`../skills/premium-onboarding/SKILL.md`](../skills/premium-onboarding/SKILL.md). SFK primitives: `SwapFoundationKit/Docs/guides/onboarding.md` + `capabilities.yaml` `onboarding` domain.

The goal is an onboarding that:

- earns attention with a polished, tactile first impression;
- explains the product through believable examples instead of feature lists;
- gathers only the information required to personalize the app;
- keeps content, navigation, and safe areas visually consistent;
- behaves correctly for new, interrupted, returning, and debug users;
- can evolve without turning into a single unmaintainable view.

**Reference product:** Windfall (MoneyTracker). Section 2 and §27 use Windfall nouns as a worked example—change the nouns for your app; preserve the narrative shape. Host apps keep a short module map (e.g. `Docs/modules/onboarding.md`) for file paths and product-specific steps.

---

## 1. The experience in one sentence

Start with a focused brand moment, transition into a short sequence of personalized decisions and realistic product demonstrations, then finish with a clear handoff into the app.

Onboarding is not a settings form with nicer colors. It is a paced product story:

1. **Attract** — establish quality and the product promise.
2. **Personalize** — learn a small amount about the user.
3. **Validate** — show that the app understands their problem.
4. **Demonstrate** — use real product components with realistic data.
5. **Ask** — request permissions or upgrades only after value is visible.
6. **Deliver** — welcome the person by name and enter the configured app.

Every screen should have one communication goal and one obvious primary action.

---

## 2. Reference flow

Windfall currently uses the following setup sequence:

| Order | Step | Purpose | Interaction |
|---:|---|---|---|
| 0 | Marketing | Sell the product promise | Continue |
| 1 | Name | Personalize the experience | Text entry, confirmation morph |
| 2 | Goal | Learn the desired outcome | Single-select cards |
| 3 | Pain points | Learn what gets in the way | Multi-select cards |
| 4 | Social proof | Build confidence | Continue |
| 5 | Solution | Connect the pain to the product | Continue |
| 6 | Currency | Configure locale-sensitive examples | Visual single selection |
| 7 | Account | Introduce the account model | Add or defer |
| 8 | Processing | Pace the transition into a demo | Timed animation |
| 9 | Product demo | Let the user try a representative action | Conversational input |
| 10 | Notifications | Explain useful notifications before asking | Enable, test, or defer |
| 11 | Paywall | Present the product offer in context | Subscribe or continue |
| 12 | Completion | Confirm personalization and hand off | Get started |

Other apps should change the nouns, examples, and number of steps. Preserve the narrative shape.

### What to remove

Do not retain a screen because it existed in an older onboarding. Keep it only if it does at least one of these:

- changes app configuration;
- increases confidence;
- demonstrates a core behavior;
- prepares the user for a permission request;
- advances purchase intent;
- gives the sequence necessary pacing.

If it does none of these, remove it.

---

## 3. The visual contract

The strongest source of consistency is a shared layout contract, not duplicated padding values.

### 3.1 Screen regions

Treat a standard onboarding screen as three regions:

```text
┌──────────────────────────────────┐
│ status bar / segmented progress  │
├──────────────────────────────────┤
│                                  │
│ visual or interactive stage      │
│                                  │
│              flexible space      │
│                                  │
├──────────────────────────────────┤
│ eyebrow                          │
│ headline                         │
│ supporting copy                  │
├──────────────────────────────────┤
│ primary CTA                      │
│ optional secondary action        │
│ home-indicator safe area         │
└──────────────────────────────────┘
```

The visual stage receives most of the screen. In the opening experience, Windfall uses roughly 64% of the full-bleed height. On ordinary steps, the stage is flexible while the text naturally settles immediately above the footer.

The important rule is:

> Push the text block toward the bottom by default. Let unusually tall interactive content push it upward.

Do not vertically center the text in leftover space. That creates a large dead zone above the CTA and makes screens feel unrelated.

### 3.2 Visual/content separation

- The hero may extend behind the status bar.
- Text must never overlap the hero.
- The footer must remain pinned and predictable.
- A gradient may bridge a busy hero into the system background.
- Use the environment's system background and semantic foreground styles.
- Never force a black or white screen color merely because a reference image used that appearance.

Test every important screen in light and dark mode.

### 3.3 Typography

Windfall's authored scale is:

| Role | Reference treatment |
|---|---|
| Eyebrow | 12 pt, bold, rounded, approximately 1.6 tracking, accent |
| Headline | 37–38 pt, bold, rounded, approximately -1.2 tracking |
| Body | 17–18 pt, medium, rounded, secondary, 3–4 pt line spacing |
| Card title | Headline/semibold |
| Card body | Subheadline/secondary |

These exact sizes are not mandatory. The hierarchy is:

- eyebrow is brief and atmospheric;
- headline carries the promise;
- supporting copy explains it in one or two short sentences;
- rounded text is used consistently, including editable name text.

Use Dynamic Type-aware styles when the app's accessibility requirements outweigh fixed art-direction sizes. At minimum, set sensible line limits, scaling, and vertical growth behavior, then verify accessibility sizes.

### 3.4 Horizontal rhythm

Use one screen inset for text and footer content. Windfall uses 24 points for most setup content and 28 points for marketing copy. Cards must provide their own internal padding; do not rely on the parent's screen inset to make card text breathe.

Avoid:

- text touching a card's border;
- one-off negative padding;
- edge-to-edge controls inside an already padded parent;
- different CTA widths on adjacent screens without a deliberate reason.

---

## 4. Shared architecture

Use a small MVVM-C feature module:

```text
Onboarding/
├── Model/
│   ├── OnboardingPresentation.swift
│   ├── OnboardingScreen.swift
│   ├── OnboardingStep.swift
│   └── app-specific selection/demo models
├── Service/
│   └── WelcomeExperienceHaptics.swift
├── View/
│   ├── OnboardingView.swift
│   ├── OnboardingSetupView.swift
│   ├── OnboardingStepView.swift
│   ├── OnboardingFooterView.swift
│   ├── WelcomeExperienceView.swift
│   └── specialized step views
├── ViewModel/
│   ├── WelcomeExperienceViewModel.swift
│   ├── OnboardingViewModel.swift
│   └── OnboardingViewModel+Navigation.swift
├── OnboardingCoordinatorDelegate.swift
└── OnboardingPreviewSupport.swift
```

Keep each role narrow:

| Type | Responsibility |
|---|---|
| `OnboardingPresentation` | Why the flow is being presented and where it starts |
| `OnboardingScreen` | Marketing versus setup at the root level |
| `OnboardingStep` | Ordered setup states and analytics names |
| Root view | Transition between marketing and setup |
| Setup view | Progress, shared footer, step transitions, and shell geometry |
| Step view | Step-specific visuals and copy |
| Specialized views | Steps with independent permission, timing, or paywall behavior |
| View model | User selections, progression, persistence, and event emission |
| Coordinator | Full-screen presentation, external flows, and dismissal |
| Preview support | Explicit, compiling preview dependencies |

Do not place permission requests, persistence writes, analytics calls, or coordinator presentation logic in a SwiftUI `body`.

---

## 5. SwapFoundationKit boundary

Before recreating this in another app, check the version of SwapFoundationKit used by that app.

The correct decision for Windfall was **`wrap_sfk`**:

| Need | Decision |
|---|---|
| Segmented progress | Use `SFKSegmentedProgress` directly |
| Primary/secondary actions | Use `SFKButton` directly |
| Generic cards and rounded typography | Use or adapt SFK primitives |
| Glass content | Use `.sfkGlass(...)` directly |
| Basic impacts/notifications | Use `HapticsHelper` directly |
| Rich buildup/blast score | Wrap Core Haptics in an app-owned service |
| Settings debug row | Use SFK settings rows |
| Item-picker sheet | Use `SFKItemPickerView` when the interaction is a sheet/list |
| Inline visual currency stage | Keep app-owned; it is not a generic picker sheet |
| Product sequence/copy/examples | Keep app-owned |
| Launch routing and persistence | Keep app-owned |
| Analytics event meaning | Keep app-owned |
| Domain previews | Keep app-owned and reuse real app components |

SFK's onboarding primitives are tools, not a complete product flow. Do not use a chip merely because `SFKSelectableChip` exists. Windfall intentionally uses substantial selection cards because chips did not match the rest of the experience.

---

## 6. Model presentation intent separately from progress

Two users can see the same marketing screen for different reasons:

- a new user who should continue into setup;
- an existing user who missed a newly introduced one-time marketing screen and should dismiss after Continue.

A single `hasCompletedOnboarding` boolean cannot express this.

Use two independent persisted facts:

- `hasShownInitialMarketingScreen`
- `hasCompletedOnboarding`

Then resolve a presentation intent:

```swift
enum OnboardingPresentation: Equatable {
    case firstLaunch
    case returningUserMarketing
    case resumedSetup
    case debug
    case preview
}
```

### Required launch matrix

| Force | Marketing shown | Setup complete | Result |
|---|---:|---:|---|
| Yes | Any | Any | Full flow for automation |
| No | No | No | Marketing, then setup |
| No | No | Yes | Marketing only; Continue dismisses |
| No | Yes | No | Resume setup |
| No | Yes | Yes | Present nothing |

This matrix solves product migrations cleanly. A newly added marketing screen can reach existing users without sending them through setup again.

### When to persist

- Mark marketing as shown when it is actually displayed, not when Continue is tapped.
- Mark setup complete only after the final completion action succeeds.
- Persist configuration choices when completion commits the flow, unless a particular choice must affect an in-flow feature immediately.
- Never write completion on dismissal.

### Debug and preview

- Debug presentation should intentionally run the full flow.
- Preview presentation must not mutate persistence or emit production analytics.
- UI automation may force first-launch behavior through a launch argument.

Unit-test every row of the launch matrix.

---

## 7. Root navigation and coordinator ownership

Present onboarding full-screen from a coordinator. The coordinator owns:

- the hosting controller;
- presentation style;
- dismissal;
- account-entry, paywall, settings, or other external flows;
- the typed completion delegate.

Use a typed delegate:

```swift
@MainActor
protocol OnboardingCoordinatorDelegate: AnyObject {
    func onboardingDidComplete()
    func onboardingDidRequestDismissal()
}
```

The root view owns a welcome view model whose `screen` is either marketing or setup. When Continue is tapped:

- `.firstLaunch`, `.debug`, and `.preview` transition into setup;
- `.returningUserMarketing` asks the coordinator to dismiss;
- `.resumedSetup` starts directly in setup.

Use an asymmetric move-plus-opacity transition for the marketing-to-setup handoff. This transition must be applied at the root boundary. If it is applied only inside the setup pager, every later screen will animate while the first transition appears broken.

Reference motion:

```swift
let animation = reduceMotion
    ? Animation.easeOut(duration: 0.2)
    : Animation.spring(
        response: 0.48,
        dampingFraction: 0.76,
        blendDuration: 0.08
    )
```

### 7.1 Dismiss the full-screen surface as one layer

A full-screen SwiftUI onboarding can contain continuously rendered content such as
`TimelineView`, `Canvas`, animated materials, or UIKit-backed previews. During an
interactive-looking UIKit dismissal, those live render layers can update one frame
after the hosting controller starts moving. The result is a transparent-looking
sheet: the background moves away while cards, text, or tiles appear to remain over
the destination until the next render pass.

Treat presentation opacity and dismissal integrity as coordinator responsibilities:

1. Present a dedicated hosting controller with `.fullScreen`.
2. Give the controller view an explicit semantic background and set `isOpaque = true`.
3. Route every exit path through one coordinator/host method. Do not let an animated
   child view call `@Environment(\.dismiss)` directly in production.
4. Immediately before dismissal, lay out the host, snapshot its complete view, add
   the snapshot above the live SwiftUI hierarchy, and hide the live subviews.
5. Ask UIKit to dismiss the hosting controller normally. UIKit now animates one
   stable bitmap surface instead of independently updating SwiftUI render layers.
6. Keep a weak presentation bridge so the SwiftUI root can request this behavior
   without owning its hosting controller. Retain environment dismissal only as a
   preview or non-UIKit fallback.

Reference shape:

```swift
@MainActor
final class OnboardingHostingController<Content: View>: UIHostingController<Content> {
    private var isDismissingAsSingleLayer = false

    func dismissAsSingleLayer() {
        guard !isDismissingAsSingleLayer else { return }
        isDismissingAsSingleLayer = true

        view.layoutIfNeeded()
        let liveSubviews = view.subviews

        if let snapshot = view.snapshotView(afterScreenUpdates: false) {
            snapshot.frame = view.bounds
            snapshot.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            snapshot.isUserInteractionEnabled = false
            snapshot.accessibilityElementsHidden = true

            UIView.performWithoutAnimation {
                view.addSubview(snapshot)
                liveSubviews.forEach { $0.isHidden = true }
            }
        }

        dismiss(animated: true)
    }
}
```

Do not try to solve this with `.drawingGroup()`, `.compositingGroup()`, or a second
SwiftUI exit animation. Those can change rendering cost or create competing motion,
but they do not guarantee that UIKit dismisses the modal as one visual surface.

---

## 8. Setup shell and footer

The setup shell should own:

- the segmented progress indicator;
- the current step view;
- page transition;
- shared primary and secondary CTA state;
- bottom safe-area geometry.

### 8.1 State-driven CTA

Derive footer behavior from the step enum with computed properties:

```swift
private var primaryCTATitle: String {
    switch viewModel.currentStep {
    case .solution:
        return "Almost there"
    case .addAccount:
        return "Add account"
    case .completion:
        return "Get started"
    default:
        return "Continue"
    }
}

private var isPrimaryEnabled: Bool {
    switch viewModel.currentStep {
    case .name:
        return !viewModel.trimmedName.isEmpty
    case .goal:
        return viewModel.selectedGoal != nil
    case .painPoints:
        return !viewModel.selectedPainPoints.isEmpty
    case .demo:
        return viewModel.demoCompleted
    default:
        return true
    }
}
```

Keep titles, identifiers, enabled state, optional secondary action, and action routing together. Do not scatter step comparisons through `body`.

### 8.2 Bottom action bar contract

The CTA must:

- be pinned with `safeAreaInset(edge: .bottom)`;
- use the app's shared bottom action container;
- extend its container through the bottom safe area;
- have a **clear** background for this onboarding style;
- use the design-system button;
- expose stable accessibility identifiers;
- use compact vertical padding.

In Windfall, `OnboardingFooterView` wraps `AppBottomActionFooter` with:

- 24-point horizontal padding;
- 12-point default top padding;
- 10-point bottom content padding;
- `showsMaterialBackground: false`.

The outer screen ignores the container safe area at the bottom so the footer reaches the physical edge. The footer itself receives the measured bottom inset and keeps controls above the home indicator.

These are two different responsibilities:

1. background reaches the edge;
2. interactive content respects the inset.

Confusing them creates a floating strip, a mismatched background, or a button under the home indicator.

### 8.3 Shared versus specialized footers

Most steps use the setup shell's footer. A specialized step may own its footer when its action state is independent, such as:

- notification authorization;
- paywall purchase state;
- a timed processing transition.

Never render both the shell footer and a specialized footer. Define a computed `stepOwnsFooter` switch and make the choice explicit.

### 8.4 No mid-flow escape

The standalone marketing screen may expose a close action for a returning user. Once first-run setup begins, do not show close buttons unless the product explicitly supports abandoning setup.

This prevents half-configured states and makes the contract honest.

---

## 9. Scroll and keyboard policy

Do not wrap every step in a `ScrollView`.

Use a per-step policy:

```swift
var usesScrolling: Bool {
    switch step {
    case .name, .goal, .painPoints, .currency, .demo:
        return true
    case .socialProof, .solution, .account, .completion:
        return false
    }
}
```

The exact list depends on the app and supported device sizes.

### Scroll behavior

- Scroll content must be able to reach the top edge beneath the fixed progress chrome.
- Do not clip it with an extra frame that starts below the progress indicator.
- Place the fixed indicator in the shell and let the step's scroll view own the remaining region.
- Avoid accidental rubber-banding on short, non-scrolling screens.
- Test on the smallest supported device and with an accessibility text size.

### Keyboard behavior

The name screen is the highest-risk layout because the keyboard reduces available height.

- Put the editable region in a scroll-capable step.
- Keep the CTA in the bottom action inset so the system can move it with the keyboard.
- Do not calculate hero height once from the original full-screen height and then reuse it after keyboard presentation.
- Use `ScrollViewReader` or focus-driven scrolling when the field can still be obscured.
- Test empty, one-line, long, and whitespace-only input.
- Keep the field's font rounded medium to match the rest of the onboarding.
- Dismiss or transfer focus before a page transition if it avoids a keyboard/layout race.

---

## 10. Opening marketing animation

### 10.1 Composition

Windfall's opening screen uses:

- a full-bleed system background;
- a large top icon stage;
- a charging orb at the stage center;
- a stable catalog of colored icon tiles;
- a bottom gradient that protects copy legibility;
- marketing copy immediately above the clear footer.

The icon stage is approximately:

```swift
stageHeight = fullBleedHeight * 0.64
stageCenterY = stageHeight * 0.46
```

Measure the full-bleed height as the geometry height plus top and bottom safe-area insets, then apply `.ignoresSafeArea()` to the outer composition. This lets the art reach the top while keeping footer content correctly inset.

### 10.2 Stable tile geometry

Every tile should have immutable authored data:

```swift
struct WelcomeItem: Identifiable {
    let id: String
    let systemImage: String
    let color: Color
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let rotation: Double
    let driftX: CGFloat
    let driftY: CGFloat
    let driftSpeed: Double
    let driftPhase: Double
    let revealDelay: Double
}
```

`x` and `y` are normalized final positions. Before the burst, every tile is rendered at the same center position. The animation changes only offset, scale, rotation, and opacity.

This prevents the blast jerk and placement flicker caused by:

- replacing one view hierarchy with another;
- generating random positions during render;
- changing IDs;
- changing frame alignment at the phase boundary;
- starting ambient drift before the burst has settled.

Use stable IDs and the same view instance throughout the animation.

### 10.3 Motion phases

Model the animation as an enum:

```swift
enum WelcomePhase {
    case dormant
    case charging
    case bursting
    case settled
}
```

Reference timing:

| Time | Phase | Visual | Haptic |
|---:|---|---|---|
| 0 ms | Dormant | Center orb, tiles hidden | Prepare engine |
| 180 ms | Charging | Orb pulses and emits ring | Buildup begins |
| 1,020 ms | Bursting | Tiles spring to final positions | Blast |
| 1,520 ms | Settled | Ambient drift blends in | Optional fallback tick |

Use a cancellable `Task`, cancel it on disappear, and stop haptic players. Never let delayed transitions fire after dismissal.

### 10.4 Burst animation

Reference spring:

```swift
.spring(
    response: 0.58,
    dampingFraction: 0.82,
    blendDuration: 0.08
)
```

Stagger tiles very lightly. The burst should read as one event, not a sequential parade. Windfall multiplies authored reveal delays by `0.42` before applying them.

### 10.5 Ambient movement

After settlement, use low-amplitude deterministic sine/cosine drift:

```swift
width  = sin(time + phase) * driftX * blend
height = cos(time * 0.82 + phase) * driftY * blend
```

Blend ambient motion in over roughly 0.8 seconds. Starting it instantly changes the final burst target while the spring is still moving and creates a visible hitch.

Use a `TimelineView` at about 30 fps. The motion should be almost subliminal, not a screensaver.

### 10.6 Reduce Motion

When Reduce Motion is enabled:

- skip charging and burst travel;
- move directly to the settled composition;
- disable ambient drift;
- use short opacity transitions;
- avoid rich haptic choreography coupled to removed motion.

The screen must still look intentionally composed in its static state.

---

## 11. Haptic score

Haptics should describe the same physical story as the motion:

1. energy gathers;
2. pressure peaks;
3. the system releases;
4. a few small fragments settle.

### Rich pattern

Windfall uses Core Haptics:

- a 0.76-second low-sharpness continuous event;
- increasingly strong transients around 0.18, 0.38, 0.55, 0.67, and 0.75 seconds;
- an intensity curve that rises from about 0.24 to 0.92;
- a blast with a strong soft transient and sharp transient together;
- three diminishing settling transients around 0.20, 0.275, and 0.345 seconds.

The buildup and blast are separate players so they can be cancelled safely.

### Fallback

Core Haptics is not universally available. Fall back to:

- light impact at charge;
- heavy impact at burst;
- light impact at settle.

Prepare generators before the moment they are needed. Do not stack unrelated button haptics on top of the animation score.

### Timed progress and staged card reveals

Short processing interstitials may use a restrained rising pulse sequence—typically
three or four impacts spaced roughly 350–500 ms apart—to communicate ongoing work.
The impacts should become slightly stronger as progress advances, then stop before
navigation. This is authored pacing, not a render-driven progress callback.

When multiple cards split, fan, or spring out of one composition, model the reveal
as an integer phase (or equivalent enum). Advance one phase per card and fire that
card's subtle impact in the same cancellable task immediately before changing the
phase. Do not trigger haptics from `body`, per-frame animation values, or generic
`onChange` observers; SwiftUI recomputation must not replay the sequence.

Use `.task` or an explicitly owned `Task`, handle cancellation from every sleep,
and keep delayed haptics from surviving dismissal. Reduce Motion should collapse
the choreography to one stack impact or a shorter, quieter progress sequence.

### Design test

Test the score on a physical device. Simulator behavior cannot validate haptic quality. If the pattern feels buzzy, reduce transient count before reducing the main blast; a clear physical sentence is better than constant vibration.

---

## 12. Page transitions and micro-interactions

### Setup paging

Reference:

```swift
.asymmetric(
    insertion: .move(edge: .trailing).combined(with: .opacity),
    removal: .move(edge: .leading).combined(with: .opacity)
)
```

Use a spring around response `0.5`, damping `0.76`, blend `0.08`. Key the step container by the step identity so SwiftUI knows it changed.

Reduce Motion uses a 0.2-second opacity transition.

### Name confirmation

A small personalized payoff improves the name step:

1. user enters a non-empty trimmed name;
2. tapping Continue morphs the full-width CTA into a centered checkmark;
3. display “Welcome, Name” or equivalent confirmation;
4. advance after a short beat.

Use `matchedGeometryEffect` between the full-width CTA and confirmation button. Windfall uses a response `0.28`, damping `0.82` spring for the morph and a cancellable delayed advance.

Do not make the user tap through an entire extra screen unless the welcome message adds meaningful value. A brief in-place confirmation keeps momentum.

---

## 13. Selection screen design

Use cards when choices are meaningful product statements. Chips are appropriate for compact tags, filters, and dense optional attributes—not for every selection interface.

A good onboarding selection card includes:

- a recognizable icon or compact illustration;
- a short title;
- optional one-line supporting copy;
- a clear selected state using fill, border, icon, and/or checkmark;
- comfortable internal padding;
- a full-card hit target;
- an accessibility label and selected trait.

Do not add “Select one to continue” under every question. The disabled CTA and visible selection affordance should communicate the requirement. Add helper copy only when the interaction is genuinely ambiguous.

For multi-select:

- show that multiple cards can remain selected;
- avoid excessive haptics;
- keep the CTA disabled until the minimum valid count is reached;
- track stable option IDs, not localized display strings.

---

## 14. Currency and locale personalization

The currency screen must represent the actual supported set, not an arbitrary shortlist.

### Presentation

- Place the selected currency in the visual center at the largest scale.
- Arrange a small number of other currencies around it as decorative satellites.
- Provide access to every supported currency in the selectable region.
- Sort or group predictably.
- Update all later monetary examples immediately.

The selected value belongs in the middle because it has maximum visual attention. Do not show one currency in the hero while another is actually selected.

### Data

Model currencies with:

- stable code;
- localized name;
- symbol;
- formatting behavior;
- decimal rules if they differ;
- optional locale/market metadata.

Later account balances, transaction prompts, notification previews, and paywall examples should all read from the selected currency. Do not duplicate hard-coded `$` or `₹` strings.

### Picker choice

Use an inline authored grid when the screen is itself a visual onboarding moment. Use `SFKItemPickerView` if selection occurs in a modal searchable list. Do not force a modal component into an inline composition.

---

## 15. Demonstrate the real product

The best onboarding preview is a real production component populated with safe demo data.

For Windfall's transaction demo:

- the user enters natural language;
- the conversation appears from the bottom like a messaging exchange;
- a redacted production `TransactionRowView` occupies the final layout while parsing;
- the completed transaction uses the exact same row component as Home;
- merchant logo, merchant name, amount, account, and category are believable;
- the card receives the onboarding's glass treatment without rewriting its internals.

This is superior to a custom “transaction ready” card because:

- users learn the actual product;
- onboarding cannot drift as far from Home;
- loading and result geometry remain stable;
- design improvements to the shared row benefit both surfaces.

### Loading

Use redaction in place:

```swift
TransactionRowView(transaction: placeholder)
    .redacted(reason: .placeholder)
```

The placeholder must have stable identity and approximately the same content geometry as the result. Avoid a giant colored loading block that disappears into a differently sized card.

### Natural prompts

Do not make every example “I spent X at Y.” Build a prompt catalog with varied human phrasing:

- “Coffee and a sandwich at Blue Bottle, 18.40”
- “Paid the electricity bill—92”
- “Uber home was 24 bucks”
- “Got 2,300 from payroll today”
- “Split dinner with Maya, my share was 36”
- “Annual domain renewal, 14.99 on the work card”

Localize merchant types, number formatting, currency, and conversational phrasing. Keep the parser input examples diverse enough to communicate flexibility, not just syntax.

---

## 16. Notification permission screen

Permission screens must show value before the system prompt.

### Visual

Use compact, vertically stacked cards resembling current iOS notifications:

- real app icon;
- user-facing app name from the bundle;
- relative time;
- concise title;
- one- or two-line body;
- rounded glass material;
- modest 8–11 point internal padding;
- subtle shadow.

Do not create a horizontal carousel. Notifications arrive as a vertical stack. Windfall begins all cards at the center, then bursts them to upper, center, and lower offsets with small rotations and a lightly staggered spring.

Give the reveal an explicit phase per card. Fire one subtle, increasing impact as
each card begins moving, keeping visual and tactile timing in the same cancellable
task. With Reduce Motion, reveal the static stack with at most one impact.

### Content

Use notification types the app can actually send. Inspect the app's notification service and reuse its categories and tone. Examples include:

- an unusual-spend alert;
- budget pace;
- a weekly summary;
- a savings milestone;
- a missing-entry reminder.

Every amount must use the selected currency.

### Permission state

Drive CTA behavior from a finite permission enum:

| State | Primary | Secondary |
|---|---|---|
| Unknown/not determined | Enable notifications | I'll enable this later |
| Enabled | Send test notification | Continue |
| Denied | Open Settings | I'll enable this later |

Refresh state when the scene becomes active so returning from Settings updates the UI.

---

## 17. Specialized steps

### Processing

A processing step is pacing, not a fake claim. Use it only when the pause helps connect configuration to demonstration.

- Keep it brief; Windfall uses about 2.4 seconds.
- Make the sequence cancellable.
- Advance exactly once.
- Use restrained rings, progress, or redacted product UI.
- A few rising impacts may reinforce visible progress; space them deliberately and
  stop them before the navigation transition.
- Drive the pulse schedule from one cancellable task, never from render updates.
- Never block the main actor with synchronous work.

### Account preview

Reflect the selected currency in balances. Use plausible account names and the product's actual visual language. The “Add account” action may present the existing account-entry coordinator; the secondary action may defer.

### Paywall

The paywall may own its footer because purchase state changes CTA semantics. Keep entitlement and purchase orchestration outside the view. Track offer viewed, selected, purchased, restored, skipped, and failed with non-sensitive metadata.

### Completion

Default the text block to immediately above the CTA. Personalize the headline with the trimmed name when available. This is the handoff, not another explainer screen.

---

## 18. View-model state and navigation

The view model should own:

- current step;
- name and confirmation phase;
- goal and pain-point selections;
- selected currency;
- demo input, parse phase, and result;
- deduplicated viewed-step tracking;
- presentation analytics source;
- completion persistence.

Use `OnboardingStep` as the single source of order. Sequential raw values are acceptable for a strictly linear flow, but transitions with branching should use an explicit next-step switch.

Every delayed or asynchronous operation must:

- use `async`/`await`;
- live outside `body`;
- be cancellable;
- check `Task.isCancelled`;
- avoid advancing after the view disappears;
- mutate UI state on the main actor.

### Required validation

Trim user-entered text. CTA validity should be a computed property, not duplicated conditions. Disabled actions use reduced opacity, muted title treatment where appropriate, and no haptic feedback.

---

## 19. Analytics specification

Instrument the funnel before rollout.

### Core event taxonomy

| Event | Required properties |
|---|---|
| `onboarding_marketing_viewed` | `source`, `continues_into_setup` |
| `onboarding_marketing_completed` | `source`, `action` |
| `onboarding_started` | `source` |
| `onboarding_step_viewed` | `step`, `source` |
| `onboarding_step_completed` | `step`, `action`, `source` |
| `onboarding_selection_changed` | `step`, `selection`, `source` |
| `onboarding_completed` | `source` |

Recommended source values:

- `first_launch`
- `returning_user_marketing`
- `resumed_setup`
- `settings_debug`
- `preview`

### Rules

- Log a step view once per presentation, not on every body refresh.
- Use stable English machine IDs for steps and selections.
- Never send the user's name, free-form transaction text, merchant text they entered, or other PII.
- Log completion action separately from selection changes.
- Distinguish defer/skip from Continue.
- Do not emit preview analytics.
- Ensure a returning-user marketing-only view does not count as a new onboarding start.

### Funnel questions

The events should answer:

- How many users see the marketing screen?
- How many continue versus close?
- Where does setup lose users?
- Which goals and pain points are common?
- Which permission states convert?
- Does the demo increase completion?
- How many interrupted users resume and finish?
- Does a paywall placement help or hurt completion?

---

## 20. Accessibility

Accessibility is a parallel design mode, not a late audit.

### Reduce Motion

- opening stage settles without travel;
- ambient drift is disabled;
- page transitions crossfade;
- CTA morph uses a short fade/scale;
- notification burst becomes a static stack or short fade;
- staged notification haptics collapse to at most one impact;
- processing haptics use a shorter, quieter sequence;
- timed steps remain understandable.

### VoiceOver

- Hide decorative icon clouds.
- Give each selectable card one coherent label and selected trait.
- Make progress expose current and total steps.
- Give icon-only confirmation and close controls explicit labels.
- Do not read redacted placeholders as real data.
- Announce important state changes such as parsed result or name confirmation when necessary.

### Dynamic Type

- Test the largest accessibility size.
- Let copy grow vertically.
- Ensure CTA text remains legible.
- Allow eligible steps to scroll.
- Avoid fixed-height text containers.
- Consider alternate layouts for dense hero content.

### Other

- Maintain sufficient contrast in both appearances.
- Do not communicate selection only by color.
- Keep touch targets at least 44×44 points.
- Verify keyboard navigation and Switch Control if the product requires them.

---

## 21. Localization and branding

- SwiftUI string literals use implicit localization.
- APIs taking `String`, including `SFKButton`, receive localized strings.
- Resolve the user-facing app name from the bundle; do not hard-code the engineering target name.
- Localize sample notification and demo language.
- Format money with the selected currency.
- Test German, Spanish, Japanese, Simplified Chinese, and Traditional Chinese in Windfall; adapt the language matrix in other apps.
- Test right-to-left layout when supported, particularly move transitions, icon direction, and card alignment.
- Avoid baking text into generated artwork.

Copy should be concise enough to survive translation. A two-line English headline may become three or four lines elsewhere.

---

## 22. Preview and test strategy

### Compiling previews

Every view must have an explicit preview dependency graph through an `OnboardingPreviewSupport` factory. Provide:

- light and dark marketing previews;
- representative selection states;
- notification permission states;
- loading and completed demo states;
- small and large device previews;
- Reduce Motion where practical.

Do not add parameterless production view-model initializers that fabricate coordinators.

### Unit tests

At minimum:

- every launch-matrix combination;
- next-step navigation;
- validation for required selections;
- completion persistence;
- currency propagation into examples;
- analytics deduplication;
- preview/debug persistence behavior.

Use Swift Testing for new tests.

### UI tests

Give every CTA and important choice a stable accessibility identifier. Cover:

1. force first launch;
2. marketing Continue transitions to name;
3. name input with keyboard visible;
4. required selections gate Continue;
5. currency changes later examples;
6. demo placeholder becomes a real production card;
7. notification defer path;
8. final completion dismisses;
9. returning marketing-only Continue dismisses;
10. debug Settings row presents the same production flow.

### Visual verification matrix

Capture screenshots for:

| Dimension | Cases |
|---|---|
| Device | smallest supported, standard, largest |
| Appearance | light, dark |
| Text size | default, largest accessibility |
| Motion | normal, Reduce Motion |
| Keyboard | hidden, shown |
| Safe area | home-indicator device, alternate simulator |
| Locale | short Latin, long Latin, CJK, RTL if supported |
| State | empty, selected, loading, success, denied permission |

### Physical-device verification

Simulator screenshots are insufficient for:

- haptic timing and intensity;
- keyboard animation races;
- ProMotion smoothness;
- real notification authorization;
- system Settings round-trip;
- purchase sheet behavior.

---

## 23. Common failure modes

### Hero overlaps text

Cause: hero and content are independently positioned in one unconstrained overlay.

Fix: give the hero a bounded stage and place text in a separate bottom region.

### Hero does not reach the top

Cause: safe-area ignoring is applied to a child background instead of the full composition, or full-bleed height excludes insets.

Fix: measure insets, calculate full height, and ignore safe areas at the outer container.

### Wrong background in light mode

Cause: hard-coded black/white fills or material tint.

Fix: use `Color(.systemBackground)`, `.primary`, `.secondary`, and restrained semantic tint.

### Footer floats above the bottom

Cause: the footer respects the safe area as a whole rather than extending its background through it.

Fix: outer container reaches the edge; footer content separately adds the bottom inset.

### Footer has a mismatched strip

Cause: material or secondary background is applied by a generic bottom container.

Fix: expose a clear-background mode and use it for onboarding.

### Burst jerks or flickers

Cause: two hierarchies, unstable IDs, random coordinates, or ambient drift starting during the spring.

Fix: render stable items once, animate transforms, and blend ambient motion after settlement.

### First transition does not animate

Cause: only the setup step container has a transition.

Fix: animate the root marketing/setup screen boundary too.

### Text floats in the middle

Cause: flexible space is below the text instead of above it.

Fix: visual stage, then `Spacer`, then copy, then footer.

### Keyboard destroys the name screen

Cause: fixed hero height and no scroll-capable content.

Fix: keyboard-aware geometry, scrolling for the name step, and a safe-area-inset footer.

### Onboarding cards look unrelated

Cause: chips or hand-built rows were selected for implementation convenience.

Fix: use the same substantial card grammar across meaningful choices.

### Demo card looks fake

Cause: onboarding duplicates a production component.

Fix: use the real component with demo data and a redacted placeholder.

### Notifications look unlike iOS

Cause: oversized padding, generic promotional cards, or horizontal scrolling.

Fix: compact notification anatomy, glass material, vertical stacking, real app icon and service copy.

### Existing users repeat onboarding

Cause: marketing impression and setup completion share one flag.

Fix: store independent facts and resolve a presentation intent.

### Content remains after the modal starts dismissing

Cause: continuously rendered SwiftUI layers update independently while UIKit moves
the hosting controller, or a child view bypasses the coordinator with environment
dismissal.

Fix: use the single-layer hosting-controller dismissal pattern in §7.1 and route
every production exit through it.

---

## 24. Recommended implementation order

Build in this order so foundational mistakes do not spread:

### Phase 1 — Product map

1. Write the narrative sequence.
2. State the purpose and success condition for each screen.
3. Remove unnecessary steps.
4. Define required versus optional interactions.
5. Draft realistic demo and notification content.

### Phase 2 — State and routing

1. Add presentation intent.
2. Add independent persistence flags.
3. Define ordered setup steps.
4. Implement the launch resolver and unit tests.
5. Add typed coordinator presentation and dismissal.

### Phase 3 — Shared shell

1. Build root marketing/setup transition.
2. Add progress.
3. Add the bottom-safe-area footer.
4. Add enum-driven CTA state.
5. Add per-step scroll policy.
6. Verify light/dark, top, bottom, and keyboard geometry before styling every step.

### Phase 4 — Static screens

1. Create shared copy hierarchy.
2. Create selection-card grammar.
3. Build personalization screens.
4. Build completion.
5. Connect selected values to later examples.

### Phase 5 — Real product previews

1. Reuse production components.
2. Add stable demo models.
3. Add redacted loading in place.
4. Create varied natural-language examples.
5. Create realistic notification previews from the app service.

### Phase 6 — Motion and haptics

1. Implement stable opening geometry.
2. Add phase-based animation.
3. Add page transitions at both navigation layers.
4. Blend ambient motion.
5. Add Core Haptics and fallback.
6. Synchronize processing pulses and staged-card impacts with explicit phases.
7. Add Reduce Motion behavior.
8. Test on device.

### Phase 7 — Instrumentation and rollout

1. Add funnel events.
2. Add accessibility identifiers.
3. Add previews and automated tests.
4. Run the visual matrix.
5. Remove the old onboarding.
6. Rename the new implementation to the canonical module name.
7. Route launch and Settings debug presentation through the same coordinator API.
8. Build and test the entire app.

---

## 25. Migration checklist for another app

Copy the architecture, not Windfall's finance content.

### Product

- [ ] What single promise should the opening screen sell?
- [ ] What is the smallest useful personalization set?
- [ ] Which real product interaction can be demonstrated?
- [ ] Which permission needs value framing?
- [ ] Is monetization appropriate inside onboarding?
- [ ] What is the personalized completion message?

### Design

- [ ] Hero uses about 55–65% of full-bleed height where appropriate.
- [ ] Text defaults to immediately above the CTA.
- [ ] Hero and text never overlap.
- [ ] System colors work in light and dark mode.
- [ ] Cards share one visual grammar.
- [ ] Footer is clear and reaches the bottom edge.
- [ ] Top artwork reaches behind the status bar.
- [ ] Selected currency/locale is visually central.

### Engineering

- [ ] Presentation intent is separate from setup step.
- [ ] Marketing shown and onboarding complete are separate flags.
- [ ] Launch matrix is tested.
- [ ] Coordinator owns presentation and dismissal.
- [ ] Full-screen host is opaque and all exits use single-layer dismissal.
- [ ] Setup uses enum-driven CTA state.
- [ ] Only steps that need scrolling scroll.
- [ ] Async sequences are cancellable.
- [ ] Real product components are reused.
- [ ] Stable demo IDs prevent flicker.
- [ ] Preview dependencies are explicit.

### Motion

- [ ] Opening phases are modeled explicitly.
- [ ] Burst uses stable geometry.
- [ ] Ambient motion begins after settlement.
- [ ] Root and setup page transitions both animate.
- [ ] Haptic score matches visual timing.
- [ ] Timed progress and staged-card haptics are task-driven and cancellable.
- [ ] SwiftUI recomputation cannot replay entrance haptics.
- [ ] Fallback haptics exist.
- [ ] Reduce Motion has an intentional static design.

### Analytics and privacy

- [ ] Marketing and setup funnels are distinguishable.
- [ ] Steps use stable analytics IDs.
- [ ] Views are deduplicated.
- [ ] Skip/defer actions are explicit.
- [ ] No names or free-form text are sent.
- [ ] Preview does not emit production events.

### QA

- [ ] Smallest and largest devices pass.
- [ ] Light and dark modes pass.
- [ ] Keyboard presentation passes.
- [ ] Dynamic Type passes.
- [ ] All supported locales pass.
- [ ] Notification states pass.
- [ ] Physical-device haptics pass.
- [ ] Clean install, interrupted setup, returning user, and debug entry pass.
- [ ] Frame-by-frame dismissal shows one full-width surface with no orphaned content.
- [ ] Full app build succeeds.

---

## 26. Definition of done

The onboarding is ready only when:

- the opening animation is stable with no visible placement jump;
- the haptic score feels deliberate on a physical device;
- every screen has a clear visual stage, bottom copy, and consistent CTA relationship;
- artwork reaches the top and the footer reaches the bottom correctly;
- light and dark mode use semantic colors;
- the name screen survives keyboard presentation;
- selected personalization affects later screens;
- demo UI reuses production components;
- permission previews resemble the real system surface and use realistic app-owned content;
- setup has no accidental escape route;
- every launch state resolves correctly;
- analytics can reconstruct the funnel without collecting PII;
- Reduce Motion, VoiceOver, and Dynamic Type are usable;
- the old flow and duplicate debug entry are removed;
- the production coordinator is the single presentation path;
- the full-screen host dismisses as one opaque layer with no cards, text, or animated
  tiles surviving into a later render pass;
- tests pass and the app builds successfully.

---

## 27. Windfall reference map

Use these files as production examples while adapting the playbook:

| Concern | Reference |
|---|---|
| Launch resolver | `Modules/Onboarding/Model/OnboardingPresentation.swift` |
| Root marketing/setup transition | `Modules/Onboarding/View/OnboardingView.swift` |
| Setup shell and CTA state | `Modules/Onboarding/View/OnboardingSetupView.swift` |
| Shared footer | `Modules/Onboarding/View/OnboardingFooterView.swift` |
| Opening layout and burst | `Modules/Onboarding/View/WelcomeExperienceView.swift` |
| Stable tile catalog | `Modules/Onboarding/Model/WelcomeExperienceItem.swift` |
| Motion sequence | `Modules/Onboarding/ViewModel/WelcomeExperienceViewModel.swift` |
| Rich haptics | `Modules/Onboarding/Service/WelcomeExperienceHaptics.swift` |
| Step routing and scroll policy | `Modules/Onboarding/View/OnboardingStepView.swift` |
| Focused standard step designs | `Modules/Onboarding/View/Onboarding*StepView.swift` |
| Notifications | `Modules/Onboarding/View/OnboardingNotificationsView.swift` |
| Processing | `Modules/Onboarding/View/OnboardingProcessingView.swift` |
| Paywall | `Modules/Onboarding/View/OnboardingPaywallView.swift` |
| State and persistence | `Modules/Onboarding/ViewModel/OnboardingViewModel.swift` |
| Navigation | `Modules/Onboarding/ViewModel/OnboardingViewModel+Navigation.swift` |
| Coordinator presentation | `Modules/Settings/SettingsCoordinator.swift` |
| App launch integration | `App/SceneDelegate.swift` |
| Analytics events | `Service/Analytics/Model/AnalyticsEvent.swift` |
| Launch-state tests | `MoneyTrackerTests/OnboardingPresentationTests.swift` |

The reusable principle is consistent throughout: share infrastructure and product components, but let each app author its own story.

---

**Last updated:** 2026-07-26
