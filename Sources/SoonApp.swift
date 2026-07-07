import SwiftUI
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
                    // Ask for tracking permission (personalized ads).
                    ATTrackingManager.requestTrackingAuthorization { _ in }
                    // Ask for notification permission up front so reminders can fire.
                    await NotificationManager.requestAuthorizationIfNeeded()
                    NotificationManager.rescheduleAll(store.events)
                }
        }
    }
}
