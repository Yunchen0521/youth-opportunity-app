//
//  OpportunityMapApp.swift
//  青機會 Opportunity Map Taiwan
//

import GoogleMobileAds
import SwiftData
import SwiftUI

@main
struct OpportunityMapApp: App {
    init() {
        MobileAds.shared.start(completionHandler: nil)   // 初始化 AdMob SDK
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: FavoriteOpportunity.self)
    }
}
