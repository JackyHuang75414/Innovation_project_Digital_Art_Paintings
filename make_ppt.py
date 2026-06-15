from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.util import Inches, Pt
import copy

# ── Palette ───────────────────────────────────────────────────────────────────
BG       = RGBColor(0x09, 0x09, 0x0B)   # near-black
SURFACE  = RGBColor(0x11, 0x11, 0x16)   # card
CORAL    = RGBColor(0xE8, 0x55, 0x2A)   # brand
WHITE    = RGBColor(0xFF, 0xFF, 0xFF)
GRAY     = RGBColor(0x9C, 0xA3, 0xAF)   # gray-400
DIMGRAY  = RGBColor(0x4B, 0x55, 0x63)   # gray-600
GREEN    = RGBColor(0x22, 0xC5, 0x5E)
AMBER    = RGBColor(0xF5, 0x9E, 0x0B)
RED      = RGBColor(0xEF, 0x44, 0x44)
PURPLE   = RGBColor(0x99, 0x45, 0xFF)

W = Inches(13.33)   # widescreen 16:9
H = Inches(7.5)

prs = Presentation()
prs.slide_width  = W
prs.slide_height = H

blank_layout = prs.slide_layouts[6]   # completely blank

# ── Helper functions ──────────────────────────────────────────────────────────

def add_slide():
    return prs.slides.add_slide(blank_layout)

def bg(slide, color=BG):
    fill = slide.background.fill
    fill.solid()
    fill.fore_color.rgb = color

def rect(slide, l, t, w, h, fill_color=None, line_color=None, line_w=Pt(0)):
    shape = slide.shapes.add_shape(1, l, t, w, h)   # MSO_SHAPE_TYPE.RECTANGLE
    shape.line.width = line_w
    if fill_color:
        shape.fill.solid()
        shape.fill.fore_color.rgb = fill_color
    else:
        shape.fill.background()
    if line_color:
        shape.line.color.rgb = line_color
    else:
        shape.line.fill.background()
    return shape

def txt(slide, text, l, t, w, h,
        size=24, color=WHITE, bold=False, italic=False,
        align=PP_ALIGN.LEFT, font_name="Calibri"):
    tb = slide.shapes.add_textbox(l, t, w, h)
    tf = tb.text_frame
    tf.word_wrap = True
    p  = tf.paragraphs[0]
    p.alignment = align
    run = p.add_run()
    run.text = text
    run.font.size  = Pt(size)
    run.font.color.rgb = color
    run.font.bold  = bold
    run.font.italic = italic
    run.font.name  = font_name
    return tb

def label(slide, text, l, t, color=CORAL):
    """Small uppercase tracking label"""
    tb = slide.shapes.add_textbox(l, t, Inches(8), Inches(0.35))
    tf = tb.text_frame
    p  = tf.paragraphs[0]
    run = p.add_run()
    run.text = text.upper()
    run.font.size  = Pt(9)
    run.font.color.rgb = color
    run.font.name  = "Calibri"
    run.font.bold  = True
    return tb

def title_txt(slide, text, l=Inches(0.8), t=Inches(1.1), w=Inches(11.7), size=40):
    return txt(slide, text, l, t, w, Inches(1.1),
               size=size, color=WHITE, bold=False, italic=True,
               font_name="Georgia")

def body_lines(slide, lines, l, t, w=Inches(11), line_h=Inches(0.45)):
    """lines: list of (text, indent, color, size)"""
    y = t
    for (text, indent, color, size) in lines:
        x = l + Inches(indent * 0.3)
        tb = slide.shapes.add_textbox(x, y, w - Inches(indent * 0.3), line_h)
        tf = tb.text_frame
        p  = tf.paragraphs[0]
        run = p.add_run()
        bullet = "• " if indent > 0 else ""
        run.text = bullet + text
        run.font.size  = Pt(size)
        run.font.color.rgb = color
        run.font.name  = "Calibri"
        y += line_h

