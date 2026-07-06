import SwiftUI

/// 探索頁（主入口）：關鍵字搜尋 + 類別篩選的機會列表。
struct ExploreView: View {
    @Environment(OpportunityStore.self) private var store
    @Environment(ProfileStore.self) private var profileStore
    @Environment(AppRouter.self) private var router
    @State private var sortByFit = false
    @State private var showProfilePrompt = false

    /// 列表要顯示的項目：一般模式不帶適配結果；「為我推薦」模式帶結果並排序。
    private struct RankedOpportunity: Identifiable {
        let opportunity: Opportunity
        let match: MatchResult?
        var id: String { opportunity.id }
    }

    private var displayed: [RankedOpportunity] {
        let base = store.filtered
        let profile = profileStore.profile
        // 有設定條件就算適配度並顯示徽章（跟詳情頁一致，不需按按鈕）。
        guard profile.hasCriteria else {
            return base.map { RankedOpportunity(opportunity: $0, match: nil) }
        }
        let ranked = base.map {
            RankedOpportunity(opportunity: $0, match: MatchEngine.evaluate($0, for: profile))
        }
        // 「依適配度排序」開啟時才重排；否則維持原順序、只顯示徽章。
        guard sortByFit else { return ranked }
        return ranked.sorted { lhs, rhs in
            guard let l = lhs.match, let r = rhs.match else { return false }
            if l.isEligible != r.isEligible { return l.isEligible }   // 符合資格的排前面
            return l.score > r.score
        }
    }

    var body: some View {
        @Bindable var store = store
        NavigationStack {
            
            Group {
                if store.isLoading {
                    ProgressView("載入中…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = store.loadError {
                    ContentUnavailableView("載入失敗",
                                           systemImage: "exclamationmark.triangle",
                                           description: Text(error))
                } else {
                    listContent
                }
            }
            .navigationTitle("探索機會")
            .searchable(text: $store.searchText, prompt: "搜尋計畫、主辦單位、關鍵字")
            .searchSuggestions {
                if store.searchText.isEmpty && !store.recentSearches.isEmpty {
                    Section("最近搜尋") {
                        ForEach(store.recentSearches, id: \.self) { term in
                            Label(term, systemImage: "clock.arrow.circlepath")
                                .searchCompletion(term)
                        }
                        Button("清除搜尋紀錄", systemImage: "trash", role: .destructive) {
                            store.clearRecentSearches()
                        }
                    }
                }
            }
            .onSubmit(of: .search) {
                store.addSearch(store.searchText)
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    recommendToggle
                    filterMenu
                }
            }
            .navigationDestination(for: Opportunity.self) { opportunity in
                OpportunityDetailView(opportunity: opportunity)
            }
            .alert("先設定你的條件", isPresented: $showProfilePrompt) {
                Button("去設定") { router.selectedTab = AppTab.profile }
                Button("知道了", role: .cancel) {}
            } message: {
                Text("填年齡、身分、地區其中任一項，就能依適配度為你排序推薦。")
            }
        }
    }

    private var listContent: some View {
        List {
            if store.filtered.isEmpty {
                ContentUnavailableView.search
            } else {
                // 計數文字：放成一般列（非 sticky header），只在頂端可見，往下滑即捲離。
                Text("\(displayed.count) 個機會")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
                ForEach(displayed) { item in
                    NavigationLink(value: item.opportunity) {
                        OpportunityRow(opportunity: item.opportunity, matchLevel: item.match?.level)
                    }
                }
            }
        }
        .listStyle(.plain)
        .environment(\.defaultMinListRowHeight, 0)   // 讓「N 個機會」短列縮到內容高度，不被最小列高撐開
        .refreshable { await store.loadRemoteThenFallback() }
    }

    private var recommendToggle: some View {
        Button {
            if profileStore.profile.hasCriteria {
                sortByFit.toggle()
            } else {
                showProfilePrompt = true      // 尚未設定任何條件 → 彈窗提醒
            }
        } label: {
            Label("依適配度排序",
                  systemImage: sortByFit ? "arrow.up.arrow.down.circle.fill" : "arrow.up.arrow.down.circle")
        }
        .tint(sortByFit ? .accentColor : .secondary)
    }

    private var filterMenu: some View {
        Menu {
            ForEach(Category.allCases, id: \.self) { category in
                Button {
                    store.toggleCategory(category)
                } label: {
                    Label(category.displayName,
                          systemImage: store.selectedCategories.contains(category) ? "checkmark" : category.symbolName)
                }
            }
            if store.activeFilterCount > 0 {
                Divider()
                Button("清除篩選", role: .destructive) { store.clearFilters() }
            }
        } label: {
            Label("篩選",
                  systemImage: store.activeFilterCount > 0 ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
        }
        // 複選時保持選單開啟，勾選完點選單外側才關閉。
        .menuActionDismissBehavior(.disabled)
    }
}

// MARK: - 共用元件

/// 列表 / 地圖卡片共用的單列。
struct OpportunityRow: View {
    let opportunity: Opportunity
    var matchLevel: MatchLevel? = nil

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: opportunity.category.symbolName)
                .font(.title3)
                .frame(width: 40, height: 40)
                .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 6) {
                Text(opportunity.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(opportunity.organizer)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    if let matchLevel {
                        MatchBadge(level: matchLevel)
                    }
                    TagChip(text: opportunity.category.displayName, accent: true)
                    TagChip(text: opportunity.sourceType.displayName)
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(.vertical, 10)
    }
}

struct TagChip: View {
    let text: String
    var accent: Bool = false

    private var color: Color { accent ? .accentColor : .secondary }

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(color)
            .lineLimit(1)
            .fixedSize()
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
            .background(color.opacity(0.14), in: Capsule())
    }
}
