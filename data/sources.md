# Opportunity Map Taiwan — v1 種子資料來源清單

> 查證日期：2026-06-16。所有計畫均經官方網站查證。
> 金額/截止日逐年微調，策展入庫時以各官網最新簡章為準；資料標註「每年固定徵件」並追蹤次年度開徵。
> `地圖` 欄：✅=有實體場域可標座標；➖=線上/全國性，只進列表不進地圖。

---

## ★ v1 核心 12 筆（先策展、走通全流程）

涵蓋 3 種來源、8+2 類別、地圖✅/列表➖兼具的驗證集。其餘 21 筆與地圖據點列為第二批擴充。

1. Jamie's Gapyear Program — grant / company / ➖
2. 雲門流浪者計畫 — grant / foundation / ➖
3. 青年百億海外圓夢基金 Pathfinder — grant / government / ➖
4. U-start 創新創業計畫 — startup / government / ✅
5. 青年社區參與行動 Changemaker — competition / government / ✅
6. 總統盃黑客松 — competition / government / ✅
7. 大專生公部門見習計畫 — internship / government / ✅
8. 學海築夢 — exchange / government / ✅
9. 教育部留學獎學金甄試 — scholarship / government / ➖
10. 支援青年就業計畫 — subsidy / government / ➖
11. 林口新創園 Startup Terrace — **venue（常設據點）** / government / ✅
12. RICH 職場體驗網 — **platform（資源平台）** / government / ➖

### 已拍板決策（影響資料模型與收錄）
- **年齡不硬性 gate**：min/max age 只當篩選欄位，收錄 15–45+ 皆可（AAMA、青創貸款、KEEP WALKING 等超 35 歲計畫可納第二批）。
- **新增 `venue` 類**：各縣市創業基地等常設據點（無截止日、有座標），作為地圖輔助主力 → 第二批納入 I 區據點。
- **新增 `platform` 類**：RICH、新創圓夢網等資源平台入口（無座標無截止日，純導流）。

---

## A. 圓夢 / 行動補助 grant（最貼近「贊助你去實現計畫」的核心類型）

| 名稱 | 主辦 | sourceType | 年齡 | 身分 | 金額 | 週期 | 地圖 | 連結 |
|---|---|---|---|---|---|---|---|---|
| Jamie's Gapyear Program | 林之晨/AppWorks | company | ≤21 | 學生(休學) | 100萬(不需還) | 年度·約4/7截止 | ➖ | https://www.gapyear.tw/ |
| 雲門流浪者計畫 | 雲門文化藝術基金會 | foundation | 18–31 | 不限 | 最高15萬 | 年度·約6/30截止 | ➖ | https://www.cloudgate.org.tw/wanderer-project |
| KEEP WALKING 夢想資助計畫 | 帝亞吉歐 Diageo | company | ≥20 | 不限 | 總額約800萬/屆 | 年度·約12/15截止 | ➖ | https://www.keepwalkingfund.com.tw/ |
| 信義房屋 全民社造行動計畫 | 信義房屋 | company | 不限 | 不限 | 個人最高20萬/社區最高50萬 | 年度·約3/1–4/30 | ✅(提案落地) | https://www.taiwan4718.tw/ |
| 青年百億海外圓夢基金 Pathfinder | 教育部青年署 | government | 15–30 | 不限 | 最高150–200萬/案 | 年度·分梯 | ➖ | https://twpathfinder.org/ |
| 獎勵青年投入地方創生 | 國發會 | government | 22–45 | 團隊 | 最高35萬 | 年度·約至1/12 | ➖ | https://www.twrr.ndc.gov.tw/reward-youth |

## B. 創業 startup

| 名稱 | 主辦 | sourceType | 年齡 | 身分 | 金額 | 週期 | 地圖 | 連結 |
|---|---|---|---|---|---|---|---|---|
| U-start 創新創業計畫 | 教育部青年署 | government | 學籍 | 學生/應屆 | 約50萬/隊起 | 年度·約2/25截止 | ✅(校育成中心) | https://ustart.yda.gov.tw/ |
| 青年創業及啟動金貸款 | 經濟部中小新創署 | government | 20–45 | 創業者 | 最高約1,200萬(低利) | 長期開放 | ➖ | https://www.moeasmea.gov.tw/article-tw-2570-4238 |
| 林口新創園 Startup Terrace | 經濟部中小新創署 | government | 不限 | 新創團隊 | 空間/資源 | 長期開放 | ✅ 新北林口 | https://www.startupterrace.tw/ |
| 社企流 iLab 育成計畫 | 社企流 | foundation | 不限 | 社創團隊 | 課程/資源(非現金) | 分梯(現況待確認) | ✅ 台北 | https://ilab.seinsights.asia/ |

