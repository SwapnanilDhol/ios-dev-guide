# Maestro iOS UI Automation

## Setup

Install Maestro from [macacaiOS/maestro](https://github.com/macacaiOS/maestro):
```bash
brew install maestro
```

## Basic Flow Structure

```yaml
appId: com.yourcompany.yourapp
---
- launchApp
- assertVisible: {id: "homeScreen"}
- tapOn: {id: "createPassButton"}
- assertVisible: {id: "passEditor"}
```

## Common Patterns

### Tap by text
```yaml
- tapOn: "Get Started"
```

### Input text
```yaml
- inputText: "my@email.com"
  into: "emailField"
```

### Screenshot
```yaml
- takeScreenshot: {path: "screenshots/onboarding_step1.png"}
```

### Conditional wait
```yaml
- waitForAnimationToEnd
- waitForElementToAppear: {id: "continueButton"}
```

## Debug Tips

- Run with `--verbose` for full element tree output
- Use `printHierarchy` to see current screen structure
- Maestro records flows interactively: `maestro record flow.yaml`

## CI Integration

Add to CI pipeline after archive step to validate critical flows before release.

---

## Checklist

Before marking Maestro UI automation as done:

- [ ] Maestro is installed (`brew install maestro`) and `maestro --version` works
- [ ] At least one critical user flow is automated (e.g., launch → home → create item)
- [ ] Flows use element IDs or stable text selectors (not brittle coordinates)
- [ ] `assertVisible` checks are included after navigation actions
- [ ] Screenshot steps are added for visual regression tracking
- [ ] Flows run successfully on the target simulator / device
- [ ] Maestro tests are integrated into CI and run after the archive step
