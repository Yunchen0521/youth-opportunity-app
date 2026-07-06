# 遠端機會資料

App 會優先抓遠端的 `opportunities.json`,失敗自動退回 App 內建版本(所以離線一定能用)。
更新這個檔,**不用改版、不用重新上架就能更新機會清單**。

## 單一 repo:程式與資料同處

程式碼和資料都在同一個 repo(`youth-opportunity-app`)。App 讀的遠端資料就是這個 repo 裡的
`data/opportunities.json`。

App 指向的網址(`OpportunityMap/Services/OpportunityService.swift`):

```
https://raw.githubusercontent.com/Yunchen0521/youth-opportunity-app/main/data/opportunities.json
```

## 之後要更新資料

編輯這個 repo 的 `data/opportunities.json`(記得把 `version` / `updatedAt` 一起更新)並推上 GitHub,
使用者下次開啟或在探索頁下拉重新整理就會拿到新資料——「我的」分頁會顯示最新版本與更新日期。

> 注意:App 內建的 `OpportunityMap/Resources/opportunities.json` 是離線 fallback,
> 建議跟 `data/opportunities.json` 保持大致同步,避免沒網路時看到太舊的清單。
