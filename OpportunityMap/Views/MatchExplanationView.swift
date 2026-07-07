import SwiftUI

/// 適配度說明（共用）：解釋「很適合 / 頗適合 / 可考慮」怎麼分、依什麼判斷。
/// 用在「我的」的 ⓘ 說明 sheet，以及 onboarding 設定條件後的說明頁。
struct MatchExplanationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("我們依你設定的條件（年齡、身分、地區），判斷每個機會跟你的適配程度，共分成三個等級：")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 16) {
                row(.high, "你的身分或地區正好符合。")
                row(.medium, "你符合資格、方向也合，多為「不限身分」或「全國適用」的機會。")
                row(.low, "符合基本資格，但契合度普通。")
            }

            Divider()

            Label("這只是幫你快速篩選的參考，實際申請資格請以各官方網站最新公告為準。",
                  systemImage: "info.circle")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func row(_ level: MatchLevel, _ desc: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            MatchBadge(level: level)
                .frame(width: 84, alignment: .leading)
            Text(desc)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
