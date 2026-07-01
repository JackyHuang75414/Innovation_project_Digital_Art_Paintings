"""
ArtEx — 10-Minute Summary Presentation
Covers: Market Analysis, User Positioning, Solution, Environmental Commitments, Team Roles
Style: dark brand (#0A0A0F bg, #E8552A accent, white text)
"""

from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.util import Inches, Pt
import sys

# ── brand colours ─────────────────────────────────────────────────────────────
BG        = RGBColor(0x0A, 0x0A, 0x0F)   # near-black background
PANEL     = RGBColor(0x11, 0x11, 0x16)   # card / panel bg
ACCENT    = RGBColor(0xE8, 0x55, 0x2A)   # ArtEx orange
WHITE     = RGBColor(0xFF, 0xFF, 0xFF)
GREY      = RGBColor(0x88, 0x88, 0x99)
GOLD      = RGBColor(0xF5, 0xC5, 0x18)   # highlight / stat callout
GREEN     = RGBColor(0x22, 0xC5, 0x5E)   # positive / eco
BLUE      = RGBColor(0x38, 0xBD, 0xF8)   # tech accent

W = Inches(13.33)   # widescreen 16:9
H = Inches(7.5)


def prs_init():
    prs = Presentation()
    prs.slide_width  = W
    prs.slide_height = H
    return prs


def blank_slide(prs):
    layout = prs.slide_layouts[6]  # completely blank
    return prs.slides.add_slide(layout)


def fill_bg(slide, color=BG):
    fill = slide.background.fill
    fill.solid()
    fill.fore_color.rgb = color


def box(slide, left, top, width, height,
        bg=None, border=None, alpha=None):
    shape = slide.shapes.add_shape(
        1,  # MSO_SHAPE_TYPE.RECTANGLE
        Inches(left), Inches(top), Inches(width), Inches(height)
    )
    shape.line.fill.background()  # no line by default
    if bg:
        shape.fill.solid()
        shape.fill.fore_color.rgb = bg
    else:
        shape.fill.background()
    if border:
        shape.line.color.rgb = border
        shape.line.width = Pt(0.75)
    return shape


def txt(slide, text, left, top, width, height,
        size=18, bold=False, italic=False,
        color=WHITE, align=PP_ALIGN.LEFT,
        wrap=True, font_name="Calibri"):
    txb = slide.shapes.add_textbox(
        Inches(left), Inches(top), Inches(width), Inches(height)
    )
    txb.word_wrap = wrap
    tf = txb.text_frame
    tf.word_wrap = wrap
    p = tf.paragraphs[0]
    p.alignment = align
    run = p.add_run()
    run.text = text
    run.font.size  = Pt(size)
    run.font.bold  = bold
    run.font.italic = italic
    run.font.color.rgb = color
    run.font.name  = font_name
    return txb


def accent_bar(slide, top=0.55, width=1.4, left=0.45):
    """Thin horizontal orange rule under section headers."""
    ln = slide.shapes.add_shape(1,
        Inches(left), Inches(top), Inches(width), Pt(2))
    ln.fill.solid()
    ln.fill.fore_color.rgb = ACCENT
    ln.line.fill.background()


def slide_label(slide, label, top=0.22):
    """Small uppercase orange label (section tag)."""
    txt(slide, label, 0.45, top, 5, 0.3,
        size=8, color=ACCENT, bold=False)


