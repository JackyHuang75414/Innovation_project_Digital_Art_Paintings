const pptxgen = require("pptxgenjs");

const pptx = new pptxgen();
pptx.layout = "LAYOUT_WIDE";
pptx.author = "TRAE Assistant";
pptx.company = "ArtEx";
pptx.subject = "User segmentation, persona analysis, user stories, and product analysis";
pptx.title = "ArtEx User Segmentation and Product Analysis";
pptx.lang = "en-US";
pptx.theme = {
  headFontFace: "Arial",
  bodyFontFace: "Arial",
  lang: "en-US",
};

const theme = {
  primary: "0F172A",
  secondary: "1E293B",
  accent: "7C3AED",
  light: "C4B5FD",
  bg: "F8FAFC",
  success: "10B981",
  warning: "F59E0B",
  danger: "DC2626",
  text: "111827",
  muted: "64748B",
  white: "FFFFFF",
  soft: "EEF2FF",
  soft2: "F1F5F9",
};

function addBg(slide, color = theme.bg) {
  slide.background = { color };
}

function addTitle(slide, title, subtitle, page) {
  slide.addText(title, {
    x: 0.45, y: 0.3, w: 7.9, h: 0.5,
    fontFace: "Arial", fontSize: 28, bold: true, color: theme.primary,
  });
  if (subtitle) {
    slide.addText(subtitle, {
      x: 0.48, y: 0.82, w: 8.3, h: 0.34,
      fontFace: "Arial", fontSize: 10.5, color: theme.muted,
    });
  }
  slide.addShape(pptx.ShapeType.line, {
    x: 0.45, y: 1.18, w: 8.7, h: 0,
    line: { color: theme.light, pt: 1.2 },
  });
  if (page) addPageBadge(slide, page);
}

function addPageBadge(slide, page) {
  slide.addShape(pptx.ShapeType.roundRect, {
    x: 9.08, y: 5.08, w: 0.58, h: 0.3,
    rectRadius: 0.08,
    fill: { color: theme.accent },
    line: { color: theme.accent, pt: 0.5 },
  });
  slide.addText(String(page).padStart(2, "0"), {
    x: 9.08, y: 5.08, w: 0.58, h: 0.3,
    fontFace: "Arial", fontSize: 10, bold: true, color: theme.white,
    align: "center", valign: "mid",
  });
}

function addSectionTag(slide, text, x, y, color = theme.accent) {
  slide.addShape(pptx.ShapeType.roundRect, {
    x, y, w: 1.4, h: 0.28,
    rectRadius: 0.08,
    fill: { color },
    line: { color, pt: 0.2 },
  });
  slide.addText(text, {
    x, y: y + 0.01, w: 1.4, h: 0.24,
    fontSize: 10, bold: true, color: theme.white, align: "center",
  });
}

function addBullets(slide, items, opts = {}) {
  const x = opts.x ?? 0.7;
  const y = opts.y ?? 1.5;
  const w = opts.w ?? 4.0;
  const h = opts.h ?? 3.2;
  const fontSize = opts.fontSize ?? 15;
  const color = opts.color ?? theme.text;
  const bulletIndent = opts.bulletIndent ?? 16;
  const indent = opts.indent ?? 24;
  const paras = items.map((t) => ({
    text: t,
    options: {
      bullet: { indent },
      hanging: 3,
      paraSpaceAfterPt: 10,
      breakLine: false,
    },
  }));
  slide.addText(paras, {
    x, y, w, h, fontFace: "Arial", fontSize, color,
    margin: 0.04, valign: "top",
    breakLine: false, bulletIndent,
  });
}

function addCard(slide, x, y, w, h, title, body, color = theme.white) {
  slide.addShape(pptx.ShapeType.roundRect, {
    x, y, w, h,
    rectRadius: 0.08,
    fill: { color },
    line: { color: theme.light, pt: 1 },
    shadow: { type: "outer", color: "CBD5E1", blur: 1, angle: 45, distance: 1, opacity: 0.15 },
  });
  slide.addText(title, {
    x: x + 0.16, y: y + 0.12, w: w - 0.24, h: 0.25,
    fontSize: 16, bold: true, color: theme.primary,
  });
  slide.addText(body, {
    x: x + 0.16, y: y + 0.44, w: w - 0.28, h: h - 0.56,
    fontSize: 10.5, color: theme.text, valign: "top", margin: 0,
  });
}

function addMetric(slide, x, y, w, h, value, label, fill) {
  slide.addShape(pptx.ShapeType.roundRect, {
    x, y, w, h, rectRadius: 0.06,
    fill: { color: fill },
    line: { color: fill, pt: 0.2 },
  });
  slide.addText(value, {
    x: x + 0.12, y: y + 0.12, w: w - 0.2, h: 0.28,
    fontSize: 20, bold: true, color: theme.white, align: "center",
  });
  slide.addText(label, {
    x: x + 0.1, y: y + 0.46, w: w - 0.2, h: 0.18,
    fontSize: 9.5, color: theme.white, align: "center",
  });
}

