import SwiftUI

/// MatchLevel 的顏色與圖示對應（放在 SwiftUI 層，讓 Model 維持純 Foundation）。
extension MatchLevel {
    var color: Color {
        switch self {
        case .ineligible: return .secondary
        case .low:        return .orange
        case .medium:     return .blue
        case .high:       return .green
        }
    }

    var symbolName: String {
        switch self {
        case .ineligible: return "xmark.circle"
        case .low:        return "circle.dashed"
        case .medium:     return "checkmark.circle"
        case .high:       return "star.circle.fill"
        }
    }
}

/// 適配度小徽章（列表列與詳情頁共用）。
struct MatchBadge: View {
    let level: MatchLevel

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: level.symbolName)
            Text(level.label)
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(level.color)
        .lineLimit(1)
        .fixedSize()
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(level.color.opacity(0.14), in: Capsule())
    }
}
