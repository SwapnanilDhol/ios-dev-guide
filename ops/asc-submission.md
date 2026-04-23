# App Store Submission with ASC CLI

## Pre-Flight Checklist

Before archiving, ensure all App Store metadata is complete:

- [ ] **What's New text** for all localizations (`asc localizations update --version ID --locale en-US --whats-new "..."`)
- [ ] **Promotional text** updated (`asc localizations update --version ID --locale en-US --promotional-text "..."`)
- [ ] **Screenshots** uploaded for all locales and device sizes
- [ ] **App Review Contact** configured in ASC
- [ ] **Build number** incremented (`CURRENT_PROJECT_VERSION` in project.pbxproj)

---

## Workflow: ASC CLI First, Archive Second

**Start with ASC CLI setup before building**, not after. This prevents wasted builds.

### Step 1: Validate ASC Auth

```bash
npx asc doctor
```

If auth fails, fix before archiving. A failed upload wastes the build.

### Step 2: Check Existing Versions

```bash
npx asc versions list --app APP_ID --platform IOS
npx asc builds list --app APP_ID --platform IOS --processing-state VALID
```

**Key insight**: Build numbers are shared across all versions. If build 11 already exists as VALID, you can attach it to a new version without re-uploading. Only increment build number when you need a new build.

### Step 3: Archive with Correct Build Number

1. Increment `CURRENT_PROJECT_VERSION` in `project.pbxproj`
2. Archive
3. Export as `.ipa` via `xcodebuild -exportArchive`
4. Upload via `npx asc builds upload --app APP_ID --ipa path.ipa --build-number N`

### Step 4: Create Version If Needed

If the latest version is already `READY_FOR_SALE` or `WAITING_FOR_REVIEW`, create a new one:

```bash
npx asc versions create --app APP_ID --platform IOS --version "X.Y.Z"
```

### Step 5: Attach Build

```bash
# Find the build ID
npx asc builds list --app APP_ID --platform IOS --processing-state VALID

# Attach to version
npx asc versions attach-build --version-id VERSION_ID --build BUILD_ID
```

### Step 6: Fill WhatsNew

```bash
# Update for each locale
npx asc localizations update --version VERSION_ID --locale en-US --whats-new "Bug fixes and performance improvements"
npx asc localizations update --version VERSION_ID --locale de-DE --whats-new "Fehlerbehebungen und Leistungsverbesserungen"
npx asc localizations update --version VERSION_ID --locale fr-FR --whats-new "Corrections de bugs"
npx asc localizations update --version VERSION_ID --locale ja --whats-new "バグ修正とパフォーマンス向上"
```

### Step 7: Submit

```bash
# Create review submission
npx asc review submissions-create --app APP_ID --platform IOS

# Add version to submission
npx asc review items-add --submission SUBMISSION_ID --item-type appStoreVersions --item-id VERSION_ID

# Submit
npx asc review submissions-submit --id SUBMISSION_ID --confirm
```

---

## Key Learnings from PassMaker 2.0.6 Submission

### 1. altool JWT Auth Is Broken

`xcrun altool --upload-app` **cannot authenticate with API keys** in current Xcode. Despite passing `--api-issuer`, `--api-key-id`, and `--api-key`, it fails with "JWT auth required" errors. The ASC CLI (`npx asc builds upload --ipa`) works correctly and is the reliable path.

**Use ASC CLI for uploads, not altool.**

### 2. builds upload Requires .ipa, Not .xcarchive

`npx asc builds upload` takes `--ipa path.ipa`, not the archive directly. Export first:

```bash
xcodebuild -exportArchive \
  -archivePath build/PassMaker.xcarchive \
  -exportPath build/Export \
  -exportOptionsPlist build/export_options.plist
```

### 3. exportOptionsPlist Format for xcodebuild -exportArchive

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>destination</key>
    <string>export</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
```

The only valid `destination` value is `export`. Using anything else (e.g., `developer`, `upload`) fails with "expected one of {export}".

### 4. Wallet Feature Requires Distribution Certificate

`exportArchive` fails with "requires a provisioning profile with the Wallet feature" when using `Apple Development` certificates. Use `signingStyle: automatic` which selects the correct Distribution certificate automatically.

### 5. Build Number Is Shared Across Versions

Build 11 already existed from an earlier upload attempt. Calling `builds upload --build-number 11` fails with "bundle version must be higher than previously uploaded." The existing VALID build 11 was attached to the new version without re-uploading.

**Before building, check if the build number already exists in App Store Connect.**

### 6. whatsNew Is Required Before Submission

Every localization requires `whatsNew` text before the version can be submitted. The error: "You must provide a value for the attribute 'whatsNew' with this request." Fill this before attempting `review items-add`.

### 7. Build Must Be VALID Before Attach

The version attachment and submission only succeed when the build processing state is `VALID`. If a new upload fails (e.g., error 90161), use an already-validated build instead.

### 8. Version Must Be in PREPARE_FOR_SUBMISSION State

`review submissions-create` works for creating submissions, but `review items-add` fails if the version is in a state other than `PREPARE_FOR_SUBMISSION`. Create the version before attempting to add items to a submission.

---

## altool vs ASC CLI

| Operation | altool | ASC CLI |
| --- | --- | --- |
| Upload .xcarchive | Broken (JWT auth) | `npx asc builds upload --ipa` |
| List versions | Works | `npx asc versions list` |
| List builds | Works | `npx asc builds list` |
| Create version | No | `npx asc versions create` |
| Attach build | No | `npx asc versions attach-build` |
| Update localizations | No | `npx asc localizations update` |
| Create submission | No | `npx asc review submissions-create` |
| Submit | No | `npx asc review submissions-submit` |

**Conclusion**: Use altool only for debugging auth. Use ASC CLI for everything else.