def divider(slide, top):
    """Full-width thin horizontal rule."""
    ln = slide.shapes.add_shape(1,
        Inches(0.45), Inches(top), Inches(12.43), Pt(1))
    ln.fill.solid()
    ln.fill.fore_color.rgb = RGBColor(0x2A, 0x2A, 0x38)
    ln.line.fill.background()


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 1 — TITLE
# ══════════════════════════════════════════════════════════════════════════════
def slide_title(prs):
    sl = blank_slide(prs)
    fill_bg(sl)

    # left accent stripe
    box(sl, 0, 0, 0.08, 7.5, bg=ACCENT)

    # big logo word
    txt(sl, "ArtEx", 0.55, 1.8, 9, 1.5,
        size=96, bold=True, italic=True, color=WHITE,
        align=PP_ALIGN.LEFT, font_name="Georgia")

    # tagline
    txt(sl, "The Digital Art Exchange", 0.6, 3.35, 9, 0.6,
        size=22, color=GREY, italic=False)

    # orange separator line
    box(sl, 0.6, 4.05, 2.5, 0.025, bg=ACCENT)

    # sub-text
    txt(sl, "AI-powered fractional art investment for the digital era",
        0.6, 4.2, 10, 0.45, size=14, color=GREY)

    # date / school
    txt(sl, "EFREI Paris  ·  2025–2026  ·  L2 Innovation Project",
        0.6, 5.1, 10, 0.35, size=11, color=RGBColor(0x44, 0x44, 0x55))

    # right-side deco circle (art-market vibe)
    circ = sl.shapes.add_shape(9,  # OVAL
        Inches(10.5), Inches(1.5), Inches(2.4), Inches(2.4))
    circ.fill.solid()
    circ.fill.fore_color.rgb = RGBColor(0x1A, 0x0A, 0x05)
    circ.line.color.rgb = ACCENT
    circ.line.width = Pt(1.5)

    txt(sl, "$67B", 10.55, 1.9, 2.3, 0.9,
        size=36, bold=True, color=ACCENT, align=PP_ALIGN.CENTER)
    txt(sl, "Global Art Market", 10.55, 2.85, 2.3, 0.4,
        size=9, color=GREY, align=PP_ALIGN.CENTER)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 2 — THE PROBLEM
# ══════════════════════════════════════════════════════════════════════════════
def slide_problem(prs):
    sl = blank_slide(prs)
    fill_bg(sl)

    slide_label(sl, "THE PROBLEM")
    txt(sl, "Art investment is broken", 0.45, 0.5, 12, 0.85,
        size=40, bold=True, color=WHITE)
    accent_bar(sl, top=1.38, width=2.2)

    pain_points = [
        ("$50K+", "Minimum ticket size to buy a single blue-chip artwork — locking out 99% of investors"),
        ("0%",    "Secondary market liquidity for most physical art — you can wait years to exit"),
        ("12–15%","Typical gallery/auction commission that eats into every transaction"),
        ("Opaque","Pricing is negotiated behind closed doors — no transparent market price"),
    ]

    for i, (stat, desc) in enumerate(pain_points):
        col = i % 2
        row = i // 2
        lft = 0.45 + col * 6.45
        tp  = 1.6  + row * 2.55

        box(sl, lft, tp, 6.0, 2.3, bg=PANEL,
            border=RGBColor(0x2A, 0x2A, 0x38))

        txt(sl, stat, lft + 0.3, tp + 0.25, 5.5, 0.85,
            size=44, bold=True, color=ACCENT)
        txt(sl, desc, lft + 0.3, tp + 1.1, 5.4, 1.0,
            size=13, color=GREY, wrap=True)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 3 — MARKET OPPORTUNITY