function slide1() {
  const slide = pptx.addSlide();
  addBg(slide, theme.primary);
  slide.addShape(pptx.ShapeType.rect, {
    x: 0, y: 0, w: 10, h: 5.625,
    fill: { color: theme.primary },
    line: { color: theme.primary, pt: 0 },
  });
  slide.addShape(pptx.ShapeType.rect, {
    x: 6.9, y: 0, w: 3.1, h: 5.625,
    fill: { color: theme.accent, transparency: 14 },
    line: { color: theme.accent, pt: 0 },
  });
  slide.addShape(pptx.ShapeType.rect, {
    x: 6.1, y: 0, w: 0.14, h: 5.625,
    fill: { color: theme.warning },
    line: { color: theme.warning, pt: 0 },
  });
  slide.addText("ArtEx User\nSegmentation &\nProduct Analysis", {
    x: 0.65, y: 1.0, w: 4.9, h: 1.7,
    fontSize: 24, bold: true, color: theme.white, breakLine: true,
  });
  slide.addText("Who is most likely to use the platform, why they come, what they do, and what product choices fit or amplify risk.", {
    x: 0.68, y: 2.95, w: 4.85, h: 0.8,
    fontSize: 12, color: "E2E8F0",
  });
  slide.addText("Prepared for presentation\nFocus: target users, personas, 3+ user stories, product implications", {
    x: 0.68, y: 4.42, w: 4.8, h: 0.5,
    fontSize: 10.5, color: "CBD5E1",
  });
  addSectionTag(slide, "ENGLISH DECK", 7.25, 0.58, theme.warning);
  slide.addText("Core thesis", {
    x: 6.6, y: 1.15, w: 2.6, h: 0.3,
    fontSize: 16, bold: true, color: theme.white,
  });
  slide.addText("The current ArtEx concept is more attractive to high-risk speculative users than to traditional art collectors.", {
    x: 6.6, y: 1.52, w: 2.55, h: 1.1,
    fontSize: 12.5, color: theme.white,
  });
  slide.addText("Signals inside the product:\nFractional shares\nPerpetual trading\nAI prompts and alerts\nWallet-first behavior\nFast market-style interface", {
    x: 6.6, y: 2.72, w: 2.55, h: 1.65,
    fontSize: 11.2, color: "F8FAFC",
    breakLine: true,
  });
}

function slide2() {
  const slide = pptx.addSlide();
  addBg(slide);
  addTitle(slide, "Research-Based Framing", "External research suggests overlap between speculative trading, gambling-like behavior, and gamified app design.", 2);

  addMetric(slide, 0.55, 1.46, 1.9, 0.8, "+39%", "more trading with points reward", theme.accent);
  addMetric(slide, 2.62, 1.46, 1.9, 0.8, "+11%", "more trades from push notifications", theme.success);
  addMetric(slide, 4.69, 1.46, 1.9, 0.8, "+12%", "more trades from points/lotteries", theme.warning);
  addMetric(slide, 6.76, 1.46, 1.9, 0.8, "+5.17%", "avg. trade lift from hedonic gamification", theme.secondary);

  addCard(
    slide, 0.55, 2.55, 4.25, 2.0,
    "What the literature says",
    "1. Crypto trading and problem gambling often co-occur.\n2. High-frequency retail speculation is strengthened by easy access, fast feedback, and game-like digital engagement.\n3. Users with lower financial literacy or higher impulsivity can be more responsive to nudges, rewards, and alerts."
  );
  addCard(
    slide, 5.05, 2.55, 4.25, 2.0,
    "Why it matters for ArtEx",
    "ArtEx combines art branding with market mechanics: fractional ownership, price boards, perpetual positions, AI suggestions, and wallet behavior. That design is likely to attract users who seek excitement, short-term upside, and fast decision loops more than slow cultural appreciation."
  );

  slide.addText("Sources used in this deck include OSC (2022), FCA (2024), Chapkovski et al. (2024), Delfabbro et al. (2021), and related trading-behavior studies.", {
    x: 0.58, y: 4.92, w: 8.45, h: 0.25, fontSize: 9.5, color: theme.muted,
  });
}

