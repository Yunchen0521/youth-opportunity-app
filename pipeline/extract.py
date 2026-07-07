"""
青年機會資料管線

流程：讀 sources.json → 逐一抓網頁 → 用 LLM 解析成 Opportunity 結構 →
去重合併進 data/opportunities.json（只加新的，不覆蓋既有的手工策展資料）。

目前用 Google Gemini（有免費額度、不用綁卡）。
★ 想換成 GPT 或 Claude：只要改下面的 `llm_extract()` 這一個函式即可，其餘不動。

本機執行：
    pip install -r requirements.txt
    export GEMINI_API_KEY=...        # 從 https://aistudio.google.com/apikey 申請（免費）
    python extract.py                # 抓 + 合併，寫回 data/opportunities.json
    python extract.py --dry-run      # 只印出會新增哪些，不寫檔

CI：由 .github/workflows/update-data.yml 呼叫（手動觸發），有變更才 commit。
"""

import argparse
import datetime
import hashlib
import json
import re
from pathlib import Path

import requests
from bs4 import BeautifulSoup
from google import genai
from google.genai import types

BASE = Path(__file__).resolve().parent
REPO = BASE.parent
SOURCES_PATH = BASE / "sources.json"
DATA_PATH = REPO / "data" / "opportunities.json"

SYSTEM = """你是青年機會資料擷取器。從給定的網頁文字中，抽出所有「青年機會」計畫。

規則：
- category 擇一：subsidy(補助) competition(競賽) internship(實習) startup(創業) training(培力) exchange(海外交流) scholarship(獎學金) grant(圓夢/行動補助) venue(常設據點) platform(資源平台)
- summary：兩三句話的中文摘要，講清楚給誰、給什麼、怎麼申請
- eligibility：minAge/maxAge 沒寫就 null；identities 從「學生 / 社會新鮮人 / 創業者 / 不限」中選；regions 用「全國」或縣市名
- deadline / applyStartDate：格式 yyyy-mm-dd；未知、長期開放或年度徵件則給 null
- website：該計畫的官方連結；找不到就用來源網址
- 只抽真正出現在文字裡的計畫，找不到的欄位給 null 或空陣列，絕對不要編造內容

只輸出 JSON，結構如下：
{"opportunities": [
  {
    "title": "字串",
    "category": "上述類別之一",
    "organizer": "主辦單位",
    "summary": "兩三句摘要",
    "description": "較完整說明",
    "amount": "金額字串或 null",
    "deadline": "yyyy-mm-dd 或 null",
    "applyStartDate": "yyyy-mm-dd 或 null",
    "website": "官方連結",
    "eligibility": {"minAge": 數字或null, "maxAge": 數字或null, "identities": ["..."], "regions": ["..."]}
  }
]}
"""


def fetch_text(url: str) -> str:
    resp = requests.get(url, timeout=30, headers={"User-Agent": "Mozilla/5.0"})
    resp.raise_for_status()
    soup = BeautifulSoup(resp.text, "html.parser")
    for tag in soup(["script", "style", "nav", "footer", "header"]):
        tag.decompose()
    return soup.get_text("\n", strip=True)


# ── 換供應商只改這裡 ─────────────────────────────────────────────
def llm_extract(client: genai.Client, text: str, source: dict) -> list[dict]:
    """把網頁文字交給 LLM，回傳結構化的機會清單。目前用 Gemini。"""
    prompt = (f"來源：{source['name']}（sourceType={source['sourceType']}、"
              f"預設主辦：{source['organizer']}）\n\n網頁文字：\n{text[:20000]}")
    resp = client.models.generate_content(
        model="gemini-2.5-flash",     # 免費額度機型
        contents=prompt,
        config=types.GenerateContentConfig(
            system_instruction=SYSTEM,
            temperature=0,
            response_mime_type="application/json",
        ),
    )
    return json.loads(resp.text).get("opportunities", [])
# ─────────────────────────────────────────────────────────────────


def make_id(title: str, source_name: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", f"{source_name}-{title}".lower()).strip("-")
    if len(slug) < 4:
        slug = "opp-" + hashlib.md5(f"{source_name}-{title}".encode()).hexdigest()[:10]
    return slug


def norm_title(t: str) -> str:
    """正規化標題用於去重（去空白、轉小寫）。"""
    return re.sub(r"\s+", "", t).lower()


def bump(version: str) -> str:
    parts = version.split(".")
    try:
        parts[-1] = str(int(parts[-1]) + 1)
        return ".".join(parts)
    except ValueError:
        return version


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true", help="只印出會新增哪些，不寫檔")
    args = parser.parse_args()

    sources = json.loads(SOURCES_PATH.read_text(encoding="utf-8"))
    feed = json.loads(DATA_PATH.read_text(encoding="utf-8"))
    seen = {norm_title(o["title"]) for o in feed["opportunities"]}   # 現有標題（去重用）

    client = genai.Client()   # 讀 GEMINI_API_KEY 環境變數
    added = 0

    for src in sources:
        print(f"抓取：{src['name']} …", flush=True)
        try:
            items = llm_extract(client, fetch_text(src["url"]), src)
        except Exception as error:               # 單一來源失敗不影響其他來源
            print(f"  ⚠️ 略過（{error}）", flush=True)
            continue

        for item in items:
            key = norm_title(item.get("title", ""))
            if not key or key in seen:
                continue                          # 去重：已存在就跳過（保留手工策展版本）
            item["id"] = make_id(item["title"], src["name"])
            item["sourceType"] = src["sourceType"]
            item["location"] = None               # 座標留給之後 enrichment
            feed["opportunities"].append(item)
            seen.add(key)
            added += 1
            print(f"  ＋ 新增：{item['title']}", flush=True)

    if added == 0:
        print("\n沒有新資料（全部已存在或抓取失敗），檔案未變更。")
        return

    if args.dry_run:
        print(f"\n[dry-run] 會新增 {added} 筆，未寫檔。")
        return

    feed["version"] = bump(feed.get("version", "0.0.0"))
    feed["updatedAt"] = datetime.date.today().isoformat()
    DATA_PATH.write_text(json.dumps(feed, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"\n新增 {added} 筆 → 總計 {len(feed['opportunities'])} 筆，"
          f"v{feed['version']}，已寫入 {DATA_PATH.relative_to(REPO)}")


if __name__ == "__main__":
    main()
