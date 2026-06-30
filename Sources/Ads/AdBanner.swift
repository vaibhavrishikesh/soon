import SwiftUI
import GoogleMobileAds

enum AdConfig {
    /// AdMob app id (also set in Info.plist as GADApplicationIdentifier).
    static let appID = "ca-app-pub-4765907187067298~5073486989"

    /// In Debug we use Google's official TEST banner unit so we never serve real
    /// ads to ourselves (which would violate AdMob policy). Release uses the real one.
    static var bannerUnitID: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/2934735716"   // Google test banner
        #else
        return "ca-app-pub-4765907187067298/4530561501"   // real Soon banner
        #endif
    }
}

/// SwiftUI wrapper around a standard AdMob banner (320×50).
struct AdBannerView: UIViewRepresentable {
    var adUnitID: String = AdConfig.bannerUnitID

    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = adUnitID
        banner.rootViewController = Self.rootViewController()
        banner.load(GADRequest())
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}

    private static func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController
    }
}
