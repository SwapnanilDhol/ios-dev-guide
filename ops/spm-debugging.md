# SPM, DerivedData & Package Cache Troubleshooting

## Common Issues

### Stale Build Artifacts After Deleting Files

After deleting source files, the build may fail with errors about missing symbols from the deleted file. The `.o` and `.swiftconstvalues` files in DerivedData reference old symbols.

**Fix**: Rebuild the project — it automatically cleans stale artifacts. The build output will show `note: Removed stale file 'XXX.o'` entries as the build succeeds.

### Module Not Found After Adding Package

If a newly added SPM package shows as "not found" even though it's in `Package.resolved`:

1. Clean the derived data for that specific package: `rm -rf ~/Library/Developer/Xcode/DerivedData/{PackageName}-*/`
2. Clean the main project's derived data
3. Run `File → Packages → Reset Package Caches`
4. Rebuild

### canImport Returns Wrong Value

`canImport()` checks are evaluated at compile time based on the build configuration. The module must be a **direct dependency** of the target, not just transitive.

**Symptoms**: Works in Debug, fails in Release. Build succeeds but entire feature branches are compiled out.

**Fix**: Use wrapper-only architecture — let the library handle conditional imports. See [`../stack/ads.md`](../stack/ads.md).

### Build Succeeds But App Crashes

If the app crashes immediately on launch after adding a package:

1. Check if the package has a `.xcconfig` file that sets deployment target too high
2. Verify the package's `platforms` in `Package.swift` includes your minimum iOS version
3. Try adding the package to a fresh empty project to isolate the issue

### Package Resolution Conflicts

If `Package.resolved` shows conflicting versions:

```bash
# Reset all packages
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf YourProject.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved

# Then rebuild
xcodebuild -resolvePackageDependencies
```

---

## Checklist

Before marking SPM and build health as done:

- [ ] A clean build succeeds after deleting stale files (verify `Removed stale file` notes)
- [ ] Newly added packages resolve correctly and appear in `Package.resolved`
- [ ] No `#if canImport(...)` guards are used in app targets (wrapper-only architecture)
- [ ] Archive build succeeds, not just Debug/simulator builds
- [ ] DerivedData reset procedure is documented for the team
- [ ] Package platform versions in `Package.swift` match the app's minimum iOS version
