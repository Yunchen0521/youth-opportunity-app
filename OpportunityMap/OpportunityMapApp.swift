//
//  OpportunityMapApp.swift
//  青機會 Opportunity Map Taiwan
//

import SwiftData
import SwiftUI

@main
struct OpportunityMapApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: FavoriteOpportunity.self)
    }
}
