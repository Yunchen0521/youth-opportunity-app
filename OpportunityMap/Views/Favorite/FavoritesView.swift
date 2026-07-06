import SwiftData
import SwiftUI

/// 收藏頁：列出本地收藏，點擊回到詳情；滑動刪除。
struct FavoritesView: View {
    @Environment(OpportunityStore.self) private var store
    @Environment(\.modelContext) private var context
    @Query(sort: \FavoriteOpportunity.savedAt, order: .reverse) private var favorites: [FavoriteOpportunity]

    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    ContentUnavailableView("尚無收藏",
                                           systemImage: "heart",
                                           description: Text("在機會詳情頁點愛心即可收藏"))
                } else {
                    List {
                        ForEach(favorites) { favorite in
                            row(for: favorite)
                        }
                        .onDelete(perform: delete)
                    }
                    .navigationDestination(for: Opportunity.self) { opportunity in
                        OpportunityDetailView(opportunity: opportunity)
                    }
                }
            }
            .navigationTitle("收藏")
        }
    }

    @ViewBuilder private func row(for favorite: FavoriteOpportunity) -> some View {
        if let opportunity = store.all.first(where: { $0.id == favorite.id }) {
            NavigationLink(value: opportunity) {
                OpportunityRow(opportunity: opportunity)
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

    private func delete(_ offsets: IndexSet) {
        for index in offsets { context.delete(favorites[index]) }
        try? context.save()
    }
}
