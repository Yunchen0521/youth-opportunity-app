// Youth Opportunity — AI 顧問後端 proxy（Cloudflare Worker）
//
// 職責：把 App 傳來的「使用者 Profile + 機會」轉成一則 prompt，呼叫 Claude，
// 回傳一句自然語言判讀。ANTHROPIC_API_KEY 只存在這裡（Worker secret），不進 App。
//
// 合約：POST /advise
//   body: { profile: {age, identity, region}, opportunity: {title, category, ...} }
//   回:   { advice: string }

const SYSTEM_PROMPT = `你是一位務實、親切的台灣青年職涯顧問。使用者會給你自己的條件（年齡、身分、地區）與一筆「青年機會」（補助、競賽、實習、創業、獎學金等）。

請用繁體中文、以「你」稱呼使用者，寫 2 到 3 句話，直接判讀這個機會適不適合他，並點出一個最關鍵的注意事項或建議。

要求：
- 誠實：若條件明顯不符或competition激烈，就直說，不要一味鼓勵。
- 具體：扣住使用者的年齡/身分/地區與這個機會的資格條件來講，不要講空話。
- 結尾提醒實際申請請以官方網站最新公告為準。
- 不要用條列、不要 markdown、不要開場白，直接給結論。`;

export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders() });
    }

    const url = new URL(request.url);
    if (request.method !== "POST" || url.pathname !== "/advise") {
      return json({ error: "Not found" }, 404);
    }

    let body;
    try {
      body = await request.json();
    } catch {
      return json({ error: "Invalid JSON" }, 400);
    }

    const { profile, opportunity } = body ?? {};
    if (!opportunity) return json({ error: "Missing opportunity" }, 400);
    if (!env.ANTHROPIC_API_KEY) return json({ error: "Server misconfigured" }, 500);

    const resp = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-api-key": env.ANTHROPIC_API_KEY,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        // 預設用最強的 Opus 4.8。若要省成本可改 "claude-haiku-4-5"
        // （短建議 Haiku 也綽綽有餘，但別加 output_config.effort，Haiku 不支援）。
        model: "claude-opus-4-8",
        max_tokens: 400,
        system: SYSTEM_PROMPT,
        messages: [{ role: "user", content: buildPrompt(profile, opportunity) }],
      }),
    });

    if (!resp.ok) {
      const detail = await resp.text();
      return json({ error: "Upstream error", detail }, 502);
    }

    const data = await resp.json();
    const advice = (data.content ?? [])
      .filter((b) => b.type === "text")
      .map((b) => b.text)
      .join("")
      .trim();

    return json({ advice });
  },
};

function buildPrompt(profile, opp) {
  const p = profile ?? {};
  const me = [
    p.age != null ? `年齡 ${p.age} 歲` : null,
    p.identity ? `身分：${p.identity}` : null,
    p.region ? `所在地區：${p.region}` : null,
  ]
    .filter(Boolean)
    .join("、") || "（未提供個人條件）";

  return [
    `我的條件：${me}`,
    ``,
    `機會：${opp.title}（${opp.category}）`,
    `主辦：${opp.organizer}`,
    `摘要：${opp.summary}`,
    `適用年齡：${opp.ageText}`,
    `適用身分：${(opp.identities ?? []).join("、")}`,
    `適用地區：${(opp.regions ?? []).join("、")}`,
    opp.amount ? `金額：${opp.amount}` : null,
    ``,
    `請判讀這個機會適不適合我。`,
  ]
    .filter((line) => line !== null)
    .join("\n");
}

function json(obj, status = 200) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { "content-type": "application/json", ...corsHeaders() },
  });
}

function corsHeaders() {
  return {
    "access-control-allow-origin": "*",
    "access-control-allow-methods": "POST, OPTIONS",
    "access-control-allow-headers": "content-type",
  };
}
