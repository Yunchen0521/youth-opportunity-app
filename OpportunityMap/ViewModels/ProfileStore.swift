import Foundation

/// 使用者 Profile 的記憶體存放與持久化（UserDefaults）。
@Observable
final class ProfileStore {
    var profile: UserProfile {
        didSet { persist() }
    }

    private let key = "userProfile"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = decoded
        } else {
            profile = .empty
        }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
