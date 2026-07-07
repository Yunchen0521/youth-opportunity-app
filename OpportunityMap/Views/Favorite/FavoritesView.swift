import SwiftData
import SwiftUI

/// 收藏頁：列出本地收藏；左滑可釘選（置頂）或刪除。釘選的機會分到「已釘選」區並排最上面。
struct FavoritesView: View {
    @Environment(OpportunityStore.self) private var store
    @Environment(ProfileStore.self) private var profileStore
    @Environment(\.modelContext) private var context
    @Query(sort: \FavoriteOpportunity.savedAt, order: .reverse) private var favorites: [FavoriteOpportunity]

    /// 釘選的機會，依釘選時間排序（最近釘的排最上）。
    private var pinned: [FavoriteOpportunity] {
        favorites.filter(\.isPinned)
            .sorted { ($0.pinnedAt ?? .distantPast) > ($1.pinnedAt ?? .distantPast) }
    }
    /// 其他（未釘選）的機會，維持收藏時間新到舊。
    private var others: [FavoriteOpportunity] {
        favorites.filter { !$0.isPinned }
    }

    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    ContentUnavailableView("尚無收藏",
                                           systemImage: "heart",
                                           description: Text("在機會詳情頁點愛心即可收藏"))
                } else {
                    List {
                        if pinned.isEmpty {
                            // 沒有釘選項目時不顯示分區標題，維持乾淨。
                            ForEach(others) { favoriteRow($0) }
                        } else {
                            Section("已釘選") {
                                ForEach(pinned) { favoriteRow($0) }
                            }
                            if !others.isEmpty {
                                Section("其他收藏") {
                                    ForEach(others) { favoriteRow($0) }
                                }
                            }
                        }
                    }
                    .navigationDestination(for: Opportunity.self) { opportunity in
                        OpportunityDetailView(opportunity: opportunity)
                    }
                }
            }
            .navigationTitle("收藏")
        }
    }

    // MARK: - 列

    @ViewBuilder private func favoriteRow(_ favorite: FavoriteOpportunity) -> some View {
        row(for: favorite)
            // 右滑：釘選 / 取消釘選
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button {
                    togglePin(favorite)
                } label: {
                    Label(favorite.isPinned ? "取消釘選" : "釘選",
                          systemImage: favorite.isPinned ? "pin.slash" : "pin")
                }
                .tint(.accentColor)
            }
            // 左滑：從收藏移除（機會本身仍在，只是取消收藏）
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    removeFavorite(favorite)
                } label: {
                    Label("移除收藏", systemImage: "heart.slash")
                }
            }
    }

    @ViewBuilder private func row(for favorite: FavoriteOpportunity) -> some View {
        if let opportunity = store.all.first(where: { $0.id == favorite.id }) {
            NavigationLink(value: opportunity) {
                OpportunityRow(opportunity: opportunity, matchLevel: matchLevel(for: opportunity))
            }
        } else {
            // 機會已不在目前清單（例如已下架）— 仍顯示基本資訊。
            VStack(alignment: .leading, spacing: 4) {
                Text(favorite.title).font(.headline)
                Text("此機會已不在目前清單")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    /// 有設定條件才算適配度徽章（跟探索/詳情頁一致）；收藏頁保留不符資格者，一併標示。
    private func matchLevel(for opportunity: Opportunity) -> MatchLevel? {
        let profile = profileStore.profile
        guard profile.hasCriteria else { return nil }
        return MatchEngine.evaluate(opportunity, for: profile).level
    }

    // MARK: - 動作

    private func togglePin(_ favorite: FavoriteOpportunity) {
        favorite.isPinned.toggle()
        favorite.pinnedAt = favorite.isPinned ? .now : nil
        try? context.save()
    }

    /// 從收藏移除（僅刪除本地收藏紀錄，不影響機會本身）。
    private func removeFavorite(_ favorite: FavoriteOpportunity) {
        context.delete(favorite)
        try? context.save()
    }
}
