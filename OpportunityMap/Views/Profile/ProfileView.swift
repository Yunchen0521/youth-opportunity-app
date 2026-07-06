import SwiftUI

/// 個人中心：設定我的條件（供推薦與 AI 判讀），並顯示 App 資訊。
struct ProfileView: View {
    @Environment(OpportunityStore.self) private var store
    @Environment(ProfileStore.self) private var profileStore

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
                    Text("我的條件")
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

                Section("即將推出") {
                    Label("截止提醒推播", systemImage: "bell")
                }
                .foregroundStyle(.secondary)
            }
            .navigationTitle("我的")
        }
    }
}
