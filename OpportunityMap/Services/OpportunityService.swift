import Foundation

/// 載入機會資料。
/// v1：先讀 App bundle 內的 opportunities.json（離線可用）。
/// 之後資料上傳到 GitHub 後，呼叫 `loadRemote()` 即可切換成遠端，介面不變。
struct OpportunityService {
    /// 資料上傳到此 repo 後，遠端抓取即生效。
    static let remoteURL = URL(string: "https://raw.githubusercontent.com/Yunchen0521/opportunity-youth/main/opportunities.json")!

    enum ServiceError: LocalizedError {
        case bundleResourceMissing
        var errorDescription: String? {
            switch self {
            case .bundleResourceMissing: return "找不到內建的 opportunities.json"
            }
        }
    }

    /// 讀取 App bundle 內建資料。
    func loadBundled() throws -> OpportunityFeed {
        guard let url = Bundle.main.url(forResource: "opportunities", withExtension: "json") else {
            throw ServiceError.bundleResourceMissing
        }
        let data = try Data(contentsOf: url)
        return try decodeFeed(data)
    }

    /// 抓遠端資料（GitHub raw）。失敗時呼叫端可 fallback 到 `loadBundled()`。
    func loadRemote() async throws -> OpportunityFeed {
        let (data, _) = try await URLSession.shared.data(from: Self.remoteURL)
        return try decodeFeed(data)
    }

    private func decodeFeed(_ data: Data) throws -> OpportunityFeed {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Taipei")
        formatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)
        return try decoder.decode(OpportunityFeed.self, from: data)
    }
}