def accent_bar(slide, t=Inches(0.72), w=Inches(0.55)):
    """Thin coral horizontal rule under section label"""
    rect(slide, Inches(0.8), t, w, Inches(0.04), fill_color=CORAL)

def slide_number(slide, n, total=9):
    txt(slide, f"{n} / {total}",
        Inches(12.2), Inches(7.05), Inches(1), Inches(0.35),
        size=9, color=DIMGRAY, align=PP_ALIGN.RIGHT)

# ── SLIDE 1 — Title ───────────────────────────────────────────────────────────
s = add_slide(); bg(s); slide_number(s, 1)

# Background accent: vertical coral strip on left
rect(s, 0, 0, Inches(0.18), H, fill_color=CORAL)

# Tagline row background
rect(s, Inches(0.18), Inches(4.85), W, Inches(1.15), fill_color=SURFACE)

txt(s, "ArtEx",
    Inches(0.8), Inches(1.2), Inches(11), Inches(1.5),
    size=72, color=WHITE, italic=True, font_name="Georgia")

txt(s, "Fractional Art Trading · Perpetual Futures · AI Automation",
    Inches(0.8), Inches(3.0), Inches(11), Inches(0.6),
    size=20, color=GRAY, font_name="Calibri")

txt(s, "EFREI Innovation Project  ·  2025–2026",
    Inches(0.85), Inches(5.0), Inches(10), Inches(0.45),
    size=13, color=DIMGRAY, font_name="Calibri")

# Three pill tags
for i, (tag, color, dim) in enumerate([
    ("Blockchain-Native", CORAL,  RGBColor(0x3A, 0x15, 0x0A)),
    ("AI-Automated",      PURPLE, RGBColor(0x26, 0x11, 0x40)),
    ("VMM Liquidity",     GREEN,  RGBColor(0x08, 0x31, 0x18)),
]):
    x = Inches(0.85) + i * Inches(2.5)
    rect(s, x, Inches(5.6), Inches(2.2), Inches(0.38),
         fill_color=dim, line_color=color, line_w=Pt(1))
    txt(s, tag, x + Inches(0.15), Inches(5.62), Inches(2.0), Inches(0.36),
        size=11, color=color, font_name="Calibri")

# ── SLIDE 2 — Platform Overview ───────────────────────────────────────────────
s = add_slide(); bg(s); slide_number(s, 2)
rect(s, 0, 0, Inches(0.18), H, fill_color=CORAL)
label(s, "Platform Overview", Inches(0.8), Inches(0.45))
accent_bar(s)
title_txt(s, "What is ArtEx?", size=36)

body_lines(s, [
    ("Premium digital artworks are tokenised into 1,000,000 tradeable fractional shares each.", 0, WHITE, 15),
    ("", 0, WHITE, 6),
    ("Spot Trading", 0, CORAL, 13),
    ("Buy or sell any number of shares at the live market price denominated in BTC, ETH, SOL, BNB or XRP.", 1, GRAY, 13),
    ("", 0, WHITE, 5),
    ("Perpetual Futures", 0, CORAL, 13),
    ("Go long or short on art price movements with up to 50× leverage, using BTC as collateral.", 1, GRAY, 13),
    ("", 0, WHITE, 5),
    ("AI Trading Agents", 0, CORAL, 13),
    ("Deploy built-in momentum / mean-reversion / grid bots, or connect any custom AI via REST API.", 1, GRAY, 13),
    ("", 0, WHITE, 5),
    ("Wallet Integration", 0, CORAL, 13),
    ("MetaMask, Coinbase Wallet, Phantom (Solana) and WalletConnect supported.", 1, GRAY, 13),
], Inches(0.85), Inches(2.3), line_h=Inches(0.38))

# Right panel — key numbers
rect(s, Inches(8.9), Inches(1.5), Inches(4.0), Inches(5.3), fill_color=SURFACE,
     line_color=RGBColor(0x1e, 0x20, 0x30), line_w=Pt(1))
