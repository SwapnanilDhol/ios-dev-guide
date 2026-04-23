# Common Code Snippets

## AppEnvironment

```swift
enum AppEnvironment {
    case debug
    case release
    case testing

    static var current: AppEnvironment {
        #if DEBUG
        return .debug
        #else
        return .release
        #endif
    }

    var analyticsEnabled: Bool {
        switch self {
        case .debug, .testing: return false
        case .release: return true
        }
    }

    var shouldShowAds: Bool {
        switch self {
        case .debug, .testing: return false
        case .release: return true
        }
    }
}
```

## DeviceInfoService

```swift
enum DeviceInfoService {
    static func properties(environment: AppEnvironment = .current) -> [String: String] {
        [
            "app_version": Bundle.main.releaseVersionNumber,
            "app_build": Bundle.main.buildVersionNumber,
            "device_model": UIDevice.current.model,
            "device_system_version": UIDevice.current.systemVersion,
            "locale_language": Locale.current.language.languageCode?.identifier ?? "unknown",
            "timezone": TimeZone.current.identifier,
            "is_pro_enabled": String(UserDefaults.standard.bool(for: UserDefaultsKey.isProEnabled)),
            "revenue_cat_user_id": Purchases.shared.appUserID,
            "environment": environment.rawValue
        ]
    }
}
```

## UserDefaultKey enum

```swift
enum UserDefaultsKey: String, UserDefaultKeyProtocol {
    var keyString: String { rawValue }

    case isProEnabled
    case appOpenCount
    case proSheetOpenCount
}

// Usage
UserDefaults.standard.bool(for: UserDefaultsKey.isProEnabled)
@AppStorage(UserDefaultsKey.isProEnabled) var isProEnabled = false
```

## SFKButton Usage

```swift
import SwapFoundationKit

// Primary CTA
SFKButton(kind: .primary, title: "Get Started", systemImage: "arrow.right") {
    onTap()
}

// Close button for modals
SFKButton(kind: .close) { dismiss() }

// Inline destructive
SFKButton(kind: .inline, title: "Delete", systemImage: "trash", tint: .red) {
    onDelete()
}
```

## GlassEffectContainer

```swift
GlassEffectContainer(cornerRadius: 8, tint: .clear) {
    TextField(text: $text) { ... }
}
```

## ToastManager

```swift
enum AppToastType: SFKToastKind {
    case saved
    case deleted
    case error

    var title: String { ... }
    var subtitle: String? { ... }
    var style: SFKToastStyle { ... }
    var image: UIImage? { ... }
}

ToastManager.shared.show(kind: AppToastType.saved)
```

## AppLinkOpener

```swift
import SwapFoundationKit

AppLinkOpener.openAppStorePage(appID: AppConstants.AppId.appStore)
AppLinkOpener.openAppReviewPage(appID: AppConstants.AppId.appStore)
AppLinkOpener.open(url: URL(string: "https://example.com"))
```

## Logger

```swift
Logger.info("Analytics initialized", context: "Analytics")
Logger.debug("Event logged: \(event.rawValue)", context: "Analytics")
Logger.warning("Missing config for key", context: "Config")
Logger.error("Sync failed: \(error.localizedDescription)", context: "SyncManager")

// Enable auto-forwarding to analytics
Logger.setSendAnalyticsOnError(true)
```

## HapticsHelper

```swift
let haptics = HapticsHelper()

haptics.successNotification()   // purchase completed, restore succeeded
haptics.errorNotification()     // purchase failed, restore failed
haptics.mediumImpact()          // UI interactions (button taps, toggles)
```

## WidgetCenter Reload

```swift
// Reload all widgets
WidgetCenter.shared.reloadAllTimelines()

// Reload specific widget kind
WidgetCenter.shared.reloadTimelines(ofKind: AppConstants.WidgetKind.myWidget)
```

## BackupService

```swift
let backupService = BackupService()

// Perform backup
try await backupService.performBackup(myData, fileType: .data)

// Restore latest backup
let restored: MyData = try backupService.restoreBackup(MyData.self, fileType: .data)

// List all backups
let files = backupService.listBackupFiles(for: .data)
```

## File Export/Import

```swift
// Export
try FileExportService.shared.export(
    myItems,
    filename: "export.json",
    encoder: JSONEncoder(),
    from: presentingViewController
)

// Import
FileImportService.shared.importFile(
    contentTypes: [.json],
    from: presentingViewController,
    delegate: self
)
```

## Sendable Error Pattern

```swift
// BAD — Error is not Sendable
case aiDidFail(error: Error)

// GOOD — convert to String
case aiDidFail(errorMessage: String)
```
