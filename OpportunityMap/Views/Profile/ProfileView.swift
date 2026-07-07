import SwiftUI

/// 個人中心：設定我的條件（供推薦與 AI 判讀），並顯示 App 資訊。
struct ProfileView: View {
    @Environment(OpportunityStore.self) private var store
    @Environment(ProfileStore.self) private var profileStore
    @State private var showExplanation = false
    @State private var contentHeight: CGFloat = 340   // 內部內容量測高度（不含導覽列）

    var body: some View {
        @Bindable var profileStore = profileStore
        NavigationStack {
            Form {
                Section {
                    Picker("年齡", selection: $profileStore.profile.age) {
                        Text("未設定").tag(Int?.none)
                        ForEach(15...45, id: \.self) { age in
                            Text("\(age) 歲").tag(Int?.some(age))
                        }
                    }
                    Picker("身分", selection: $profileStore.profile.identity) {
                        Text("未設定").tag(UserIdentity?.none)
                        ForEach(UserIdentity.allCases) { identity in
                            Text(identity.displayName).tag(UserIdentity?.some(identity))
                        }
                    }
                    Picker("所在地區", selection: $profileStore.profile.region) {
                        Text("未設定").tag(String?.none)
                        ForEach(TaiwanRegion.all, id: \.self) { region in
                            Text(region).tag(String?.some(region))
                        }
                    }
                } header: {
                    HStack(spacing: 6) {
                        Text("我的條件")
                        Button {
                            showExplanation = true
                        } label: {
                            Label("適配度說明", systemImage: "info.circle")
                                .labelStyle(.iconOnly)
                        }
                        .buttonStyle(.borderless)
                        Spacer()
                    }
                } footer: {
                    Text("填寫後，探索頁可依適配度為你排序，詳情頁也會給 AI 判讀。資料只存在本機。")
                }

                Section("關於") {
                    LabeledContent("App", value: "青機會 Opportunity Map")
                    LabeledContent("目前機會", value: "\(store.all.count) 筆")
                    LabeledContent("資料版本", value: store.dataVersion ?? "—")
                    if let updated = store.dataUpdatedAt {
                        LabeledContent("資料更新", value: updated)
                    }
                }

                Section("資料來源") {
                    Text("整合政府、基金會與企業提供的青年機會。所有資訊以各官方網站最新公告為準，App 僅整理與導流，申請請以官網為準。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("我的")
            .sheet(isPresented: $showExplanation) {
                NavigationStack {
                    ScrollView {
                        MatchExplanationView()
                            .padding()
                            .onGeometryChange(for: CGFloat.self) { proxy in
                                proxy.size.height
                            } action: { newValue in
                                contentHeight = newValue
                            }
                    }
                    .navigationTitle("適配度說明")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("完成") { showExplanation = false }
                        }
                    }
                }
                // 內容高度 + 導覽列（約 60pt）→ 貼合；ScrollView 保底避免估太緊被裁切
                .presentationDetents([.height(contentHeight + 60)])
                .presentationDragIndicator(.visible)
            }
        }
    }
}
