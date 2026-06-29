import SwiftUI

@main
struct SoonApp: App {
    @StateObject private var store = EventStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