# ══════════════════════════════════════════════════════════════════════════════
def slide_market(prs):
    sl = blank_slide(prs)
    fill_bg(sl)

    slide_label(sl, "MARKET OPPORTUNITY")
    txt(sl, "A $67B market shifting online", 0.45, 0.5, 12, 0.85,
        size=38, bold=True, color=WHITE)
    accent_bar(sl, top=1.38, width=2.5)

    # three big stats
    stats = [
        ("$67B",  "Global art market\ntotal value (2024)", WHITE),
        ("$10.8B","Online art &\ncollectibles sales", GOLD),
        ("+12%",  "YoY online segment\ngrowth rate", GREEN),
    ]
    for i, (val, lbl, col) in enumerate(stats):
        lft = 0.45 + i * 4.28
        box(sl, lft, 1.55, 4.0, 1.8, bg=PANEL,
            border=RGBColor(0x25, 0x25, 0x35))
        txt(sl, val, lft + 0.25, 1.7, 3.5, 0.8,
            size=46, bold=True, color=col)
        txt(sl, lbl, lft + 0.25, 2.5, 3.5, 0.7,
            size=11, color=GREY, wrap=True)

    divider(sl, 3.55)

    bullets = [
        "Art Basel / UBS 2024 Report: online art sales reached $10.8B, up from $8.4B in 2021",
        "73% of new collectors (under 40) say they prefer to discover and buy art digitally",
        "Digital art (NFTs + licensed digital works) is the fastest-growing sub-category",
        "Traditional platforms (Christie's, Sotheby's) are not built for retail — minimum lots $5,000+",
        "No existing platform combines fractional ownership + AI advisory + leveraged trading",
    ]
    for i, b in enumerate(bullets):
        txt(sl, f"•  {b}", 0.55, 3.7 + i * 0.56, 12.3, 0.5,
            size=13, color=GREY if i > 0 else WHITE)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 4 — COMPETITIVE LANDSCAPE
# ══════════════════════════════════════════════════════════════════════════════
def slide_competitors(prs):
    sl = blank_slide(prs)
    fill_bg(sl)

    slide_label(sl, "COMPETITIVE LANDSCAPE")
    txt(sl, "Existing platforms leave a critical gap", 0.45, 0.5, 12, 0.85,
        size=36, bold=True, color=WHITE)
    accent_bar(sl, top=1.38, width=2.8)

    # table header
    cols  = ["Feature", "Artsy", "OpenSea", "ArtEx"]
    widths = [3.5, 2.3, 2.3, 2.3]
    lefts  = [0.45, 3.95, 6.25, 8.55]

    for j, (c, w, l) in enumerate(zip(cols, widths, lefts)):
        bg = ACCENT if j == 3 else RGBColor(0x1A, 0x1A, 0x25)
        box(sl, l, 1.55, w, 0.55, bg=bg)
        txt(sl, c, l + 0.12, 1.6, w - 0.2, 0.45,
            size=12, bold=True, color=WHITE if j == 3 else GREY,
            align=PP_ALIGN.LEFT)

    rows = [
        ("Fractional Ownership",  "No",    "No",      "Yes"),
        ("AI Buy Recommendations","No",    "No",      "Yes"),
        ("Leveraged Trading",     "No",    "No",      "Yes"),
        ("Traditional Art",       "Yes",   "No",      "Yes"),
        ("Digital / NFT Art",     "No",    "Yes",     "Yes"),
        ("Active Price Discovery","No",    "Volatile","Yes"),
        ("Retail Accessible",     "No",    "Partial", "Yes"),
    ]

    CHECK  = WHITE
    CROSS  = RGBColor(0xFF, 0x55, 0x55)
    YELLOW = GOLD

    def cell_col(v):
        if v == "Yes":    return GREEN
        if v == "No":     return CROSS
        if v == "No":     return CROSS
        return YELLOW

    for i, (feat, artsy, opensea, artex) in enumerate(rows):
        tp = 2.18 + i * 0.66
        bg_row = RGBColor(0x0D, 0x0D, 0x15) if i % 2 == 0 else PANEL
        box(sl, 0.45, tp, 12.43, 0.62, bg=bg_row)

        txt(sl, feat, 0.57, tp + 0.08, 3.3, 0.5, size=12, color=WHITE)
        for val, lft in [(artsy, 3.95), (opensea, 6.25), (artex, 8.55)]:
            col = cell_col(val)
            txt(sl, val, lft + 0.15, tp + 0.08, 2.0, 0.5,
                size=12, color=col, bold=(val == "Yes"))


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 5 — OUR SOLUTION
# ══════════════════════════════════════════════════════════════════════════════
def slide_solution(prs):
    sl = blank_slide(prs)
    fill_bg(sl)

    slide_label(sl, "OUR SOLUTION")
    txt(sl, "ArtEx — Where Art Meets Finance", 0.45, 0.5, 12, 0.85,
        size=38, bold=True, color=WHITE)
    accent_bar(sl, top=1.38, width=2.8)

    txt(sl,
        "ArtEx is a web platform that democratises digital art investment through fractional ownership, "
        "AI-powered advisory, and a transparent secondary market — accessible from any browser.",
        0.45, 1.55, 12.43, 0.75, size=14, color=GREY, wrap=True)

    pillars = [
        ("01", "Fractional\nOwnership",
         "Buy as little as 0.1% of a digital artwork.\nNo $50K barriers — invest from any amount."),
        ("02", "AI Advisor",
         "DeepSeek-powered chat assistant analyses\nmarket trends and surfaces personalised picks."),
        ("03", "Leveraged\nPerpetuals",
         "Up to 5× leverage on art price exposure.\nGBM-based price simulation with live P&L."),
        ("04", "Active\nSecondary Market",
         "Resell your shares instantly at the current\nmarket price — true liquidity for art."),
    ]

    for i, (num, title, body) in enumerate(pillars):
        lft = 0.45 + i * 3.23
        box(sl, lft, 2.5, 3.05, 4.5, bg=PANEL,
            border=RGBColor(0x25, 0x25, 0x35))
        # number badge
        badge = sl.shapes.add_shape(9,
            Inches(lft + 0.25), Inches(2.7), Inches(0.5), Inches(0.5))
        badge.fill.solid()
        badge.fill.fore_color.rgb = ACCENT
        badge.line.fill.background()
        txt(sl, num, lft + 0.25, 2.7, 0.5, 0.5,
            size=10, bold=True, color=WHITE, align=PP_ALIGN.CENTER)

        txt(sl, title, lft + 0.25, 3.35, 2.6, 0.75,
            size=17, bold=True, color=WHITE, wrap=True)
        txt(sl, body, lft + 0.25, 4.2, 2.6, 2.3,
            size=12, color=GREY, wrap=True)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 6 — TARGET USERS
