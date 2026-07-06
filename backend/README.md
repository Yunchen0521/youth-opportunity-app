# AI 顧問後端 proxy

把「使用者 Profile + 機會」轉成 prompt、呼叫 Claude、回傳一句判讀。
金鑰 `ANTHROPIC_API_KEY` 只存在這裡，**不進 App**。

## 部署（一次性）

需要一個 [Cloudflare](https://dash.cloudflare.com/sign-up) 帳號（免費方案即可）。

```bash
cd backend

# 1. 登入 Cloudflare（會開瀏覽器）
npx wrangler login

# 2. 設定 Anthropic 金鑰（不會存進檔案，存在 Cloudflare secret）
npx wrangler secret put ANTHROPIC_API_KEY
#   貼上你的 sk-ant-... 金鑰

# 3. 部署
npx wrangler deploy
```

部署完成後會印出網址，例如：

```
https://youth-opportunity-advisor.你的帳號.workers.dev
```

## 接回 App

把上面的網址填進
`OpportunityMap/Services/RecommendationService.swift` 的 `BackendAdvisor.endpoint`，
記得結尾加上 `/advise`：

```swift
static let endpoint = URL(string: "https://youth-opportunity-advisor.你的帳號.workers.dev/advise")!
```

## 本地測試

```bash
npx wrangler dev
# 另開一個終端：
curl -X POST http://localhost:8787/advise \
  -H "content-type: application/json" \
  -d '{
    "profile": { "age": 22, "identity": "學生", "region": "臺北市" },
    "opportunity": {
      "title": "青年海外和平工作團",
      "category": "海外交流",
      "organizer": "教育部青年署",
      "summary": "補助青年赴海外從事志願服務。",
      "ageText": "18–35 歲",
      "identities": ["學生", "社會新鮮人"],
      "regions": ["全國"],
      "amount": "每案最高 30 萬元"
    }
  }'
```

## 成本備註

`worker.js` 預設用 `claude-opus-4-8`。每次判讀約 300～500 tokens，成本很低。
若想再省，把 `model` 改成 `claude-haiku-4-5` 即可（短建議 Haiku 也很夠用）。
