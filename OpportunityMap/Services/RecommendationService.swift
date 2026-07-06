import Foundation

// MARK: - OpportunityAdvisor

/// AI 顧問：針對「使用者 Profile + 某個機會」給一句自然語言判讀。
/// 抽成 protocol，之後要換供應商 / 換呼叫方式只改實作。
protocol OpportunityAdvisor {
    func advise(opportunity: Opportunity, profile: UserProfile, match: MatchResult) async throws -> String
}

// MARK: - BackendAdvisor

/// 透過自架後端 proxy 呼叫 Claude。金鑰只放在後端（Cloudflare Worker），不進 App。
/// 後端合約：POST /advise，body = { profile, opportunity }，回 { advice: String }。
struct BackendAdvisor: OpportunityAdvisor {
    /// TODO：部署 Worker 後換成你的網址（見 backend/README.md）。
    static let endpoint = URL(string: "https://youth-opportunity-advisor.YOUR-SUBDOMAIN.workers.dev/advise")!

    // MARK: 傳輸型別

    private struct RequestBody: Encodable {
        let profile: ProfilePayload
        let opportunity: OpportunityPayload
    }
    private struct ProfilePayload: Encodable {
        let age: Int?
        let identity: String?
        let region: String?
    }
    private struct OpportunityPayload: Encodable {
        let title: String
        let category: String
        let organizer: String
        let summary: String
        let ageText: String
        let identities: [String]
        let regions: [String]
        let amount: String?
    }
    private struct ResponseBody: Decodable {
        let advice: String
    }

    enum AdvisorError: LocalizedError {
        case badStatus(Int)
        var errorDescription: String? {
            switch self {
            case .badStatus(let code): return "AI 顧問暫時無法使用（\(code)）"
            }
        }
    }

    func advise(opportunity: Opportunity, profile: UserProfile, match: MatchResult) async throws -> String {
        let body = RequestBody(
            profile: .init(age: profile.age,
                           identity: profile.identity?.rawValue,
                           region: profile.region),
            opportunity: .init(title: opportunity.title,
                               category: opportunity.category.displayName,
                               organizer: opportunity.organizer,
                               summary: opportunity.summary,
                               ageText: opportunity.eligibility.ageText,
                               identities: opportunity.eligibility.identities,
                               regions: opportunity.eligibility.regions,
                               amount: opportunity.amount)
        )

        var request = URLRequest(url: Self.endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw AdvisorError.badStatus((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        return try JSONDecoder().decode(ResponseBody.self, from: data).advice
    }

    /// endpoint 還是 placeholder 就代表尚未部署後端。
    static var isConfigured: Bool {
        !endpoint.absoluteString.contains("YOUR-SUBDOMAIN")
    }
}

// MARK: - MockAdvisor

/// 離線假顧問：不呼叫任何 API、零成本，但用真實資料組出貼近使用者的判讀，
/// 讓 App 在後端尚未部署時也能完整 demo。
struct MockAdvisor: OpportunityAdvisor {
    func advise(opportunity: Opportunity, profile: UserProfile, match: MatchResult) async throws -> String {
        // 模擬網路延遲，讓載入動畫自然呈現。
        try? await Task.sleep(for: .milliseconds(700))

        let e = opportunity.eligibility
        let category = opportunity.category.displayName

        guard match.isEligible else {
            return "依你填的條件，這個計畫的資格是「\(e.ageText)」，你目前可能不符合。先把它放一邊——探索頁開「為我推薦」會幫你把符合資格的往前排。"
        }

        var sentences: [String] = []

        switch match.level {
        case .high:
            sentences.append("這個\(category)跟你的條件很搭，值得優先考慮。")
        case .medium:
            sentences.append("這個\(category)整體算適合你，可以列入口袋名單。")
        default:
            sentences.append("這個\(category)你符合基本資格，但契合度普通，行有餘力再投。")
        }

        if let region = profile.region, e.regions.contains(region) {
            sentences.append("它就在\(region)，在地參與的成本低，是個優勢。")
        } else if e.regions.contains("全國") {
            sentences.append("全國都適用，地點不是問題。")
        }

        if let amount = opportunity.amount {
            sentences.append("補助「\(amount)」，記得看清楚使用與核銷規定。")
        } else {
            sentences.append("這類機會競爭者不少，建議提早準備作品或計畫書。")
        }

        sentences.append("實際申請請以\(opportunity.organizer)官網最新公告為準。")
        return sentences.joined()
    }
}

// MARK: - Advisors

enum Advisors {
    /// 後端已設定就用真的 Claude；否則自動退回 Mock（零成本、離線可 demo）。
    static var `default`: OpportunityAdvisor {
        BackendAdvisor.isConfigured ? BackendAdvisor() : MockAdvisor()
    }
}