# ══════════════════════════════════════════════════════════════════════════════
def slide_users(prs):
    sl = blank_slide(prs)
    fill_bg(sl)

    slide_label(sl, "USER POSITIONING")
    txt(sl, "Four distinct user segments", 0.45, 0.5, 12, 0.85,
        size=38, bold=True, color=WHITE)
    accent_bar(sl, top=1.38, width=2.2)

    personas = [
        ("Retail\nArt Investor",
         "Age 25–45 · mid income\nWants portfolio diversification beyond stocks\nLocked out by high minimums of physical art",
         ACCENT),
        ("Digital Art\nCollector",
         "Age 20–35 · tech-savvy\nCollects digital works for passion & value\nNeeds a transparent pricing mechanism",
         BLUE),
        ("Crypto-Native\nTrader",
         "Age 22–40 · crypto fluent\nFamiliar with leverage & perpetuals\nLooks for non-correlated assets beyond BTC/ETH",
         GREEN),
        ("Curious\nEnthusiast",
         "Age 18–30 · student / early career\nPassionate about art but can't afford entry\nNeeds guidance + fractional access",
         GOLD),
    ]

    for i, (name, desc, col) in enumerate(personas):
        lft = 0.45 + i * 3.23
        box(sl, lft, 1.55, 3.05, 5.55, bg=PANEL,
            border=col)
        # top colour strip
        box(sl, lft, 1.55, 3.05, 0.12, bg=col)

        # avatar circle
        av = sl.shapes.add_shape(9,
            Inches(lft + 1.0), Inches(1.8), Inches(1.05), Inches(1.05))
        av.fill.solid()
        av.fill.fore_color.rgb = RGBColor(0x1A, 0x1A, 0x25)
        av.line.color.rgb = col
        av.line.width = Pt(1.5)

        initials = name.replace("\n", " ").split()
        init_str = "".join(w[0] for w in initials[:2])
        txt(sl, init_str, lft + 1.0, 1.8, 1.05, 1.05,
            size=22, bold=True, color=col, align=PP_ALIGN.CENTER)

        txt(sl, name, lft + 0.2, 3.0, 2.7, 0.75,
            size=15, bold=True, color=WHITE, align=PP_ALIGN.CENTER, wrap=True)
        txt(sl, desc, lft + 0.2, 3.85, 2.7, 3.1,
            size=11, color=GREY, wrap=True)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 7 — KEY FEATURES (platform demo)
