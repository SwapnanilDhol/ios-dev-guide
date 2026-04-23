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
