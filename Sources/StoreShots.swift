import Foundation

/// Launch with: `-STORE_SHOTS` and optional `-STORE_SHOTS_SCREEN` = home|detail|add
enum StoreShots {
    static var enabled: Bool {
        ProcessInfo.processInfo.arguments.contains("-STORE_SHOTS")
    }

    /// Which screen to land on for capture. Default home.
    static var screen: String {
        guard let i = ProcessInfo.processInfo.arguments.firstIndex(of: "-STORE_SHOTS_SCREEN"),
              i + 1 < ProcessInfo.processInfo.arguments.count else { return "home" }
        return ProcessInfo.processInfo.arguments[i + 1]
    }
}