for i, (val, lbl, color) in enumerate([
    ("1 M",   "Shares per artwork", WHITE),
    ("50×",   "Max leverage",       AMBER),
    ("Top 5", "Crypto currencies",  GREEN),
    ("2s",    "VMM tick interval",  PURPLE),
]):
    y = Inches(1.75) + i * Inches(1.2)
    txt(s, val, Inches(9.15), y, Inches(2), Inches(0.65),
        size=32, color=color, bold=True, font_name="Calibri")
    txt(s, lbl, Inches(9.15), y + Inches(0.55), Inches(3.6), Inches(0.35),
        size=11, color=DIMGRAY, font_name="Calibri")

# ── SLIDE 3 — Leverage Mechanism ─────────────────────────────────────────────
s = add_slide(); bg(s); slide_number(s, 3)
rect(s, 0, 0, Inches(0.18), H, fill_color=CORAL)
label(s, "Leverage Mechanism", Inches(0.8), Inches(0.45))
accent_bar(s)
title_txt(s, "Perpetual Futures on Art", size=36)

# Two-column layout
# Left: formula explanation
body_lines(s, [
    ("How it works", 0, WHITE, 15),
    ("User deposits BTC margin → receives USD notional exposure × leverage.", 1, GRAY, 13),
    ("Art price moves in your favour → profits returned as BTC.", 1, GRAY, 13),
    ("", 0, WHITE, 5),
    ("Double Volatility Exposure", 0, CORAL, 13),
    ("Art price uncertainty  ×  BTC price volatility  =  compounded leverage.", 1, AMBER, 13),
    ("Even if art price stays flat, BTC collateral drift affects margin ratio.", 1, GRAY, 12),
    ("", 0, WHITE, 5),
    ("Funding Rate", 0, CORAL, 13),
    ("Paid between longs and shorts every 8h to keep perp price anchored to spot.", 1, GRAY, 13),
], Inches(0.85), Inches(2.35), w=Inches(6.8), line_h=Inches(0.38))

# Right: formula box
rect(s, Inches(8.2), Inches(1.6), Inches(4.7), Inches(5.4), fill_color=SURFACE,
     line_color=RGBColor(0x1e, 0x20, 0x30), line_w=Pt(1))
label(s, "Key Formulas", Inches(8.45), Inches(1.75), color=DIMGRAY)

formulas = [
    ("Notional", "= Margin (BTC) × BTC/USD × Leverage"),
    ("PnL (Long)", "= (Pₜ − P₀) / P₀  ×  Notional"),
    ("Margin Rate", "= (Margin × BTC/USD + PnL) / Notional"),
    ("Liq. Price", "= P₀ × (1 − 1/Lev + 0.5%)"),
    ("10× example", "Liquidated after ~9.5% adverse move"),
    ("50× example", "Liquidated after ~1.5% adverse move"),
]
for i, (key, val) in enumerate(formulas):
    y = Inches(2.15) + i * Inches(0.75)
    txt(s, key, Inches(8.45), y, Inches(1.7), Inches(0.38),
        size=11, color=DIMGRAY, font_name="Calibri")
    txt(s, val, Inches(10.0), y, Inches(2.7), Inches(0.38),
        size=11, color=GREEN if "example" in key else WHITE, font_name="Calibri")

# ── SLIDE 4 — Virtual Market Maker ───────────────────────────────────────────
s = add_slide(); bg(s); slide_number(s, 4)
rect(s, 0, 0, Inches(0.18), H, fill_color=GREEN)
label(s, "Liquidity Infrastructure", Inches(0.8), Inches(0.45), color=GREEN)
accent_bar(s, w=Inches(0.55)); s.shapes[-1].fill.fore_color.rgb = GREEN
title_txt(s, "Virtual Market Maker (VMM)", size=36)

