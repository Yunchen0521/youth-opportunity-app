//
//  ContentView.swift
//  青機會 — 根 TabBar（探索 / 收藏 / 我的）
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var store = OpportunityStore()
    @State private var profileStore = ProfileStore()
    @State private var router = AppRouter()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                mainTabs
            } else {
                OnboardingView { hasCompletedOnboarding = true }
            }
        }
        .environment(store)
        .environment(profileStore)
        .environment(router)
        .task {
            if store.all.isEmpty { await store.loadRemoteThenFallback() }
        }
    }

    private var mainTabs: some View {
        @Bindable var router = router
        return TabView(selection: $router.selectedTab) {
            ExploreView()
                .tabItem { Label("探索", systemImage: "square.grid.2x2") }
                .tag(AppTab.explore)

            FavoritesView()
                .tabItem { Label("收藏", systemImage: "heart") }
                .tag(AppTab.favorites)

            ProfileView()
                .tabItem { Label("我的", systemImage: "person") }
                .tag(AppTab.profile)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: FavoriteOpportunity.self, inMemory: true)
}