## C. 競賽 competition

| 名稱 | 主辦 | sourceType | 年齡 | 身分 | 金額 | 週期 | 地圖 | 連結 |
|---|---|---|---|---|---|---|---|---|
| 青年社區參與行動 Changemaker | 教育部青年署 | government | 18–35 | 團隊 | 每隊最高35萬 | 年度·約1–3月 | ✅(社區據點) | https://changemaker.yda.gov.tw/ |
| Young飛全球行動計畫 | 教育部青年署 | government | 18–35 | 不限(組隊) | 每隊最高80萬 | 年度·約1–3月 | ➖ | https://iyouth.youthhub.tw/youngfly/ |
| 青年壯遊臺灣–尋找感動地圖 | 教育部青年署 | government | 15–35 | 學生/青年 | 實踐獎金約2–8萬 | 年度·約1–3月 | ✅(全台壯遊點) | https://youthtravel.tw/ |
| 戰國策全國創新創業競賽 | 中華創業育成協會 | foundation | 18–35 | 學生/應屆/創業者 | 總獎金數十萬+進駐 | 年度·約3–6月 | ✅(新北青創基地) | https://www.2026ntpcstartup.com/ |
| 總統盃黑客松 | 行政院 | government | 不限 | 不限 | 卓越團隊每隊20萬 | 年度·約8–9月 | ✅(多縣市) | https://presidential-hackathon.taiwan.gov.tw/ |
| 金點新秀設計獎 | 經濟部/設研院 | government | 學籍 | 學生 | 最佳設計10萬等 | 年度·約3月截止 | ✅ 南港展覽館 | https://goldenpin.org.tw/goldenpin/zh-TW/participate/young-pin-design-award |
| AI CUP 全國大專AI競賽 | 教育部 | government | 學籍 | 學生 | 高額獎金 | 年度·春/秋多場 | ➖ | https://www.aicup.tw/ |
| 台積電青年築夢計畫 | 台積電文教基金會 | foundation | 大專/研究生 | 學生 | 總獎金300萬/屆 | 年度·約10月 | ➖ | https://www.tsmc-foundation.org/dreambuilder |

## D. 實習 internship

| 名稱 | 主辦 | sourceType | 年齡 | 身分 | 金額 | 週期 | 地圖 | 連結 |
|---|---|---|---|---|---|---|---|---|
| 大專生公部門見習計畫 | 教育部青年署 | government | ≤35 | 學生 | 學期/暑假帶薪 | 年度·分梯 | ✅(中央機關) | https://www.yda.gov.tw/plan.aspx?p=2019 |
| 後生行世界客家實習計畫 | 客委會 | government | 18–26 | 學生 | 個人5–15萬/案 | 年度·約6月截止 | ✅(海外) | https://www.hakkayouth.com.tw/ |
| 台北市青年實習津貼計畫 | 台北市青年局 | government | 15–35 | 在學 | 60/90日發1–3萬 | 年度·約至11/30 | ➖ | https://youth.gov.taipei/ |

## E. 培力 / 就業 training

| 名稱 | 主辦 | sourceType | 年齡 | 身分 | 金額 | 週期 | 地圖 | 連結 |
|---|---|---|---|---|---|---|---|---|
| 青年就業旗艦計畫 | 勞動部勞發署 | government | 15–29 | 缺經驗青年 | 補助企業訓練薪資 | 長期開放 | ✅(參訓企業) | https://www.wda.gov.tw/ |
| 產業新尖兵計畫 | 勞動部勞發署 | government | 15–29 | 失/待業青年 | 訓練費補助+月領8,000 | 年度·滾動開班 | ✅(訓練單位) | https://elite.taiwanjobs.gov.tw/ |

## F. 海外交流 exchange