body_lines(s, [
    ("The cold-start problem", 0, WHITE, 14),
    ("A new marketplace has no organic order flow — no liquidity = no traders.", 1, GRAY, 12),
    ("VMM seeds the market with synthetic bid/ask depth from day one.", 1, GRAY, 12),
    ("", 0, WHITE, 5),
    ("Geometric Brownian Motion (GBM)", 0, GREEN, 14),
    ("Price follows:  Sₜ₊₁ = Sₜ · exp( (μ − σ²/2)·Δt + σ·ε·√Δt )", 1, AMBER, 12),
    ("μ = 0.00006  (slight upward drift)     σ = 0.008  (per 2s tick)", 1, GRAY, 12),
    ("ε ~ N(0,1) via Box-Muller transform — true randomness, not pseudo-uniform.", 1, GRAY, 12),
    ("", 0, WHITE, 5),
    ("Order Book Injection", 0, GREEN, 14),
    ("10 VMM levels per side at ±0.3 % spacing, regenerated every 2 seconds.", 1, GRAY, 12),
    ("3–5 fake 'user' orders injected randomly to create organic-looking depth.", 1, GRAY, 12),
    ("", 0, WHITE, 5),
    ("BTC Simulation", 0, GREEN, 14),
    ("Independent GBM for BTC/USD (σ = 0.015) — directly affects perp collateral value.", 1, GRAY, 12),
], Inches(0.85), Inches(2.35), w=Inches(8.5), line_h=Inches(0.37))

# Right: VMM properties
rect(s, Inches(9.8), Inches(2.2), Inches(3.1), Inches(4.5), fill_color=SURFACE,
     line_color=RGBColor(0x22, 0xC5, 0x5E, ), line_w=Pt(1))
for i, (k, v) in enumerate([
    ("Tick", "2 000 ms"),
    ("Spread", "±0.3 %"),
    ("Depth", "10 levels"),
    ("Drift μ", "+ 0.006 %"),
    ("Vol σ", "0.8 % / tick"),
    ("History", "200 pts"),
]):
    y = Inches(2.45) + i * Inches(0.65)
    txt(s, k, Inches(10.0), y, Inches(1.0), Inches(0.38),
        size=10, color=DIMGRAY, font_name="Calibri")
    txt(s, v, Inches(11.2), y, Inches(1.5), Inches(0.38),
        size=13, color=GREEN, bold=True, font_name="Calibri")

# ── SLIDE 5 — Business Model ──────────────────────────────────────────────────
s = add_slide(); bg(s); slide_number(s, 5)
rect(s, 0, 0, Inches(0.18), H, fill_color=AMBER)
label(s, "Revenue Model", Inches(0.8), Inches(0.45), color=AMBER)
accent_bar(s, w=Inches(0.55)); s.shapes[-1].fill.fore_color.rgb = AMBER
title_txt(s, "How the Platform Makes Money", size=36)

streams = [
    ("Trading Fees",        "0.1–0.3% per executed spot trade. Volume-driven — the more active the market, the higher the revenue.",          CORAL),
    ("Spread Capture",      "VMM earns the bid-ask spread on every trade it fills. At high tick-volume this compounds rapidly.",               AMBER),
    ("Perpetual Funding",   "Platform captures a portion of the funding rate flow between longs and shorts (typically 0.01–0.03% / 8h).",      GREEN),
    ("AI Custody Fees",     "2% annual management fee on assets under AI agent management (AUM). Scales with platform adoption.",              PURPLE),
    ("Premium Strategies",  "Subscription tiers: access to advanced AI models, custom endpoint priority, higher leverage limits.",              RGBColor(0x06, 0xB6, 0xD4)),
    ("Artwork Listing",     "One-time tokenisation fee paid by galleries / artists to list new works. Creates curation revenue.",              RGBColor(0xF4, 0x72, 0xB6)),
]
for i, (title, desc, color) in enumerate(streams):
    col = i % 2
    row = i // 2
    x = Inches(0.7) + col * Inches(6.3)
    y = Inches(2.25) + row * Inches(1.6)
    rect(s, x, y, Inches(5.9), Inches(1.45), fill_color=SURFACE,
         line_color=color, line_w=Pt(1))
    rect(s, x, y, Inches(0.12), Inches(1.45), fill_color=color)
    txt(s, title, x + Inches(0.22), y + Inches(0.12), Inches(5.5), Inches(0.38),
        size=13, color=color, bold=True, font_name="Calibri")
    txt(s, desc, x + Inches(0.22), y + Inches(0.55), Inches(5.5), Inches(0.82),
        size=11, color=GRAY, font_name="Calibri")

