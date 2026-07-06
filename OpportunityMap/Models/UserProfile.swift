import Foundation

// MARK: - UserProfile

/// 使用者自填的基本條件，用於本地適配比對與 AI 判讀。存 UserDefaults。
struct UserProfile: Codable, Equatable {
    var age: Int?
    var identity: UserIdentity?
    var region: String?          // 縣市名；nil = 未設定

    /// 只要填了任一項條件就能推薦（填什麼就用什麼比對，不強迫全填）。
    var hasCriteria: Bool { age != nil || identity != nil || region != nil }

    static let empty = UserProfile()
}

// MARK: - UserIdentity

/// 對應 data 內的 identities 值（「不限」為機會端的萬用值，不是使用者身分）。
enum UserIdentity: String, Codable, CaseIterable, Identifiable {
    case student       = "學生"
    case freshGraduate = "社會新鮮人"
    case entrepreneur  = "創業者"
    case other         = "其他"

    var id: String { rawValue }
    var displayName: String { rawValue }
}

// MARK: - TaiwanRegion

/// 縣市清單（供 Profile 選單）。比對時：機會 regions 含使用者縣市 → 在地；含「全國」→ 全國適用。
enum TaiwanRegion {
    static let all = [
        "臺北市", "新北市", "桃園市", "臺中市", "臺南市", "高雄市",
        "基隆市", "新竹市", "新竹縣", "苗栗縣", "彰化縣", "南投縣",
        "雲林縣", "嘉義市", "嘉義縣", "屏東縣", "宜蘭縣", "花蓮縣",
        "臺東縣", "澎湖縣", "金門縣", "連江縣"
    ]
}

// MARK: - MatchResult

/// 單筆機會對某使用者的本地比對結果（確定性、離線、免費）。
struct MatchResult {
    let isEligible: Bool
    let score: Int          // 0...100，僅在 isEligible 時有意義
    let reasons: [String]   // 命中理由（本地產生，供詳情頁條列）

    var level: MatchLevel {
        guard isEligible else { return .ineligible }
        switch score {
        case 80...:     return .high
        case 60..<80:   return .medium
        default:        return .low
        }
    }
}

enum MatchLevel {
    case ineligible, low, medium, high

    var label: String {
        switch self {
        case .ineligible: return "不符資格"
        case .low:        return "可考慮"
        case .medium:     return "頗適合"
        case .high:       return "很適合"
        }
    }
}

// MARK: - MatchEngine

/// 用 Eligibility 對 UserProfile 算適配度。年齡為硬條件，身分與地區為加權。
enum MatchEngine {
    static func evaluate(_ opportunity: Opportunity, for profile: UserProfile) -> MatchResult {
        let e = opportunity.eligibility

        // 年齡是硬條件：填了年齡且落在範圍外 → 直接不符資格。
        if let age = profile.age, !e.matches(age: age) {
            return MatchResult(isEligible: false, score: 0,
                               reasons: ["年齡不符（適用 \(e.ageText)）"])
        }

        var score = 45   // 基礎分：落在資格內
        var reasons: [String] = []

        // 年齡命中（機會設有年齡限制且使用者落在範圍內）。
        if profile.age != nil, e.minAge != nil || e.maxAge != nil {
            score += 15
            reasons.append("年齡符合（\(e.ageText)）")
        }

        // 身分：精準相符加最多；不限次之。
        if let identity = profile.identity, e.identities.contains(identity.rawValue) {
            score += 25
            reasons.append("身分相符（\(identity.displayName)）")
        } else if e.identities.contains("不限") {
            score += 10
            reasons.append("身分不限")
        }

        // 地區：在地相符加最多；全國適用次之。
        if let region = profile.region, e.regions.contains(region) {
            score += 20
            reasons.append("在地機會（\(region)）")
        } else if e.regions.contains("全國") {
            score += 10
            reasons.append("全國適用")
        }

        return MatchResult(isEligible: true, score: min(score, 100), reasons: reasons)
    }
}