# ══════════════════════════════════════════════════════════════════════════════
def slide_features(prs):
    sl = blank_slide(prs)
    fill_bg(sl)

    slide_label(sl, "PLATFORM FEATURES")
    txt(sl, "Everything you need to trade digital art", 0.45, 0.5, 12, 0.85,
        size=36, bold=True, color=WHITE)
    accent_bar(sl, top=1.38, width=2.8)

    features = [
        ("Gallery &\nMarketplace",
         "Browse 200+ curated digital artworks. Filter by style, artist, price range. Real-time price charts powered by GBM simulation.",
         "gallery"),
        ("AI Personal\nAssistant",
         "Chat with DeepSeek AI for buy/sell recommendations. AI profiles your risk appetite and monitors price alerts for you.",
         "ai"),
        ("Leveraged\nTrading",
         "Open long/short positions with up to 5x leverage. Live P&L tracking, margin display, one-click trade execution.",
         "trade"),
        ("Portfolio &\nAnalytics",
         "Real-time portfolio dashboard, allocation pie chart, BTC/USD balance, position history, and performance metrics.",
         "portfolio"),
        ("Account &\nSecurity",
         "Email registration, JWT auth, Google OAuth (coming), forgot-password via email, delete-account with confirmation.",
         "account"),
        ("Subscription\nTiers",
         "Free tier: browse + small fractions. Pro tier: full leverage, AI advisor, real-time alerts, portfolio export.",
         "sub"),
    ]

    for i, (title, desc, _) in enumerate(features):
        col = i % 3
        row = i // 3
        lft = 0.45 + col * 4.3
        tp  = 1.6  + row * 2.75

        box(sl, lft, tp, 4.0, 2.55, bg=PANEL,
            border=RGBColor(0x22, 0x22, 0x33))

        # accent dot
        dot = sl.shapes.add_shape(9,
            Inches(lft + 0.25), Inches(tp + 0.25), Inches(0.18), Inches(0.18))
        dot.fill.solid()
        dot.fill.fore_color.rgb = ACCENT
        dot.line.fill.background()

        txt(sl, title, lft + 0.55, tp + 0.18, 3.3, 0.6,
            size=14, bold=True, color=WHITE, wrap=True)
        txt(sl, desc, lft + 0.25, tp + 0.88, 3.6, 1.6,
            size=11, color=GREY, wrap=True)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 8 — BUSINESS MODEL
# ══════════════════════════════════════════════════════════════════════════════
def slide_business(prs):
    sl = blank_slide(prs)
    fill_bg(sl)

    slide_label(sl, "BUSINESS MODEL")
    txt(sl, "Multiple revenue streams from day one", 0.45, 0.5, 12, 0.85,
        size=36, bold=True, color=WHITE)
    accent_bar(sl, top=1.38, width=2.5)

    streams = [
        ("Trading\nCommission", "0.5–1.5%",
         "Fee on every buy/sell transaction.\nScales directly with trading volume."),
        ("Pro\nSubscription", "$9.99/mo",
         "Unlocks AI advisor, full leverage,\nreal-time price alerts, portfolio export."),
        ("Artist\nListing Fee", "$49–$199",
         "Artists pay to list and tokenise their\ndigital works on the platform."),
        ("Spread\nRevenue", "Maker/Taker",
         "Bid-ask spread on perpetual contracts\ncaptured by the platform as market maker."),
    ]

    for i, (title, price, desc) in enumerate(streams):
        lft = 0.45 + i * 3.23
        box(sl, lft, 1.6, 3.05, 4.8, bg=PANEL,
            border=RGBColor(0x25, 0x25, 0x38))
        box(sl, lft, 1.6, 3.05, 0.08, bg=ACCENT)

        txt(sl, title, lft + 0.25, 1.75, 2.6, 0.7,
            size=16, bold=True, color=WHITE, wrap=True)
        txt(sl, price, lft + 0.25, 2.55, 2.6, 0.7,
            size=34, bold=True, color=GOLD, wrap=False)
        txt(sl, desc, lft + 0.25, 3.35, 2.6, 2.9,
            size=12, color=GREY, wrap=True)

    divider(sl, 6.65)
    txt(sl,
        "Positioning: B2C SaaS + transaction revenue  ·  Target break-even at 2,000 active monthly traders",
        0.55, 6.75, 12.3, 0.45, size=11, color=GREY)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 9 — TECHNOLOGY STACK
