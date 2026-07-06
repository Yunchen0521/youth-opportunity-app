# 資料管線（雛形）

把「散在各官網的公告」自動變成 App 讀得懂的結構化 JSON。

## 這條線在做什麼

```
抓來源網頁  →  Claude 解析成 Opportunity 結構  →  輸出 OpportunityFeed JSON
（requests）    （structured outputs，對齊 App 模型）   （之後 commit 到 GitHub，App 自動更新）
```

- **`extract.py`**：雛形主程式。目前只接一個已驗證的來源（台灣就業通 投資青年就業方案），
  用來把整條流程跑通。
- **為什麼用 Claude**：把自由格式的公告（誰能申請、截止日、金額…）抽成固定欄位，正是 LLM 最擅長、
  也是履歷「AI-assisted Development」的實際展示。用 structured outputs 保證輸出一定符合 schema。

## 試跑

```bash
cd pipeline
pip install -r requirements.txt
export ANTHROPIC_API_KEY=sk-ant-...      # 用你自己的 API 金鑰（會計費，一次幾塊台幣）
python extract.py                        # 印出解析結果
python extract.py --out feed.json        # 存成檔案看看
```

輸出就是 App 讀的 `OpportunityFeed` 格式（`version` / `updatedAt` / `opportunities[]`）。

## 這只是雛形 — 還沒做的（之後統一深入）

- **多來源**：改成讀 `../data/source-registry.md` 的 P1 清單，逐一擷取。
- **去重與合併**：跨來源、跨天的重複計畫要合併，不是每天蓋掉。
- **驗證**：日期/金額格式檢查、明顯錯誤過濾。
- **座標**：venue 類的實體據點補經緯度（給地圖用）。
- **自動排程**：GitHub Actions 每日跑一次，把結果 commit 到資料 repo → App 隔天自動更新。
- **成本**：批次擷取可把 `extract.py` 的 model 改成 `claude-haiku-4-5` 省錢。

> 現階段目的只是「跑通一條」，證明「網頁 → AI 解析 → App 格式」這條路可行。
> 規模化（涵蓋 registry 裡的主要來源）是把這支腳本重複套用到更多來源而已。
