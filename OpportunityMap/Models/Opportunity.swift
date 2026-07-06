import Foundation

// MARK: - Opportunity

/// 一筆青年機會。對應 data/opportunities.json 的單一項目。
/// `location` 僅用於「單一固定據點」（venue 或單址活動）；多點/全國/海外的機會 location = nil，只進列表不進地圖。
struct Opportunity: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let category: Category
    let organizer: String
    let sourceType: SourceType
    let summary: String          // AI 三句話摘要
    let description: String
    let eligibility: Eligibility
    let amount: String?
    let deadline: Date?          // 可空：長期開放或年度徵件（日期逐年微調）
    let applyStartDate: Date?
    let website: String
    let location: OppLocation?

    /// 是否可標在地圖上（有固定據點）。
    var isMappable: Bool { location != nil }
}

// MARK: - Eligibility

struct Eligibility: Codable, Hashable {
    let minAge: Int?
    let maxAge: Int?
    let identities: [String]     // 學生 / 社會新鮮人 / 創業者 / 不限
    let regions: [String]        // 縣市 或 全國

    /// 「18–35 歲」「35 歲以下」「不限年齡」等顯示字串。
    var ageText: String {
        switch (minAge, maxAge) {
        case let (min?, max?): return "\(min)–\(max) 歲"
        case let (min?, nil):  return "\(min) 歲以上"
        case let (nil, max?):  return "\(max) 歲以下"
        case (nil, nil):       return "不限年齡"
        }
    }

    /// 判斷某年齡是否落在資格範圍內（用於篩選；無界線視為符合）。
    func matches(age: Int) -> Bool {
        if let min = minAge, age < min { return false }
        if let max = maxAge, age > max { return false }
        return true
    }
}

// MARK: - Location

struct OppLocation: Codable, Hashable {
    let city: String
    let address: String
    let latitude: Double?        // 可空：為空時由 App 以 address 在執行時 CLGeocoder 取座標並快取
    let longitude: Double?

    /// 是否已帶座標（不需再 geocode）。
    var hasCoordinate: Bool { latitude != nil && longitude != nil }
}

// MARK: - Category

enum Category: String, Codable, CaseIterable, Hashable {
    case subsidy        // 補助
    case competition    // 競賽
    case internship     // 實習
    case startup        // 創業
    case training       // 培力
    case exchange       // 海外交流
    case scholarship    // 獎學金
    case grant          // 圓夢 / 行動補助
    case venue          // 常設據點（創業基地等）
    case platform       // 資源平台入口

    var displayName: String {
        switch self {
        case .subsidy:     return "補助"
        case .competition: return "競賽"
        case .internship:  return "實習"
        case .startup:     return "創業"
        case .training:    return "培力"
        case .exchange:    return "海外交流"
        case .scholarship: return "獎學金"
        case .grant:       return "圓夢補助"
        case .venue:       return "創業據點"
        case .platform:    return "資源平台"
        }
    }

    /// SF Symbol 名稱，供地圖標記與列表圖示使用。
    var symbolName: String {
        switch self {
        case .subsidy:     return "dollarsign.circle"
        case .competition: return "trophy"
        case .internship:  return "briefcase"
        case .startup:     return "lightbulb"
        case .training:    return "graduationcap"
        case .exchange:    return "airplane"
        case .scholarship: return "studentdesk"
        case .grant:       return "sparkles"
        case .venue:       return "building.2"
        case .platform:    return "square.grid.2x2"
        }
    }
}

// MARK: - SourceType

enum SourceType: String, Codable, CaseIterable, Hashable {
    case government     // 政府機關
    case foundation     // 基金會 / 非營利
    case company        // 企業

    var displayName: String {
        switch self {
        case .government: return "政府"
        case .foundation: return "基金會"
        case .company:    return "企業"
        }
    }
}

// MARK: - Feed wrapper

/// data/opportunities.json 的最外層結構。
struct OpportunityFeed: Codable {
    let version: String
    let updatedAt: String
    let opportunities: [Opportunity]
}