# ══════════════════════════════════════════════════════════════════════════════
def slide_tech(prs):
    sl = blank_slide(prs)
    fill_bg(sl)

    slide_label(sl, "TECHNOLOGY")
    txt(sl, "Modern, production-ready stack", 0.45, 0.5, 12, 0.85,
        size=36, bold=True, color=WHITE)
    accent_bar(sl, top=1.38, width=2.2)

    layers = [
        ("Frontend",  BLUE,
         ["Vue 3 + Composition API", "Pinia state management",
          "Tailwind CSS (dark design system)", "Vite 6 build tool + proxy"]),
        ("Backend",   ACCENT,
         ["Spring Boot 4 REST API", "MyBatis + MySQL 8.0",
          "JWT authentication (HMAC256)", "Global exception handling"]),
        ("AI / Data", GREEN,
         ["DeepSeek LLM via Dify proxy", "GBM price simulation (client-side)",
          "Personalised risk profiling", "Real-time price alert engine"]),
        ("External",  GOLD,
         ["CoinGecko API (BTC/ETH price)", "BlockCypher (blockchain data)",
          "Google GSI (OAuth 2.0 ready)", "Vercel / cloud deployment"]),
    ]

    for i, (layer, col, items) in enumerate(layers):
        lft = 0.45 + i * 3.23
        box(sl, lft, 1.6, 3.05, 5.55, bg=PANEL,
            border=col)

        # label tab
        tab = sl.shapes.add_shape(1,
            Inches(lft), Inches(1.6), Inches(3.05), Inches(0.45))
        tab.fill.solid()
        tab.fill.fore_color.rgb = col
        tab.line.fill.background()
        txt(sl, layer.upper(), lft + 0.15, 1.62, 2.8, 0.4,
            size=11, bold=True, color=WHITE)

        for j, item in enumerate(items):
            txt(sl, f"— {item}", lft + 0.2, 2.2 + j * 0.9, 2.7, 0.8,
                size=12, color=WHITE if j == 0 else GREY, wrap=True)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 10 — ENVIRONMENTAL COMMITMENT
