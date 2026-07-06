import SwiftData
import SwiftUI

/// 機會詳情頁：摘要、內容、結構化資格，底部可收藏與前往官網。
struct OpportunityDetailView: View {
    let opportunity: Opportunity

    @Environment(\.modelContext) private var context
    @Environment(\.openURL) private var openURL
    @Environment(ProfileStore.self) private var profileStore
    @Query private var favorites: [FavoriteOpportunity]

    private var isFavorite: Bool { favorites.contains { $0.id == opportunity.id } }

    @State private var reminderOn = false
    @State private var reminderAlert: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                if profileStore.profile.hasCriteria {
                    MatchCard(opportunity: opportunity, profile: profileStore.profile)
                } else {
                    profilePromptCard
                }
                card(title: "三句話摘要") { Text(opportunity.summary) }
                card(title: "計畫內容") { Text(opportunity.description) }
                detailsCard
            }
            .padding(20)
            .padding(.bottom, 90)
        }
        .background(SoftBackground())
        .navigationTitle(opportunity.category.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { bottomBar }
        .task { reminderOn = await ReminderService.shared.isScheduled(for: opportunity.id) }
        .alert("無法設定提醒",
               isPresented: Binding(get: { reminderAlert != nil },
                                    set: { if !$0 { reminderAlert = nil } }),
               presenting: reminderAlert) { _ in
            Button("好", role: .cancel) {}
        } message: { Text($0) }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                TagChip(text: opportunity.category.displayName, accent: true)
                TagChip(text: opportunity.sourceType.displayName)
            }
            Text(opportunity.title)
                .font(.title2.bold())
            Text(opportunity.organizer)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func card<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            content()
                .font(.body)
                .foregroundStyle(.primary.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .softGlass(cornerRadius: 14)
    }

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            infoRow("適用年齡", opportunity.eligibility.ageText)
            Divider()
            infoRow("適用身分", opportunity.eligibility.identities.joined(separator: "、"))
            Divider()
            infoRow("適用地區", opportunity.eligibility.regions.joined(separator: "、"))
            if let amount = opportunity.amount {
                Divider(); infoRow("金額", amount)
            }
            if let deadline = opportunity.deadline {
                Divider(); infoRow("截止日期", deadline.formatted(date: .abbreviated, time: .omitted))
            } else {
                Divider(); infoRow("截止日期", "依官網最新公告（年度徵件 / 長期開放）")
            }
            if let location = opportunity.location {
                Divider(); infoRow("地點", location.address)
            }
        }
        .padding(16)
        .softGlass(cornerRadius: 14)
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 76, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 10)
    }

    private var profilePromptCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.title2)
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 2) {
                Text("想知道適不適合你？")
                    .font(.subheadline.weight(.semibold))
                Text("到「我的」分頁設定年齡與身分，即可看到適配度與 AI 建議。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .softGlass(cornerRadius: 14)
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            Button {
                toggleFavorite()
            } label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.title3)
                    .frame(width: 52, height: 52)
                    .softGlass(cornerRadius: 14)
                    .foregroundStyle(isFavorite ? .pink : .primary)
            }

            if opportunity.deadline != nil {
                Button {
                    Task { await toggleReminder() }
                } label: {
                    Image(systemName: reminderOn ? "bell.fill" : "bell")
                        .font(.title3)
                        .frame(width: 52, height: 52)
                        .softGlass(cornerRadius: 14)
                        .foregroundStyle(reminderOn ? Color.accentColor : .primary)
                }
            }

            Button {
                if let url = URL(string: opportunity.website) { openURL(url) }
            } label: {
                Label("前往官方網站", systemImage: "safari")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.bar)
    }

    private func toggleFavorite() {
        if let existing = favorites.first(where: { $0.id == opportunity.id }) {
            context.delete(existing)
        } else {
            context.insert(FavoriteOpportunity(from: opportunity))
        }
        try? context.save()
    }

    private func toggleReminder() async {
        if reminderOn {
            ReminderService.shared.cancel(for: opportunity.id)
            reminderOn = false
            return
        }
        switch await ReminderService.shared.schedule(for: opportunity) {
        case .scheduled:
            reminderOn = true
        case .denied:
            reminderAlert = "請到「設定 › 通知」開啟本 App 的通知權限，才能收到截止提醒。"
        case .pastDeadline:
            reminderAlert = "這個機會已過截止日，無法設定提醒。"
        case .noDeadline:
            reminderAlert = "這個機會沒有明確截止日（長期開放或年度徵件），無法設定提醒。"
        case .failed:
            reminderAlert = "設定提醒失敗，請稍後再試。"
        }
    }
}

// MARK: - MatchCard

/// 「這個機會適不適合我」卡片：本地適配結果（即時）＋ AI 判讀（非同步載入）。
struct MatchCard: View {
    let opportunity: Opportunity
    let profile: UserProfile
    var advisor: OpportunityAdvisor = Advisors.default

    @State private var advice: String?
    @State private var isLoading = false
    @State private var loadFailed = false

    private var match: MatchResult { MatchEngine.evaluate(opportunity, for: profile) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("這個機會適不適合我")
                    .font(.headline)
                Spacer()
                MatchBadge(level: match.level)
            }

            ForEach(match.reasons, id: \.self) { reason in
                Label(reason, systemImage: "checkmark")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Divider()
            aiSection
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .softGlass(cornerRadius: 14)
        .task(id: opportunity.id) { await loadAdvice() }
    }

    @ViewBuilder private var aiSection: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles").foregroundStyle(.tint)
            Text("AI 顧問").font(.subheadline.weight(.semibold))
        }

        if isLoading {
            HStack(spacing: 8) {
                ProgressView()
                Text("分析中…").font(.footnote).foregroundStyle(.secondary)
            }
        } else if let advice {
            Text(advice)
                .font(.callout)
                .foregroundStyle(.primary.opacity(0.9))
        } else if loadFailed {
            Button {
                Task { await loadAdvice(force: true) }
            } label: {
                Label("重新產生 AI 建議", systemImage: "arrow.clockwise")
                    .font(.footnote)
            }
        }
    }

    private func loadAdvice(force: Bool = false) async {
        if advice != nil && !force { return }
        isLoading = true
        loadFailed = false
        defer { isLoading = false }
        do {
            advice = try await advisor.advise(opportunity: opportunity, profile: profile, match: match)
        } catch {
            loadFailed = true
        }
    }
}
