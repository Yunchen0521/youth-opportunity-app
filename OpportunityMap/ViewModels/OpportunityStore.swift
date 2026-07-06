import Foundation

/// 機會資料的記憶體存放與篩選邏輯（MVVM 的 ViewModel）。
@Observable
final class OpportunityStore {
    private(set) var all: [Opportunity] = []
    private(set) var isLoading = false
    private(set) var loadError: String?

    // 資料來源 metadata（顯示在「我的」，讓遠端更新看得見）。
    private(set) var dataVersion: String?
    private(set) var dataUpdatedAt: String?

    // 篩選狀態
    var searchText: String = ""
    var selectedCategories: Set<Category> = []
    var selectedSource: SourceType?

    // 搜尋歷史（存 UserDefaults，跨次開啟保留）
    private(set) var recentSearches: [String] = []
    private let recentSearchesKey = "recentSearches"
    private let maxRecentSearches = 8

    private let service = OpportunityService()

    init() {
        recentSearches = UserDefaults.standard.stringArray(forKey: recentSearchesKey) ?? []
    }

    /// 載入內建資料（同步、離線可用）。
    func load() {
        isLoading = true
        loadError = nil
        do {
            apply(try service.loadBundled())
        } catch {
            loadError = "資料載入失敗：\(error.localizedDescription)"
            all = []
        }
        isLoading = false
    }

    /// 資料上 GitHub 後，這個會抓遠端；失敗自動 fallback 內建。
    func loadRemoteThenFallback() async {
        isLoading = true
        loadError = nil
        do {
            apply(try await service.loadRemote())
        } catch {
            do { apply(try service.loadBundled()) }
            catch { loadError = "資料載入失敗：\(error.localizedDescription)" }
        }
        isLoading = false
    }

    private func apply(_ feed: OpportunityFeed) {
        all = feed.opportunities
        dataVersion = feed.version
        dataUpdatedAt = feed.updatedAt
    }

    /// 套用搜尋與篩選後的結果。
    var filtered: [Opportunity] {
        all.filter { opp in
            if !selectedCategories.isEmpty && !selectedCategories.contains(opp.category) { return false }
            if let source = selectedSource, opp.sourceType != source { return false }
            if !searchText.isEmpty {
                let query = searchText.localizedLowercase
                let haystack = [opp.title, opp.organizer, opp.summary, opp.category.displayName]
                    .joined(separator: " ")
                    .localizedLowercase
                if !haystack.contains(query) { return false }
            }
            return true
        }
    }

    /// 有固定據點、可標在地圖上的機會。
    var mappable: [Opportunity] { all.filter(\.isMappable) }

    var activeFilterCount: Int {
        selectedCategories.count + (selectedSource == nil ? 0 : 1)
    }

    func toggleCategory(_ category: Category) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }

    func clearFilters() {
        selectedCategories.removeAll()
        selectedSource = nil
    }

    // MARK: - 搜尋歷史

    /// 記錄一次搜尋（去重、最近的排最前、上限 maxRecentSearches）。
    func addSearch(_ raw: String) {
        let term = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return }
        recentSearches.removeAll { $0.caseInsensitiveCompare(term) == .orderedSame }
        recentSearches.insert(term, at: 0)
        if recentSearches.count > maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(maxRecentSearches))
        }
        persistRecentSearches()
    }

    func removeSearch(_ term: String) {
        recentSearches.removeAll { $0 == term }
        persistRecentSearches()
    }

    func clearRecentSearches() {
        recentSearches.removeAll()
        persistRecentSearches()
    }

    private func persistRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }
}
