"""
青年機會資料管線 — 雛形 (prototype)

一句話：抓一個來源網頁 → 用 Claude 解析成 App 的 Opportunity 結構 → 輸出 JSON。

目前只接「台灣就業通 投資青年就業方案」一個來源，用來把整條流程跑通。
之後可擴充：讀 data/source-registry.md 的多來源、去重合併、GitHub Actions 每日排程、
把結果 commit 到 GitHub（App 隔天自動抓到）。

執行：
    pip install -r requirements.txt
    export ANTHROPIC_API_KEY=sk-ant-...
    python extract.py                 # 印出解析結果
    python extract.py --out feed.json # 存成檔案
"""

import argparse
import datetime
import hashlib
import json
import re

import requests
from bs4 import BeautifulSoup
from anthropic import Anthropic

# 先接一個已驗證、好爬、又能一次產出多筆的來源。
SOURCE = {
    "name": "台灣就業通 投資青年就業方案",
    "url": "https://youth.taiwanjobs.gov.tw/CompletePlan",
    "sourceType": "government",   # government / foundation / company
    "organizer": "勞動部勞動力發展署",
}

# 交給 Claude 的目標結構（對齊 App 的 Opportunity 模型；id/sourceType/location 由程式補）。
SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "required": ["opportunities"],
    "properties": {
        "opportunities": {
            "type": "array",
            "items": {
                "type": "object",
                "additionalProperties": False,
                "required": [
                    "title", "category", "organizer", "summary", "description",
                    "amount", "deadline", "applyStartDate", "website", "eligibility",
                ],
                "properties": {
                    "title": {"type": "string"},
                    "category": {
                        "type": "string",
                        "enum": ["subsidy", "competition", "internship", "startup",
                                 "training", "exchange", "scholarship", "grant",
                                 "venue", "platform"],
                    },
                    "organizer": {"type": "string"},
                    "summary": {"type": "string"},
                    "description": {"type": "string"},
                    "amount": {"type": ["string", "null"]},
                    "deadline": {"type": ["string", "null"]},        # yyyy-mm-dd 或 null
                    "applyStartDate": {"type": ["string", "null"]},
                    "website": {"type": "string"},
                    "eligibility": {
                        "type": "object",
                        "additionalProperties": False,
                        "required": ["minAge", "maxAge", "identities", "regions"],
                        "properties": {
                            "minAge": {"type": ["integer", "null"]},
                            "maxAge": {"type": ["integer", "null"]},
                            "identities": {"type": "array", "items": {"type": "string"}},
                            "regions": {"type": "array", "items": {"type": "string"}},
                        },
                    },
                },
            },
        }
    },
}

SYSTEM = """你是青年機會資料擷取器。從給定的網頁文字中，抽出所有「青年機會」計畫，輸出成指定 JSON schema。

規則：
- category 擇一：subsidy(補助) competition(競賽) internship(實習) startup(創業) training(培力) exchange(海外交流) scholarship(獎學金) grant(圓夢/行動補助) venue(常設據點) platform(資源平台)
- summary：兩三句話的中文摘要，講清楚給誰、給什麼、怎麼申請
- eligibility：minAge/maxAge 沒寫就 null；identities 從「學生 / 社會新鮮人 / 創業者 / 不限」中選；regions 用「全國」或縣市名
- deadline / applyStartDate：格式 yyyy-mm-dd；未知、長期開放或年度徵件則給 null
- website：該計畫的官方連結；找不到就用來源網址
- 只抽真正出現在文字裡的計畫，找不到的欄位給 null 或空陣列，絕對不要編造內容
"""


def fetch_text(url: str) -> str:
    """抓網頁、去掉 script/style/導覽，回傳純文字。"""
    resp = requests.get(url, timeout=30, headers={"User-Agent": "Mozilla/5.0"})
    resp.raise_for_status()
    soup = BeautifulSoup(resp.text, "html.parser")
    for tag in soup(["script", "style", "nav", "footer", "header"]):
        tag.decompose()
    return soup.get_text("\n", strip=True)


def extract(text: str, source: dict) -> list[dict]:
    """把網頁文字丟給 Claude，回傳結構化的機會清單。"""
    client = Anthropic()  # 讀 ANTHROPIC_API_KEY 環境變數
    user = (
        f"來源：{source['name']}（sourceType={source['sourceType']}、"
        f"預設主辦：{source['organizer']}）\n\n網頁文字：\n{text[:20000]}"
    )
    resp = client.messages.create(
        # 預設用 opus-4-8；要壓成本可改 "claude-haiku-4-5"（批次擷取 Haiku 也夠用）。
        model="claude-opus-4-8",
        max_tokens=8000,
        system=SYSTEM,
        messages=[{"role": "user", "content": user}],
        output_config={"format": {"type": "json_schema", "schema": SCHEMA}},
    )
    raw = next(b.text for b in resp.content if b.type == "text")
    return json.loads(raw)["opportunities"]


def make_id(title: str, source_name: str) -> str:
    """從標題產生穩定 id；中文標題 slug 會是空的，改用雜湊。"""
    slug = re.sub(r"[^a-z0-9]+", "-", f"{source_name}-{title}".lower()).strip("-")
    if len(slug) < 4:
        slug = "opp-" + hashlib.md5(f"{source_name}-{title}".encode()).hexdigest()[:10]
    return slug


def to_feed(raw_items: list[dict], source: dict) -> dict:
    """補上 id / sourceType / location，包成 App 讀的 OpportunityFeed 格式。"""
    opportunities = []
    for it in raw_items:
        it["id"] = make_id(it["title"], source["name"])
        it["sourceType"] = source["sourceType"]
        it["location"] = None       # 雛形先不處理座標
        opportunities.append(it)
    return {
        "version": "pipeline-proto",
        "updatedAt": datetime.date.today().isoformat(),
        "note": f"由管線雛形自動擷取，來源：{source['name']}",
        "opportunities": opportunities,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", help="輸出檔路徑；不給就印到畫面")
    args = parser.parse_args()

    print(f"抓取：{SOURCE['url']} …")
    text = fetch_text(SOURCE["url"])
    print(f"取得 {len(text)} 字，交給 Claude 解析 …")
    items = extract(text, SOURCE)
    feed = to_feed(items, SOURCE)
    print(f"解析出 {len(feed['opportunities'])} 筆機會。\n")

    output = json.dumps(feed, ensure_ascii=False, indent=2)
    if args.out:
        with open(args.out, "w", encoding="utf-8") as f:
            f.write(output)
        print(f"已寫入 {args.out}")
    else:
        print(output)


if __name__ == "__main__":
    main()
