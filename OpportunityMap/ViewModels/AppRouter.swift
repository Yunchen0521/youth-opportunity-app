import Observation

/// 全域導覽狀態：目前選到的 Tab（讓子頁能主動切換分頁，例如彈窗的「去設定」）。
@Observable
final class AppRouter {
    var selectedTab: Int = AppTab.explore
}

enum AppTab {
    static let explore = 0
    static let favorites = 2
    static let profile = 3
}