# ── SLIDE 6 — Platform Flywheel ───────────────────────────────────────────────
s = add_slide(); bg(s); slide_number(s, 6)
rect(s, 0, 0, Inches(0.18), H, fill_color=CORAL)
label(s, "Growth Logic", Inches(0.8), Inches(0.45))
accent_bar(s)
title_txt(s, "The Platform Flywheel", size=36)

# Centre flywheel visual — 5 nodes in a cycle
import math
cx, cy = Inches(6.65), Inches(4.2)
r = Inches(2.2)
nodes = [
    ("More\nArtworks",   CORAL),
    ("Deeper\nLiquidity", GREEN),
    ("More\nTraders",    PURPLE),
    ("More\nVolume",     AMBER),
    ("More\nAI Data",    RGBColor(0x06, 0xB6, 0xD4)),
]
NODE_DIM = {
    CORAL:                      RGBColor(0x2E, 0x11, 0x08),
    GREEN:                      RGBColor(0x08, 0x27, 0x12),
    PURPLE:                     RGBColor(0x1F, 0x0D, 0x33),
    AMBER:                      RGBColor(0x30, 0x1F, 0x03),
    RGBColor(0x06, 0xB6, 0xD4): RGBColor(0x03, 0x24, 0x2A),
}
for i, (label_text, color) in enumerate(nodes):
    angle = math.pi / 2 + i * (2 * math.pi / len(nodes))
    nx = cx + r * math.cos(angle)
    ny = cy - r * math.sin(angle)
    rect(s, nx - Inches(0.8), ny - Inches(0.42), Inches(1.6), Inches(0.84),
         fill_color=NODE_DIM.get(color, RGBColor(0x11, 0x11, 0x16)),
         line_color=color, line_w=Pt(1.5))
    txt(s, label_text,
        nx - Inches(0.75), ny - Inches(0.40), Inches(1.5), Inches(0.80),
        size=11, color=color, align=PP_ALIGN.CENTER, font_name="Calibri")

# Centre label
txt(s, "ArtEx", cx - Inches(0.6), cy - Inches(0.3), Inches(1.2), Inches(0.6),
    size=18, color=WHITE, italic=True, align=PP_ALIGN.CENTER, font_name="Georgia")

# Right side: bullets
body_lines(s, [
    ("VMM seeds liquidity → attracts first wave of traders.", 1, GRAY, 13),
    ("Traders generate volume → fee revenue funds growth.", 1, GRAY, 13),
    ("More volume → better price discovery → fairer market.", 1, GRAY, 13),
    ("", 0, WHITE, 5),
    ("AI network effect", 0, CORAL, 13),
    ("More trading data → smarter AI models → better strategies.", 1, GRAY, 13),
    ("Better strategies → higher returns → attract more capital.", 1, GRAY, 13),
    ("", 0, WHITE, 5),
    ("Monetisation scales with the flywheel —", 0, WHITE, 13),
    ("fees, spread, AUM and data all grow proportionally.", 1, GRAY, 13),
], Inches(9.0), Inches(2.2), w=Inches(4.0), line_h=Inches(0.40))

# ── SLIDE 7 — Tech Architecture ───────────────────────────────────────────────
s = add_slide(); bg(s); slide_number(s, 7)
rect(s, 0, 0, Inches(0.18), H, fill_color=PURPLE)
label(s, "Technical Architecture", Inches(0.8), Inches(0.45), color=PURPLE)
accent_bar(s, w=Inches(0.55)); s.shapes[-1].fill.fore_color.rgb = PURPLE
title_txt(s, "Stack & Infrastructure", size=36)

