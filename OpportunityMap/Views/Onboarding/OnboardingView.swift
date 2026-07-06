import SwiftUI

/// 首次開啟的引導流程：介紹 App，並順手收集使用者條件（讓推薦立即可用）。
struct OnboardingView: View {
    @Environment(ProfileStore.self) private var profileStore
    var onFinish: () -> Void

    @State private var step = 0

    var body: some View {
        @Bindable var profileStore = profileStore
        ZStack {
            SoftBackground()
            VStack(spacing: 0) {
                TabView(selection: $step) {
                    welcomePage.tag(0)
                    profilePage(age: $profileStore.profile.age,
                                identity: $profileStore.profile.identity,
                                region: $profileStore.profile.region).tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                bottomBar
            }
        }
    }

    // MARK: - 第一頁：歡迎 + 功能亮點

    private var welcomePage: some View {
        VStack(spacing: 28) {
            Spacer()
            Image(systemName: "sparkle.magnifyingglass")
                .font(.system(size: 64))
                .foregroundStyle(Color.accentColor)

            VStack(spacing: 6) {
                Text("青機會")
                    .font(.largeTitle.bold())
                Text("CREATE YOUR OPPORTUNITY")
                    .font(.caption.weight(.semibold))
                    .tracking(2)
                    .foregroundStyle(Color.accentColor)
                Text("一站看完政府、基金會與企業的青年機會")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }

            VStack(alignment: .leading, spacing: 18) {
                featureRow("square.grid.2x2", "探索與篩選", "補助、競賽、實習、獎學金一次搜")
                featureRow("map", "地圖找據點", "看看你附近有哪些實體機會")
                featureRow("sparkles", "AI 為你推薦", "依你的條件排序，並判讀適不適合")
            }
            .padding(.horizontal, 12)

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private func featureRow(_ symbol: String, _ title: String, _ subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle).font(.footnote).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: - 第二頁：設定條件

    private func profilePage(
        age: Binding<Int?>,
        identity: Binding<UserIdentity?>,
        region: Binding<String?>
    ) -> some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 56))
                .foregroundStyle(Color.accentColor)

            VStack(spacing: 8) {
                Text("設定你的條件")
                    .font(.title.bold())
                Text("填好後就能為你排序推薦、判讀適配度。之後也可以在「我的」修改。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 0) {
                pickerRow("年齡") {
                    Picker("年齡", selection: age) {
                        Text("未設定").tag(Int?.none)
                        ForEach(15...45, id: \.self) { Text("\($0) 歲").tag(Int?.some($0)) }
                    }
                }
                Divider()
                pickerRow("身分") {
                    Picker("身分", selection: identity) {
                        Text("未設定").tag(UserIdentity?.none)
                        ForEach(UserIdentity.allCases) { Text($0.displayName).tag(UserIdentity?.some($0)) }
                    }
                }
                Divider()
                pickerRow("所在地區") {
                    Picker("所在地區", selection: region) {
                        Text("未設定").tag(String?.none)
                        ForEach(TaiwanRegion.all, id: \.self) { Text($0).tag(String?.some($0)) }
                    }
                }
            }
            .padding(.horizontal, 4)
            .softGlass(cornerRadius: 16)

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private func pickerRow<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(label).font(.body)
            Spacer()
            content()
                .labelsHidden()
                .tint(.accentColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - 底部控制列

    @ViewBuilder private var bottomBar: some View {
        VStack(spacing: 12) {
            Button {
                if step == 0 {
                    withAnimation { step = 1 }
                } else {
                    onFinish()
                }
            } label: {
                Text(step == 0 ? "開始" : "完成")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)

            if step == 1 {
                Button("略過，稍後再設定") { onFinish() }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 20)
    }
}
