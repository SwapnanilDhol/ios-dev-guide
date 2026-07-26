# Build Gate (RTK)

## Principles

1. Prefer `rtk xcodebuild` for routine agent / CI-style builds so logs stay small.
2. Treat **exit code** as source of truth (`0` = success). Some wrappers may print a trailing `ok` even on failure — trust the process exit code.
3. For full compiler diagnostics, use plain `xcodebuild` or `rtk err xcodebuild …`.
4. Verify Release with archive before shipping — simulator Debug can hide `canImport` / linker issues.

## Recipe

```bash
cd /path/to/HostApp && rtk xcodebuild \
  -scheme <Scheme> \
  -destination 'platform=iOS Simulator,name=<Simulator>' \
  -quiet build
```

Discover simulators: `xcodebuild -scheme <Scheme> -showdestinations`.

`rtk` is expected on PATH (e.g. Homebrew: `/opt/homebrew/bin/rtk`).

## Task completion rule

Do not mark implementation tasks complete until the app **compiles successfully**.

## Checklist

- [ ] Scheme and simulator names are documented in the host `AGENTS.md`
- [ ] Routine builds use `rtk xcodebuild`
- [ ] Exit code is checked, not log text alone
- [ ] Archive path is used before App Store / TestFlight
