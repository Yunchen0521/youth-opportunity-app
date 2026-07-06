# 遠端機會資料

App 會優先抓遠端的 `opportunities.json`,失敗自動退回 App 內建版本(所以離線一定能用)。
把資料放上 GitHub 後,**不用改版、不用重新上架就能更新機會清單**。

## App 目前指向的網址

`OpportunityMap/Services/OpportunityService.swift`：

```
https://raw.githubusercontent.com/Yunchen0521/opportunity-youth/main/opportunities.json
```

代表 repo = `github.com/Yunchen0521/opportunity-youth`、分支 `main`、根目錄放 `opportunities.json`。
（若你的 GitHub 帳號不是 `Yunchen0521`,改這行 `remoteURL` 即可。）

## 建立步驟(一次性)

1. 在 GitHub 建一個 **public** repo,名稱 `opportunity-youth`。
2. 把這個資料夾的 `opportunities.json` 上傳到 repo 根目錄(直接在網頁上 Upload files 也行)。
3. 完成。App 下次啟動或在探索頁下拉重新整理,就會抓到遠端版本。

## 之後要更新資料

只要編輯 repo 裡的 `opportunities.json`(記得把 `version` / `updatedAt` 一起更新),使用者下次開啟就會拿到新資料——「我的」分頁會顯示最新的資料版本與更新日期。

> 注意:App 內建的 `OpportunityMap/Resources/opportunities.json` 是離線 fallback,
> 建議跟遠端保持大致同步,避免沒網路時看到太舊的清單。