function slide3() {
  const slide = pptx.addSlide();
  addBg(slide);
  addTitle(slide, "Primary Target User Groups", "Positioning the likely demand side by motivation, behavior, and monetization potential.", 3);

  addCard(slide, 0.55, 1.45, 2.8, 3.25, "1. Momentum Speculators",
    "Motivation\nShort-term price upside\n\nBehavior\nTrack movers, react to alerts, rotate fast\n\nWhy they fit ArtEx\nLove market dashboards, volatility, and trade-like UX\n\nRisk\nChurn if liquidity and excitement decline");
  addCard(slide, 3.6, 1.45, 2.8, 3.25, "2. Gambling-Style High-Risk Users",
    "Motivation\nThrill, uncertainty, big-win fantasy\n\nBehavior\nPrefer leverage, lottery-like outcomes, repeated entries\n\nWhy they fit ArtEx\nPerpetuals, PnL, and gamified loops create strong engagement\n\nRisk\nHigh loss sensitivity, compliance and ethics concerns");
  addCard(slide, 6.65, 1.45, 2.8, 3.25, "3. AI-Assisted Opportunists",
    "Motivation\nUse tools to reduce effort and catch signals\n\nBehavior\nRely on prompts, rankings, and agent-like recommendations\n\nWhy they fit ArtEx\nAI chat and trade suggestions lower friction\n\nRisk\nMay over-trust automation or unclear prompts");
}

function slide4() {
  const slide = pptx.addSlide();
  addBg(slide);
  addTitle(slide, "Persona A: The Momentum Speculator", "The most commercially attractive early user if the platform aims for frequent activity.", 4);

  addCard(slide, 0.55, 1.48, 2.2, 3.45, "Profile",
    "Name\nJason, 24\n\nOccupation\nGraduate student / part-time freelancer\n\nMindset\n'If the chart is moving, I want exposure now.'\n\nRisk tolerance\nHigh\n\nFavorite cues\nTop movers, trend lines, green candles");
  addCard(slide, 2.95, 1.48, 3.1, 3.45, "Goals and triggers",
    "Goals\nMake quick gains from short bursts of attention\nBuild a track record among friends\nFeel ahead of the crowd\n\nTriggers\nPush alerts, social buzz, a sudden spike, a 'hot artwork' ranking");
  addCard(slide, 6.25, 1.48, 3.2, 3.45, "What he needs from ArtEx",
    "Fast onboarding\nReal-time market board\nClear entry/exit actions\nSimple PnL visibility\nAI summaries of market direction\n\nLikely retention driver\nA feeling that action is always available");
}

function slide5() {
  const slide = pptx.addSlide();
  addBg(slide);
  addTitle(slide, "Persona B: The Gambling-Style High Roller", "Not necessarily an art lover; often motivated by arousal, leverage, and outsized wins.", 5);

  addCard(slide, 0.55, 1.48, 2.2, 3.45, "Profile",
    "Name\nRyan, 29\n\nOccupation\nSales / nightlife / irregular income\n\nMindset\n'I can recover losses with one strong move.'\n\nRisk tolerance\nVery high\n\nFavorite cues\nLeverage, volatility, limited-time opportunity");
  addCard(slide, 2.95, 1.48, 3.1, 3.45, "Behavior pattern",
    "Trades after wins and after losses\nChases excitement more than fundamentals\nUses bigger size when emotional\nSeeks fast recovery after drawdowns\nOften ignores long-term art value");
  addCard(slide, 6.25, 1.48, 3.2, 3.45, "Implication for product",
    "This user can generate activity and volume, but also the greatest harm and reputation risk.\n\nIf the product rewards speed, streaks, and constant prompts without safeguards, it may drift from 'art investment' toward 'aestheticized gambling.'");
}

function slide6() {
  const slide = pptx.addSlide();
  addBg(slide);
  addTitle(slide, "Persona C: The AI-Assisted Opportunist", "A digitally fluent user who wants edge through tools, not deep art expertise.", 6);

  addCard(slide, 0.55, 1.48, 2.2, 3.45, "Profile",
    "Name\nMina, 27\n\nOccupation\nJunior product analyst\n\nMindset\n'If AI can surface the best opportunities, I can act faster than manual users.'\n\nRisk tolerance\nMedium-high");
  addCard(slide, 2.95, 1.48, 3.1, 3.45, "Needs and expectations",
    "Wants the system to shortlist opportunities\nPrefers summaries over deep research\nLooks for confidence, not perfect certainty\nLikes automation, watchlists, and alerts");
  addCard(slide, 6.25, 1.48, 3.2, 3.45, "Why ArtEx fits",
    "AI recommendation chat\nAlert-based decision flow\nWallet + market hybrid identity\nPerceived sophistication of the platform\n\nMain risk\nAutomation may create false confidence and faster impulse trading");
}