layers = [
    ("Frontend",  "Vue 3 + Vite + Tailwind CSS · Pinia state · Vue Router",                                 CORAL),
    ("Pricing",   "Pinia trading store · GBM VMM engine · CoinGecko live crypto feed (via Vite proxy)",     AMBER),
    ("AI Layer",  "DeepSeek Chat API (art curator) · Custom AI agent endpoints · Account monitor loop",     PURPLE),
    ("Wallets",   "MetaMask / Coinbase (EIP-1193) · Phantom (Solana) · WalletConnect · Test Wallet",        GREEN),
    ("Backend*",  "FastAPI (Python) · PostgreSQL · Redis · Alembic migrations  [planned]",                  DIMGRAY),
    ("Blockchain","BTC testnet via BlockCypher proxy · On-chain settlement [planned]",                       RGBColor(0x06, 0xB6, 0xD4)),
]
LAYER_DIM = {
    CORAL:                      RGBColor(0x2E, 0x11, 0x08),
    AMBER:                      RGBColor(0x30, 0x1F, 0x03),
    PURPLE:                     RGBColor(0x1F, 0x0D, 0x33),
    GREEN:                      RGBColor(0x08, 0x27, 0x12),
    DIMGRAY:                    RGBColor(0x12, 0x14, 0x16),
    RGBColor(0x06, 0xB6, 0xD4): RGBColor(0x03, 0x24, 0x2A),
}
for i, (layer, detail, color) in enumerate(layers):
    y = Inches(2.1) + i * Inches(0.78)
    rect(s, Inches(0.8), y, Inches(1.5), Inches(0.55),
         fill_color=LAYER_DIM.get(color, SURFACE),
         line_color=color, line_w=Pt(1))
    txt(s, layer, Inches(0.9), y + Inches(0.07), Inches(1.3), Inches(0.38),
        size=11, color=color, bold=True, font_name="Calibri")
    txt(s, detail, Inches(2.55), y + Inches(0.07), Inches(10.5), Inches(0.42),
        size=12, color=GRAY, font_name="Calibri")

txt(s, "* Backend branch scaffolded; frontend operates fully client-side for this demo.",
    Inches(0.85), Inches(7.05), Inches(12), Inches(0.35),
    size=9, color=DIMGRAY, font_name="Calibri")

# ── SLIDE 8 — Roadmap ─────────────────────────────────────────────────────────
s = add_slide(); bg(s); slide_number(s, 8)
rect(s, 0, 0, Inches(0.18), H, fill_color=CORAL)
label(s, "Roadmap", Inches(0.8), Inches(0.45))
accent_bar(s)
title_txt(s, "What's Next", size=36)

phases = [
    ("Phase 1\n(Now)",
     ["Frontend demo: trading terminal, AI agent, wallet connect",
      "VMM providing simulated liquidity and price discovery",
      "DeepSeek-powered art curation chatbot live"],
     CORAL, Inches(0.8)),
    ("Phase 2\n(3 months)",
     ["FastAPI backend + PostgreSQL order book",
      "Real BTC testnet settlement via BlockCypher",
      "Artist / gallery onboarding portal",
      "WalletConnect SDK full integration"],
     AMBER, Inches(3.7)),
    ("Phase 3\n(6 months)",
     ["Mainnet launch with regulatory review",
      "Institutional AI strategy marketplace",
      "Cross-chain support (ETH, SOL, BNB)",
      "DAO governance for artwork listing"],
     GREEN, Inches(6.6)),
    ("Phase 4\n(12 months)",
     ["Physical-digital art bridge (NFC + NFT)",
      "Secondary market royalty engine",
      "Mobile app (React Native)",
      "International gallery partnerships"],
     PURPLE, Inches(9.5)),
]
for title, bullets, color, x in phases:
    rect(s, x, Inches(1.85), Inches(2.65), Inches(5.3),
         fill_color=SURFACE, line_color=color, line_w=Pt(1))
    rect(s, x, Inches(1.85), Inches(2.65), Inches(0.08), fill_color=color)
    txt(s, title, x + Inches(0.15), Inches(2.0), Inches(2.35), Inches(0.75),
        size=14, color=color, bold=True, font_name="Calibri")
    for j, b in enumerate(bullets):
        txt(s, "• " + b,
            x + Inches(0.15), Inches(2.9) + j * Inches(0.55),
            Inches(2.4), Inches(0.5),
            size=10.5, color=GRAY, font_name="Calibri")