# ══════════════════════════════════════════════════════════════════════════════
def slide_env(prs):
    sl = blank_slide(prs)
    fill_bg(sl)

    slide_label(sl, "ENVIRONMENTAL COMMITMENT")
    txt(sl, "Art without the carbon footprint", 0.45, 0.5, 12, 0.85,
        size=36, bold=True, color=WHITE)
    accent_bar(sl, top=1.38, width=2.2)

    # big comparison boxes
    box(sl, 0.45, 1.6, 5.7, 2.8, bg=RGBColor(0x18, 0x0A, 0x0A),
        border=RGBColor(0xFF, 0x55, 0x55))
    txt(sl, "Physical Art Event", 0.65, 1.72, 5.3, 0.45,
        size=13, color=RGBColor(0xFF, 0x88, 0x88))
    txt(sl, "30,000", 0.65, 2.1, 5.3, 1.0,
        size=58, bold=True, color=RGBColor(0xFF, 0x55, 0x55))
    txt(sl, "tonnes CO₂e  (Art Basel 2023, single event)",
        0.65, 3.15, 5.3, 0.5, size=12, color=GREY)

    txt(sl, "VS", 6.35, 2.3, 0.65, 0.8,
        size=20, bold=True, color=GREY, align=PP_ALIGN.CENTER)

    box(sl, 7.1, 1.6, 5.78, 2.8, bg=RGBColor(0x06, 0x12, 0x0A),
        border=GREEN)
    txt(sl, "ArtEx Platform", 7.3, 1.72, 5.4, 0.45,
        size=13, color=GREEN)
    txt(sl, "15–30", 7.3, 2.1, 5.4, 1.0,
        size=58, bold=True, color=GREEN)
    txt(sl, "kg CO₂e / month  (at 1,000 daily active users)",
        7.3, 3.15, 5.4, 0.5, size=12, color=GREY)

    divider(sl, 4.6)

    principles = [
        "No Proof-of-Work blockchain — we use certificate-based digital provenance only",
        "100% renewable energy cloud hosting target by end of 2026",
        "Eco-design: lazy loading, efficient queries, minimal JS bundle (< 250 kB gzipped)",
        "No physical shipping, no printed catalogues, no intercontinental art transport",
        "Carbon calculator available in-app so users see their impact per trade",
    ]
    txt(sl, "Our 5 eco-design commitments:", 0.45, 4.7, 6, 0.4,
        size=12, bold=True, color=WHITE)
    for i, p in enumerate(principles):
        txt(sl, f"  {chr(0x2713)}  {p}", 0.45, 5.15 + i * 0.44, 12.43, 0.42,
            size=11, color=GREEN if i == 0 else GREY)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 11 — TEAM
# ══════════════════════════════════════════════════════════════════════════════
def slide_team(prs):
    sl = blank_slide(prs)
    fill_bg(sl)

    slide_label(sl, "OUR TEAM")
    txt(sl, "Built by six EFREI engineers", 0.45, 0.5, 12, 0.85,
        size=36, bold=True, color=WHITE)
    accent_bar(sl, top=1.38, width=2.0)

    members = [
        ("Yuhao Huang",       "Team Lead · PM · Design · Frontend",
         "Vue 3 frontend, Tailwind UI, Vite config,\nproject management, AI feature integration,\ndeployment & design system",
         ACCENT, "YH"),
        ("Yinghui Ren",       "Backend Engineer",
         "Spring Boot REST API, MyBatis/MySQL,\nJWT auth, user controller,\nSpring 4 migration & endpoint design",
         BLUE, "YR"),
        ("Lena Makri",        "Backend Engineer",
         "Spring Boot API co-dev,\nMyBatis mapper layer,\ndata modelling & database queries",
         BLUE, "LM"),
        ("Berena-Jackie\nDouanla",  "Market Research",
         "Competitor analysis (Artsy / OpenSea),\nmarket sizing (TAM/SAM/SOM),\nuser survey & feasibility study",
         GOLD, "BJ"),
        ("Nelson-Harold\nKamteu",   "UML & Architecture",
         "Use-case diagrams, class diagrams,\nsequence diagrams, system architecture\nand technical documentation",
         GREEN, "NK"),
        ("Junior Mevi",       "AI Skill Writing",
         "Dify AI skill authoring,\nprompt engineering for the art advisor,\nAI training data & scenario testing",
         RGBColor(0xC0, 0x84, 0xFF), "JM"),
    ]

    for i, (name, role, desc, col, initials) in enumerate(members):
        c = i % 3
        r = i // 3
        lft = 0.45 + c * 4.3
        tp  = 1.6 + r * 2.85

        box(sl, lft, tp, 4.0, 2.65, bg=PANEL,
            border=col)

        # avatar
        av = sl.shapes.add_shape(9,
            Inches(lft + 0.2), Inches(tp + 0.25), Inches(0.75), Inches(0.75))
        av.fill.solid()
        av.fill.fore_color.rgb = RGBColor(0x1A, 0x1A, 0x25)
        av.line.color.rgb = col
        av.line.width = Pt(1.5)
        txt(sl, initials, lft + 0.2, tp + 0.25, 0.75, 0.75,
            size=14, bold=True, color=col, align=PP_ALIGN.CENTER)

        txt(sl, name, lft + 1.1, tp + 0.25, 2.75, 0.45,
            size=13, bold=True, color=WHITE, wrap=True)
        txt(sl, role, lft + 1.1, tp + 0.7, 2.75, 0.38,
            size=10, color=col, wrap=True)
        txt(sl, desc, lft + 0.2, tp + 1.2, 3.65, 1.35,
            size=10, color=GREY, wrap=True)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 12 — ROADMAP & CLOSING