function slide7() {
  const slide = pptx.addSlide();
  addBg(slide);
  addTitle(slide, "Three User Stories", "These stories show how the current product concept serves high-risk speculative behavior.", 7);

  addCard(slide, 0.55, 1.5, 2.85, 3.2, "Story 1: Chasing momentum",
    "As a momentum trader,\nI want to see top movers and enter quickly,\nso that I can capture a short-term spike before attention fades.\n\nKey features\nMarket board, trade page, fast spot buy, AI summary.");
  addCard(slide, 3.57, 1.5, 2.85, 3.2, "Story 2: Leveraged thrill",
    "As a high-risk user,\nI want perpetual exposure and visible PnL,\nso that I can amplify gains from a strong directional bet.\n\nKey features\nPerp interface, leverage slider, liquidation price, active positions.");
  addCard(slide, 6.59, 1.5, 2.85, 3.2, "Story 3: AI-guided action",
    "As an opportunistic user,\nI want AI prompts and alerts,\nso that I can make decisions quickly without doing full analysis myself.\n\nKey features\nAI chat, signal summaries, action suggestions, notifications.");
}

function slide8() {
  const slide = pptx.addSlide();
  addBg(slide);
  addTitle(slide, "Product Analysis: Strong Fit, Strong Risk", "The current feature set is coherent for speculative use, but weaker for traditional collector trust.", 8);

  addCard(slide, 0.55, 1.46, 2.9, 3.4, "What already works",
    "Clear speculative proposition\nFast visual feedback\nEngaging trade workflow\nAI lowers decision friction\nFractional ownership widens entry access\n\nResult\nGood for demo value and active-user storytelling");
  addCard(slide, 3.57, 1.46, 2.9, 3.4, "What is missing",
    "Little collector-oriented value proof\nWeak long-term ownership narrative\nLimited educational framing\nFew trust and harm-reduction cues\nNo clear separation between investing and gambling-like play");
  addCard(slide, 6.59, 1.46, 2.9, 3.4, "Strategic tension",
    "If ArtEx wants growth through activity, it will naturally attract high-risk users.\n\nIf ArtEx wants legitimacy, it must add guardrails, transparent risk language, and stronger art-value context.\n\nThe core product question is not only 'who uses it?' but 'who should it be built for?'");
}

function slide9() {
  const slide = pptx.addSlide();
  addBg(slide);
  addTitle(slide, "Recommendations for Presentation and Product Positioning", "Use a balanced framing: the product is attractive to speculative users, but that insight should guide safer design choices.", 9);

  addBullets(slide, [
    "Position the primary early users as high-risk speculative participants rather than conventional collectors.",
    "Use neutral language such as 'speculative traders', 'high-volatility seekers', and 'AI-assisted opportunists' instead of presenting the platform as explicitly built for gambling behavior.",
    "Show the opportunity: high engagement, clear feature-market fit, strong demo narrative.",
    "Show the risk: impulsive decisions, over-trading, leverage harm, false confidence from AI, and ethical/reputational issues.",
    "Recommend product guardrails: risk disclosures, cooldowns, educational prompts, limit settings, and transparent AI confidence cues.",
    "In Q&A, emphasize that this analysis helps the team decide both target market and responsible product boundaries."
  ], { x: 0.65, y: 1.55, w: 8.4, h: 3.5, fontSize: 15 });
}

function slide10() {
  const slide = pptx.addSlide();
  addBg(slide);
  addTitle(slide, "Selected References", "Short source list used to support the behavioral framing in this deck.", 10);

  slide.addText(
    [
      { text: "1. Ontario Securities Commission (2022) - Gamification and investing behavior.\n" },
      { text: "https://www.osc.ca/sites/default/files/2022-11/sn_20221117_11-796_gamification-report.pdf\n\n", options: { color: theme.accent } },
      { text: "2. UK FCA (2024) - Digital engagement practices in trading apps.\n" },
      { text: "https://www.fca.org.uk/publications/research-notes/research-note-digital-engagement-practices-trading-apps-experiment\n\n", options: { color: theme.accent } },
      { text: "3. Chapkovski, Khapko, Zoican (2024) - Gamification increases trading activity.\n" },
      { text: "https://pubsonline.informs.org/doi/10.1287/mnsc.2022.02650\n\n", options: { color: theme.accent } },
      { text: "4. Delfabbro et al. (2021) - Cryptocurrency trading and gambling overlap.\n" },
      { text: "https://doi.org/10.1016/j.addbeh.2021.107021\n\n", options: { color: theme.accent } },
      { text: "5. Havakhor et al. (2024) - Frictionless data access and retail trading behavior.\n" },
      { text: "https://pubsonline.informs.org/doi/10.1287/mnsc.2021.01379" , options: { color: theme.accent } },
    ],
    {
      x: 0.7, y: 1.55, w: 8.4, h: 3.7,
      fontSize: 11.2, color: theme.text, margin: 0,
    }
  );
}

slide1();
slide2();
slide3();
slide4();
slide5();
slide6();
slide7();
slide8();
slide9();
slide10();

pptx.writeFile({ fileName: "output/Artex_User_Segmentation_Analysis.pptx" });