# ── SLIDE 9 — The Uncomfortable Truth (subtle) ────────────────────────────────
s = add_slide(); slide_number(s, 9)

# Special background — very dark, almost black, with faint red tint
fill = s.background.fill
fill.solid()
fill.fore_color.rgb = RGBColor(0x06, 0x04, 0x06)

# Faint diagonal line texture via a semi-transparent rect
rect(s, 0, 0, W, H, fill_color=RGBColor(0x0e, 0x04, 0x04))

rect(s, 0, 0, Inches(0.18), H, fill_color=RGBColor(0x6B, 0x21, 0x21))  # muted red strip

label(s, "A Reflection", Inches(0.8), Inches(0.5), color=RGBColor(0x7F, 0x1D, 0x1D))
rect(s, Inches(0.8), Inches(0.78), Inches(0.55), Inches(0.04),
     fill_color=RGBColor(0x7F, 0x1D, 0x1D))

txt(s, "On Speculation and Restraint",
    Inches(0.8), Inches(1.05), Inches(11.5), Inches(1.0),
    size=38, color=RGBColor(0xFE, 0xCA, 0xCA), italic=True, font_name="Georgia")

# Main observation — stated quietly
observations = [
    ("The Mechanism",
     "Strip away the art, the curation, and the crypto branding — and what remains is a price-speculation "
     "engine with a house-maintained order book, leveraged positions, and algorithmically generated "
     "volatility. The structural difference between this platform and online gambling is thinner than we "
     "initially set out to build.",
     RGBColor(0xFE, 0xCA, 0xCA)),

    ("Why It Would Work Regardless",
     "Speculation is a fundamental human instinct. As long as there are people who believe they can "
     "predict price movements — and there always are — the business logic is sound. The platform does "
     "not need the art to be real, the market to be fair, or the odds to be transparent.",
     GRAY),

    ("What Constrains Us",
     "Our group chose not to implement dark patterns: no hidden fees, no fabricated scarcity signals, "
     "no predatory leverage defaults. We could have. We did not. That decision is not commercially "
     "optimal. It is a deliberate ethical constraint, and we believe it is the right one.",
     RGBColor(0x86, 0xEF, 0xAC)),  # muted green
]

y = Inches(2.3)
for title, body, color in observations:
    txt(s, title, Inches(0.85), y, Inches(11.5), Inches(0.38),
        size=12, color=color, bold=True, font_name="Calibri")
    txt(s, body, Inches(0.85), y + Inches(0.37), Inches(11.5), Inches(0.85),
        size=11.5, color=RGBColor(0x71, 0x71, 0x7A), font_name="Calibri")
    y += Inches(1.45)

# Closing line — very small, bottom
txt(s, "\"The most profitable version of this platform is one we chose not to build.\"",
    Inches(0.85), Inches(6.85), Inches(11.5), Inches(0.45),
    size=11, color=RGBColor(0x4B, 0x21, 0x21), italic=True,
    align=PP_ALIGN.CENTER, font_name="Georgia")

# ── Save ──────────────────────────────────────────────────────────────────────
OUT = r"D:\软件工程\L2 第二學期\Innovation project\ArtEx_Pitch_Deck.pptx"
prs.save(OUT)
print("Saved:", OUT)
