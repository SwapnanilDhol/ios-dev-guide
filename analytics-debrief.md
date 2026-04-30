# Daily/Weekly Debrief Format

Run daily or weekly reports using this format. Pull data from PostHog MCP.

---

## Report Structure

### 1. Topline Metrics

- active users
- pass creation started / completed / failed
- checkout started
- purchases completed / failed

### 2. Funnel Health

- onboardingStarted → onboardingCompleted
- onboardingCompleted → onboardingPaywallViewed
- onboardingPaywallViewed → checkoutStarted
- checkoutStarted → purchaseDidComplete

### 3. AI and Product Usage

- aiPromptAnalysisStarted / Completed / Failed
- aiImageAnalysisStarted / Completed / Failed
- AI completion to pass creation completion linkage

### 4. What's Going Well
### 5. What's Not Going Well
### 6. Biggest Current Risk
### 7. One Operational Priority for Next Period

---

## KPI Formulas

- Onboarding Completion Rate = `onboardingCompleted / onboardingStarted`
- Paywall Exposure Rate = `onboardingPaywallViewed / onboardingCompleted`
- Checkout Intent Rate = `checkoutStarted / onboardingPaywallViewed`
- Purchase Conversion Rate = `purchaseDidComplete / checkoutStarted`
- Pass Creation Success Rate = `passCreationCompleted / passCreationStarted`
- Pass Creation Failure Rate = `passCreationFailed / passCreationStarted`
- AI Prompt Completion Rate = `aiPromptAnalysisCompleted / aiPromptAnalysisStarted`
- AI Image Completion Rate = `aiImageAnalysisCompleted / aiImageAnalysisStarted`
- AI Adoption Rate = users with AI start event / active users

---

## Interpretation Rules

- If checkout intent is low, paywall clarity/value communication is weak
- If checkout intent is high and purchase completion is low, billing/store/plan friction is likely
- If onboarding completion is low, onboarding friction is likely
- If AI usage is high but pass creation completion is low, product output quality/activation gap exists

---

## Communication Style

- Keep concise and business-oriented
- Focus on revenue and conversion implications, not technical detail
- Prefer clear directional statements:
  - up/down vs prior period
  - where drop-offs concentrate
  - where gains occurred

---

## Checklist

Before marking the debrief process as done:

- [ ] Topline metrics dashboard is accessible in PostHog (or equivalent)
- [ ] Funnel events are correctly instrumented and visible in the analytics tool
- [ ] KPI formulas are documented and calculated automatically where possible
- [ ] Debrief is run on a consistent cadence (daily or weekly)
- [ ] Action items from debriefs are tracked and reviewed in the next period