# ══════════════════════════════════════════════════════════════════════════════
def slide_closing(prs):
    sl = blank_slide(prs)
    fill_bg(sl)

    slide_label(sl, "ROADMAP & NEXT STEPS")
    txt(sl, "What's coming next", 0.45, 0.5, 12, 0.85,
        size=36, bold=True, color=WHITE)
    accent_bar(sl, top=1.38, width=1.8)

    phases = [
        ("Phase 1\n(Done)", "MVP",
         ["Frontend UI complete", "JWT auth + registration",
          "AI chat advisor live", "6 artworks seeded in DB"],
         GREEN),
        ("Phase 2\nQ3 2026", "Growth",
         ["Google OAuth login", "Forgot-password email flow",
          "Artist onboarding portal", "Mobile-responsive redesign"],
         ACCENT),
        ("Phase 3\nQ4 2026", "Scale",
         ["Real fractional ownership (legal)", "Stripe payment integration",
          "Carbon footprint dashboard", "Public beta launch"],
         GOLD),
    ]

    for i, (phase, title, items, col) in enumerate(phases):
        lft = 0.45 + i * 4.3
        box(sl, lft, 1.6, 4.0, 4.5, bg=PANEL, border=col)
        box(sl, lft, 1.6, 4.0, 0.1, bg=col)

        txt(sl, phase, lft + 0.25, 1.72, 3.6, 0.6,
            size=11, color=col, wrap=True)
        txt(sl, title, lft + 0.25, 2.35, 3.6, 0.5,
            size=22, bold=True, color=WHITE)

        for j, item in enumerate(items):
            txt(sl, f"  {chr(0x25B8)}  {item}", lft + 0.2, 2.95 + j * 0.62, 3.7, 0.55,
                size=12, color=WHITE if j == 0 else GREY, wrap=True)

    # closing banner
    box(sl, 0.45, 6.3, 12.43, 0.9, bg=ACCENT)
    txt(sl,
        "ArtEx — Making art investment as liquid and accessible as the stock market.",
        0.65, 6.38, 12.0, 0.75, size=16, bold=True, color=WHITE,
        align=PP_ALIGN.CENTER)


# ══════════════════════════════════════════════════════════════════════════════
# ASSEMBLE
# ══════════════════════════════════════════════════════════════════════════════
def main():
    prs = prs_init()

    print("Building slides...")
    slide_title(prs)       ; print("  1/12  Title")
    slide_problem(prs)     ; print("  2/12  Problem")
    slide_market(prs)      ; print("  3/12  Market Opportunity")
    slide_competitors(prs) ; print("  4/12  Competitive Landscape")
    slide_solution(prs)    ; print("  5/12  Our Solution")
    slide_users(prs)       ; print("  6/12  Target Users")
    slide_features(prs)    ; print("  7/12  Key Features")
    slide_business(prs)    ; print("  8/12  Business Model")
    slide_tech(prs)        ; print("  9/12  Technology Stack")
    slide_env(prs)         ; print(" 10/12  Environmental Commitment")
    slide_team(prs)        ; print(" 11/12  Team & Roles")
    slide_closing(prs)     ; print(" 12/12  Roadmap & Closing")

    out = r"D:\软件工程\L2 第二學期\Innovation project\ArtEx_Summary_Pitch.pptx"
    prs.save(out)
    print(f"\nSaved: {out}")


if __name__ == "__main__":
    main()
