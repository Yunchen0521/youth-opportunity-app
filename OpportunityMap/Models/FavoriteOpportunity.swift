import Foundation
import SwiftData

/// 使用者收藏的機會（本地 SwiftData）。以 `id` 對應遠端 Opportunity 的穩定 ID。
@Model
final class FavoriteOpportunity {
    @Attribute(.unique) var id: String
    var title: String
    var category: String
    var savedAt: Date

    init(id: String, title: String, category: String, savedAt: Date = .now) {
        self.id = id
        self.title = title
        self.category = category
        self.savedAt = savedAt
    }

    convenience init(from opportunity: Opportunity) {
        self.init(id: opportunity.id,
                  title: opportunity.title,
                  category: opportunity.category.rawValue)
    }
}
