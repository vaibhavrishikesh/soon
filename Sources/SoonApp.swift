import SwiftUI
import UIKit
import GoogleMobileAds
import AppTrackingTransparency
import UserNotifications

@main
struct SoonApp: App {
    @StateObject private var store = EventStore()
    private static let notifDelegate = NotificationDelegate()

    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        // Present reminders even while the app is open (foreground).
        UNUserNotificationCenter.current().delegate = Self.notifDelegate
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .task {
                    await requestPermissions()
                    NotificationManager.rescheduleAll(store.events)
                    // Live Activity for the soonest event in its final 24h.
                    LiveActivityManager.sync(store.events)
                }
        }
    }

    /// iOS silently drops an ATT request made before the app is active, and it
    /// can only present one system prompt at a time. So: wait until the app is
    /// active, request tracking and WAIT for the answer, then ask for
    /// notifications — otherwise the two prompts race and ATT never shows.
    @MainActor
    private func requestPermissions() async {
        while UIApplication.shared.applicationState != .active {
            try? await Task.sleep(nanoseconds: 150_000_000)
        }
        // A short beat so the window is key before presenting the ATT prompt.
        try? await Task.sleep(nanoseconds: 400_000_000)
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            await withCheckedContinuation { continuation in
                ATTrackingManager.requestTrackingAuthorization { _ in
                    continuation.resume()
                }
            }
        }
        // Ask for notification permission next so reminders can fire.
        await NotificationManager.requestAuthorizationIfNeeded()
    }
}
