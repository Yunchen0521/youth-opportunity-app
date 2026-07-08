import GoogleMobileAds
import SwiftUI
import UIKit

/// 探索頁底部的 AdMob 橫幅廣告。
///
/// 目前用 Google 官方「測試廣告單元 ID」→ 顯示標著「Test Ad」的假廣告，
/// 不需 AdMob 帳號、也不違反政策（自己不能點真廣告）。
///
/// 之後真要上架營利時，改兩個地方即可：
///  1. 這裡的 `testAdUnitID` 換成 AdMob 後台的正式 Ad Unit ID。
///  2. 專案 build 設定的 `INFOPLIST_KEY_GADApplicationIdentifier` 換成正式 App ID。
struct BannerAdView: UIViewRepresentable {
    /// Google 官方 iOS 橫幅測試 ID（公開固定值）
    private let testAdUnitID = "ca-app-pub-3940256099942544/2934735716"

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)   // 標準 320×50 橫幅
        banner.adUnitID = testAdUnitID
        banner.rootViewController = Self.topViewController()
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}

    /// 廣告被點擊時要有 rootViewController 來呈現後續畫面。
    private static func topViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
