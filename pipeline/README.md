# 資料管線

把各官網公告自動變成 App 讀得懂的結構化資料。

```
sources.json（來源清單）
   ↓  逐一抓網頁（requests）
   ↓  LLM 解析成 Opportunity 結構（目前用 Gemini，免費額度）
   ↓  去重合併（只加新的，不覆蓋既有手工策展資料）
data/opportunities.json  →  App 從遠端抓到、自動更新
```

## 檔案

- **`sources.json`**：要抓的來源清單（名稱、網址、sourceType、預設主辦）。要加來源就編這個檔。
- **`extract.py`**：主程式。★ 換 AI 供應商只要改裡面的 `llm_extract()` 一個函式。
- **`../.github/workflows/update-data.yml`**：GitHub Actions，手動觸發跑 `extract.py`，有變更就自動 commit。

## 用哪個 AI（目前 Gemini，免費）

`llm_extract()` 目前用 **Google Gemini**：有免費額度、申請金鑰**不用綁信用卡**。
到 <https://aistudio.google.com/apikey> 申請一把,環境變數用 `GEMINI_API_KEY`。

之後想換 **GPT** 或 **Claude**：只改 `extract.py` 的 `llm_extract()` 那一段，其餘流程不動。

## 本機試跑

```bash
cd pipeline
pip install -r requirements.txt
export GEMINI_API_KEY=...      # 從 aistudio.google.com/apikey 申請（免費）
python extract.py --dry-run    # 只印出會新增哪些，不寫檔
python extract.py              # 實際合併寫回 data/opportunities.json
```

## 用 GitHub Actions 跑（手動觸發）

1. repo **Settings → Secrets and variables → Actions → New repository secret**，
   新增 `GEMINI_API_KEY`（值為你的 Gemini 金鑰）。
2. **Actions** 分頁 → 選「更新機會資料」→ 按 **Run workflow**。
3. 跑完若有新資料，會自動 commit 回 `data/opportunities.json`，App 下次開啟即更新。

想改成**每天自動跑**：把 `update-data.yml` 裡 `schedule` 兩行的註解拿掉即可。

## 去重原則

以「標題正規化後」比對：已存在的**跳過**（保留手工策展的版本），只加**全新**的機會。
所以重複跑不會洗掉或洗爛既有資料，只會補進新項目。

## 還沒做（之後可加）

- **enrichment**：跟著計畫連結再抓一層，補金額 / 截止日 / 座標（目前這些常是 null）。
- **更多來源**：把 `source-registry.md` 裡其他 P1/P2 來源逐一加進 `sources.json`。