| 名稱 | 主辦 | sourceType | 年齡 | 身分 | 金額 | 週期 | 地圖 | 連結 |
|---|---|---|---|---|---|---|---|---|
| 學海築夢(含新南向) | 教育部 | government | 學籍 | 大專在學 | 含國際機票 | 年度·2梯 | ✅(海外實習) | https://www.studyabroad.moe.gov.tw/ |
| 學海飛颺 | 教育部 | government | 學籍 | 大專在學 | 每人5–30萬 | 年度·分梯 | ➖ | https://www.studyabroad.moe.gov.tw/ |
| 國合會海外服務工作團 | 國合會 TaiwanICDF | government | 20–65 | 不限 | 含機票住宿 | 年度·約1–2月 | ✅(友邦) | https://www.icdf.org.tw/ |
| 外交部國際青年大使交流計畫 | 外交部 | government | 18–35 | 學生 | 政府籌組出訪 | 年度·約3–5月 | ✅(友邦) | https://youthambassador.tw/ |
| iYouth voice 青年國際發聲 | 教育部青年署 | government | 18–35 | 不限 | 上限20萬 | 年度·三階段 | ➖ | https://www.yda.gov.tw/plan.aspx?p=1020 |

## G. 獎學金 scholarship

| 名稱 | 主辦 | sourceType | 年齡 | 身分 | 金額 | 週期 | 地圖 | 連結 |
|---|---|---|---|---|---|---|---|---|
| 教育部留學獎學金甄試 | 教育部 | government | 不限 | 赴外攻讀學位青年 | 定額獎學金 | 年度·約1–2月截止 | ➖ | https://www.scholarship.moe.gov.tw/scholarship |
| 教育部公費留學考試 | 教育部 | government | 不限 | 具學歷國民 | 全額公費 | 年度 | ➖ | https://www.scholarship.moe.gov.tw/studyabroad/exam |
| 嘉新獎學金 | 嘉新兆福文化基金會 | foundation | 不限 | 清寒/身障學生 | 依辦法 | 年度·約至4/2 | ➖ | https://www.chf.ngo/ |
| 台達荷蘭環境獎學金 | 台達電子文教基金會 | company | 不限 | 赴荷蘭環境碩士 | 每名25萬 | 年度·約至4/30 | ➖ | https://www.delta-foundation.org.tw/project/15 |

## H. 就業 / 生活津貼 subsidy

| 名稱 | 主辦 | sourceType | 年齡 | 身分 | 金額 | 週期 | 地圖 | 連結 |
|---|---|---|---|---|---|---|---|---|
| 支援青年就業計畫 | 勞動部勞發署 | government | 15–29 | 初次尋職青年 | 尋職津貼+就業獎勵最高約4.8萬 | 長期開放 | ➖ | https://special.taiwanjobs.gov.tw/internet/2025/YNGSRH/page-05.html |
| 青年跨域就業津貼 | 勞動部勞發署 | government | 18–29 | 跨域就業 | 搬遷/租屋/交通津貼 | 長期開放 | ➖ | https://emps.wda.gov.tw/ |
| 青年生涯領航計畫 | 教育部 | government | 高中職畢 | 高中職應屆 | 月領1萬·最高28.5萬 | 年度·約11–2月 | ➖ | https://www.yda.gov.tw/planList.aspx?uid=93&pid=55 |

---

## I. 地圖實體據點候選（常設地點，無截止日 — 視「地圖內容」決策是否納入）

各縣市青年創業基地，最適合放在地圖上作為輔助內容：
- 台北青年職涯發展中心 TYS — 台北市仁愛路一段17號2樓
- 高雄 Pinway 青創試煉基地 — 高雄駁二8號倉庫(鹽埕區瀨南街8號)
- 桃園青創指揮部 — 中壢區環北路390號3樓
- 台中光復新村 / 審計新村創業基地
- 台南贏地創新育成基地 — 新營區民治路38號
- 新北創力坊 / 三重社會創新基地等

---

## J. 排除 / 待確認（誠實註記，不入 v1）

- **AAMA 台北搖籃計畫**：對象建議 25–45 歲，多超出 35 上限，且為導師制非補助 → 視年齡策略決定。
- **青年海外長期志工計畫**：自 2024/3/14 暫停受理 → 暫不收錄。
- **富邦青少年圓夢、友達圓夢、鴻海/玉山/中租/廣達**：本輪查無實證或對象偏青少年 → 不收錄，待補查。
- **RICH職場體驗網、新創圓夢網**：屬「資源平台」非單一機會 → 視是否要納入「平台型」條目決定。
- 注意：「全民社造行動計畫」教育部青年署也有同名政府版，收錄時務必標清主辦單位（此處指信義房屋版）。
