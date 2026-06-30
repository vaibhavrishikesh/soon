import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

@main
struct SoonApp: App {
    @StateObject private var store = EventStore()

    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .task {
                    NotificationManager.rescheduleAll(store.events)
                    // Ask for tracking permission (needed for personalized ads).
                    ATTrackingManager.requestTrackingAuthorization { _ in }
                }
        }
    }
}
