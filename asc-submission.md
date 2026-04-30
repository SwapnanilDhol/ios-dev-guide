# App Store Submission with ASC CLI

## The Right Way: `asc publish appstore`

There's a single canonical command that handles the entire flow:

```bash
npx asc publish appstore \
  --app 6469374653 \
  --ipa build/Export/PassMaker.ipa \
  --version 2.0.6 \
  --submit \
  --confirm
```

This does everything in one shot:
1. Uploads the IPA
2. Waits for build processing
3. Finds or creates the App Store version
4. Attaches the build
5. Submits for review

---

## Pre-Flight Checklist (Before Running the Command)

- [ ] **Build number** incremented in `project.pbxproj`
- [ ] **IPA exported** from the archive
- [ ] **whatsNew text** ready for each locale
- [ ] **Screenshots** uploaded (done separately via ASC or App Store Connect web)

---

## Step-by-Step (When You Need Manual Control)

### Step 1: Export IPA from Archive

```bash
# Create export_options.plist
cat > build/export_options.plist << 'EOF'
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
EOF

# Export
xcodebuild -exportArchive \
  -archivePath build/PassMaker.xcarchive \
  -exportPath build/Export \
  -exportOptionsPlist build/export_options.plist
```

### Step 2: Upload via ASC CLI

```bash
npx asc builds upload \
  --app 6469374653 \
  --ipa build/Export/PassMaker.ipa \
  --build-number 11 \
  --wait
```

### Step 3: Create Version If Needed

```bash
# Check existing state
npx asc versions list --app 6469374653 --platform IOS

# Create new version if latest is already published
npx asc versions create \
  --app 6469374653 \
  --platform IOS \
  --version "2.0.6"
```

### Step 4: Attach Build

```bash
# Find build ID
npx asc builds list --app 6469374653 --platform IOS --processing-state VALID

# Attach to version
npx asc versions attach-build \
  --version-id VERSION_ID \
  --build BUILD_ID
```

### Step 5: Fill WhatsNew

```bash
npx asc localizations update \
  --version VERSION_ID \
  --locale en-US \
  --whats-new "Bug fixes and performance improvements"
```

### Step 6: Submit

```bash
npx asc review submissions-create --app 6469374653 --platform IOS
npx asc review items-add \
  --submission SUBMISSION_ID \
  --item-type appStoreVersions \
  --item-id VERSION_ID
npx asc review submissions-submit --id SUBMISSION_ID --confirm
```

---

## Key Learnings from PassMaker 2.0.6

### 1. altool JWT Auth Is Broken

`xcrun altool --upload-app` **cannot authenticate with API keys** in current Xcode. Use `npx asc builds upload` or `asc publish appstore` instead.

### 2. `destination` Must Be `export` in ExportOptions

Using `developer`, `upload`, or any other value for `destination` in `ExportOptions.plist` fails with "expected one of {export}". Use `automatic` signing style for Wallet-enabled apps.

### 3. Build Number Is Shared Across Versions

Build 11 already existed as VALID. Calling `builds upload --build-number 11` fails with "bundle version must be higher." Attach the existing VALID build to the new version instead of re-uploading.

### 4. Check Builds Before Archiving

Before incrementing build number and archiving, check if it already exists:
```bash
npx asc builds list --app APP_ID --platform IOS --processing-state VALID
```

### 5. whatsNew Is Required Before Submission

Every localization requires `whatsNew` text before the version can be submitted. Fill this before `review items-add`.

### 6. Build Must Be VALID Before Attach

Only attach builds with `processingState: VALID`. If a new upload fails, use an already-validated build.

### 7. Use `asc publish appstore` When Possible

This single command handles the full workflow. Use step-by-step only when you need fine-grained control (e.g., reusing an existing build).

---

## Checklist

Before marking App Store submission as done for a release:

- [ ] Build number is incremented and unique (checked via `asc builds list`)
- [ ] IPA is exported with `destination: export` in `ExportOptions.plist`
- [ ] `asc publish appstore` command is prepared with correct `--app`, `--ipa`, and `--version`
- [ ] `whatsNew` text is ready for every supported locale
- [ ] Screenshots are uploaded for all required devices and locales
- [ ] Release build archives successfully before attempting upload
- [ ] An existing VALID build is reused when appropriate instead of re-uploading
- [ ] Submission is confirmed and build processing completes without errors
