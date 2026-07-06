import Foundation
import UserNotifications

/// 截止提醒：用本地通知（UNUserNotificationCenter），在截止前 N 天提醒使用者。
/// 不需要伺服器；權限、排程、取消都在裝置本地完成。
final class ReminderService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = ReminderService()

    private let center = UNUserNotificationCenter.current()
    private let idPrefix = "reminder-"
    private let daysBefore = 3

    enum ScheduleResult {
        case scheduled           // 已排程
        case denied              // 使用者未授權通知
        case pastDeadline        // 已過截止日
        case noDeadline          // 此機會沒有明確截止日
        case failed              // 其他失敗
    }

    private override init() {
        super.init()
        center.delegate = self   // 讓通知在 App 前景時也會跳出（demo 友善）
    }

    // MARK: - 排程 / 取消 / 查詢

    func schedule(for opportunity: Opportunity) async -> ScheduleResult {
        guard let deadline = opportunity.deadline else { return .noDeadline }
        guard await ensureAuthorized() else { return .denied }

        let now = Date()
        guard deadline > now else { return .pastDeadline }

        let content = UNMutableNotificationContent()
        content.title = "截止提醒"
        content.body = "「\(opportunity.title)」將於 \(Self.dateText(deadline)) 截止，記得把握。"
        content.sound = .default

        let request = UNNotificationRequest(identifier: id(for: opportunity.id),
                                            content: content,
                                            trigger: trigger(for: deadline, now: now))
        do {
            try await center.add(request)
            return .scheduled
        } catch {
            return .failed
        }
    }

    func cancel(for opportunityID: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id(for: opportunityID)])
    }

    func isScheduled(for opportunityID: String) async -> Bool {
        let target = id(for: opportunityID)
        return await center.pendingNotificationRequests().contains { $0.identifier == target }
    }

    // MARK: - 內部

    /// 截止前 daysBefore 天的早上 9 點；若已過該時刻但尚未截止，則 60 秒後提醒（確保仍會觸發、也方便 demo）。
    private func trigger(for deadline: Date, now: Date) -> UNNotificationTrigger {
        let cal = Calendar(identifier: .gregorian)
        var reminder = cal.date(byAdding: .day, value: -daysBefore, to: deadline) ?? deadline
        if let nine = cal.date(bySettingHour: 9, minute: 0, second: 0, of: reminder) {
            reminder = nine
        }
        if reminder > now {
            let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: reminder)
            return UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        } else {
            return UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        }
    }

    private func ensureAuthorized() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        default:
            return false
        }
    }

    private func id(for opportunityID: String) -> String { idPrefix + opportunityID }

    private static func dateText(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// App 在前景時也顯示橫幅與聲音。
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
        -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }
}
