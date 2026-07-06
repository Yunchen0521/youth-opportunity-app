import SwiftUI

/// 輕量玻璃風格輔助。
/// iOS 26 以上使用原生 Liquid Glass（`glassEffect`），較舊系統自動退回 `ultraThinMaterial`，
/// 並刻意維持「輕」——只用在重點表面（標籤、卡片、浮層），不鋪滿整個畫面。
extension View {
    /// 圓角玻璃表面（卡片、浮層用）。
    @ViewBuilder
    func softGlass(cornerRadius: CGFloat = 16) -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(.primary.opacity(0.06), lineWidth: 1)
                )
        }
    }

    /// 膠囊玻璃（標籤、橫幅用）。
    @ViewBuilder
    func softGlassCapsule() -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(.regular, in: .capsule)
        } else {
            background(.ultraThinMaterial, in: Capsule())
        }
    }
}

/// 淡淡的主色背景漸層，讓玻璃表面有東西可折射、整體更有層次（很輕）。
struct SoftBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.accentColor.opacity(0.10),
                Color(.systemBackground)
            ],
            startPoint: .top,
            endPoint: .center
        )
        .ignoresSafeArea()
    }
}
