<script setup>
import { ref } from 'vue'

const activeTab = ref('overview')

const tabs = [
  { id: 'overview',    label: 'Overview' },
  { id: 'footprint',   label: 'Carbon Footprint' },
  { id: 'blockchain',  label: 'Blockchain Strategy' },
  { id: 'ecodesign',   label: 'Eco-Design' },
  { id: 'commitments', label: 'Commitments' },
]

const stats = [
  { value: '~100%',   unit: '',       label: 'Reduction vs. physical\nart shipping & production' },
  { value: '0',       unit: 'PoW',    label: 'Proof-of-Work blockchain\ntransactions executed' },
  { value: '< 30 kg', unit: 'CO₂e',  label: 'Estimated monthly footprint\nat 1,000 daily active users' },
  { value: '100%',    unit: 'RE',     label: 'Renewable energy target\nfor production deployment' },
]

const comparison = [
  { category: 'Artwork transport',        physical: 'Air/road freight per sale',   digital: 'Zero — digital delivery',      saved: '100%' },
  { category: 'Print production',         physical: 'Paper, ink, framing per unit', digital: 'Zero — no physical goods',     saved: '100%' },
  { category: 'Climate-controlled storage', physical: 'Warehouse HVAC 24/7',        digital: 'Cloud storage only',           saved: '>95%' },
  { category: 'Art fair attendance',      physical: 'Flights & hotels per event',  digital: 'Online — no events needed',    saved: '100%' },
  { category: 'Return logistics',         physical: 'Double transport per unsold work', digital: 'Not applicable',           saved: '100%' },
  { category: 'Server infrastructure',    physical: 'N/A',                         digital: 'Cloud compute (minimised)',     saved: 'New — minimised' },
]

const footprintSources = [
  { name: 'End-user Browser (SPA)',      value: '~0.3 g CO₂e / page view',  pct: 62, color: '#22c55e' },
  { name: 'DeepSeek AI Inference',       value: '~0.2–0.5 g CO₂e / call',   pct: 18, color: '#2dd4bf' },
  { name: 'CoinGecko API Polling',       value: 'Negligible (60s interval)', pct: 8,  color: '#fbbf24' },
  { name: 'VMM Computation (client-side)', value: '~0.1W extra CPU',         pct: 8,  color: '#38bdf8' },
  { name: 'Cloud Server (planned)',      value: '~2–5 kg CO₂e/mo (green)',   pct: 4,  color: '#9ca3af' },
]

const blockchainOptions = [
  {
    name: 'Bitcoin (PoW)',
    status: 'not-used',
    statusLabel: 'Not Used',
    color: '#f87171',
    facts: [
      '700–900 kWh per transaction',
      'Equivalent to 1 month of household electricity',
      '~65 MtCO₂e globally per year',
      'Used only as a pricing unit — no real BTC settlement',
    ],
  },
  {
    name: 'Ethereum (PoS)',
    status: 'planned',
    statusLabel: 'Phase 4 Plan',
    color: '#2dd4bf',
    facts: [
      '~0.03 kWh per transaction',
      '99.95% less energy than PoW (post-Merge)',
      '~0.01 kg CO₂e per transaction',
      'Only PoS chains permitted if on-chain settlement added',
    ],
  },
  {
    name: 'ArtEx POC (Current)',
    status: 'active',
    statusLabel: 'Active Now',
    color: '#22c55e',
    facts: [
      '0 blockchain transactions executed',
      'Ownership stored in PostgreSQL database',
      '~0 kg CO₂e from settlement layer',
      'Full trading simulation with zero chain footprint',
    ],
  },
]

const ecoDesignItems = [
  {
    title: 'Single-Page Application',
    desc: 'No full-page reloads. Only changed components re-render, reducing HTTP requests and server compute per interaction.',
    icon: '⚡',
    color: '#22c55e',
  },
  {
    title: 'API Call Minimisation',
    desc: 'CoinGecko polled every 60 seconds, not real-time. Results cached in Pinia store to eliminate redundant server fetches.',
    icon: '📡',
    color: '#2dd4bf',
  },
  {
    title: 'Client-Side VMM',
    desc: 'Price simulation (Geometric Brownian Motion) runs entirely in the user\'s browser — no dedicated server required for continuous price generation.',
    icon: '🖥',
    color: '#4ade80',
  },
  {
    title: 'Production Build Optimisation',
    desc: 'Vite tree-shaking, code-splitting, and minification produce smaller JS bundles, reducing energy consumed per page load.',
    icon: '📦',
    color: '#38bdf8',
  },
  {
    title: 'CDN Image Delivery',
    desc: 'Artwork images delivered from Wikimedia Commons CDN — globally cached at the edge, avoiding redundant origin fetches.',
    icon: '🌐',
    color: '#fbbf24',
  },
  {
    title: 'No Physical Goods',
    desc: 'Purely digital platform — no printing, no shipping, no packaging. Zero Scope 3 emissions from the physical supply chain.',
    icon: '♻️',
    color: '#22c55e',
  },
  {
    title: 'Green Hosting Target',
    desc: 'Production deployment planned on Vercel or Fly.io, both operating on 100% renewable energy (RE100 commitment).',
    icon: '🌱',
    color: '#2dd4bf',
  },
  {
    title: 'Efficient Data Queries',
    desc: 'SQLAlchemy async ORM with pagination and indexed queries keeps per-API-call compute minimal, reducing server energy use.',
    icon: '🗄',
    color: '#4ade80',
  },
]

const commitments = [
  {
    when: 'Q4 2026',
    title: '100% Renewable Energy Hosting',
    desc: 'Deploy on Vercel or Fly.io (RE100 certified). Net-zero Scope 2 emissions from day one of production launch.',
    color: '#22c55e',
    done: false,
  },
  {
    when: 'Q4 2026',
    title: 'PoS-Only Blockchain Policy',
    desc: 'If on-chain settlement is added, only Ethereum PoS or Layer 2 networks (Polygon, Arbitrum, Base) are permitted.',
    color: '#2dd4bf',
    done: false,
  },
  {
    when: 'Q1 2027',
    title: 'Carbon-Neutral AI Inference',
    desc: 'Select AI providers with verified carbon offsets, or evaluate efficient local model deployment for the AI Account Monitor.',
    color: '#4ade80',
    done: false,
  },
  {
    when: 'Q2 2027',
    title: 'User Carbon Transparency',
    desc: 'Display estimated CO₂e footprint per trading session in account settings — empowering users to make informed choices.',
    color: '#38bdf8',
    done: false,
  },
  {
    when: 'Annual',
    title: 'Digital Sobriety Audit',
    desc: 'Annual review of API call frequency, JS bundle size, server compute efficiency, and AI inference volume.',
    color: '#fbbf24',
    done: false,
  },
  {
    when: 'Q4 2027',
    title: 'Artist Sustainability Criteria',
    desc: 'Partner only with artists whose practice produces no physical waste — born-digital works only. No print-on-demand.',
    color: '#22c55e',
    done: false,
  },
]

const lcaPhases = [
  {
    phase: 'Development',
    period: 'Oct 2025 – Jun 2026',
    impact: '50–100 kg CO₂e total',
    color: '#38bdf8',
    items: [
      'Developer workstations: ~15–20W each',
      'Git / CI pipeline: negligible',
      'No production servers active during POC',
      'Equivalent to ~5 hours of transatlantic flying',
    ],
  },
  {
    phase: 'Operation',
    period: 'From Q4 2026',
    impact: '15–30 kg CO₂e / month',
    color: '#22c55e',
    items: [
      '1,000 DAU on green cloud hosting',
      'Scope 2 → 0 with 100% renewable energy',
      'AI inference is dominant cost (~60%)',
      'CDN delivery: near-zero marginal cost',
    ],
  },
  {
    phase: 'End-of-Life',
    period: 'When decommissioned',
    impact: '~0 kg CO₂e',
    color: '#2dd4bf',
    items: [
      'No physical hardware to dispose of',
      'Cloud instances shut down instantly',
      'Data deletion per GDPR Article 17',
      'No e-waste — pure software product',
    ],
  },
]
</script>

<template>
  <div class="min-h-screen bg-[#09090b] text-gray-100">

    <!-- ── Hero ──────────────────────────────────────────────────────────────── -->
    <section class="relative overflow-hidden border-b border-white/[0.06]">
      <!-- background glow -->
      <div class="absolute inset-0 pointer-events-none">
        <div class="absolute top-0 left-1/4 w-[600px] h-[600px] rounded-full bg-green-500/5 blur-3xl" />
        <div class="absolute bottom-0 right-1/4 w-[400px] h-[400px] rounded-full bg-teal-500/5 blur-3xl" />
      </div>

      <div class="relative max-w-screen-xl mx-auto px-6 lg:px-16 pt-20 pb-16">
        <!-- eyebrow -->
        <p class="text-[10px] tracking-[0.3em] uppercase text-green-500 mb-4 font-light">
          Environmental Impact & Eco-Design
        </p>

        <h1 class="font-display text-4xl lg:text-6xl font-light text-white mb-4 leading-tight">
          Sustainable by <span class="italic text-green-400">Design</span>
        </h1>
        <p class="text-gray-400 text-lg max-w-2xl mb-12 font-light leading-relaxed">
          ArtEx is built from the ground up to minimise its environmental footprint.
          Digital art trading eliminates the largest sources of emissions in the traditional
          art market — and we're committed to doing even more.
        </p>

        <!-- key stats -->
        <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
          <div
            v-for="s in stats" :key="s.label"
            class="bg-[#111116] border border-white/[0.07] p-5"
          >
            <div class="flex items-baseline gap-1.5 mb-2">
              <span class="text-3xl font-bold text-green-400 tabular-nums">{{ s.value }}</span>
              <span v-if="s.unit" class="text-sm text-green-600 font-mono uppercase">{{ s.unit }}</span>
            </div>
            <p class="text-[11px] text-gray-500 leading-relaxed whitespace-pre-line font-light">{{ s.label }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- ── Tab nav ────────────────────────────────────────────────────────────── -->
    <div class="sticky top-16 z-30 bg-[#09090b]/95 backdrop-blur-md border-b border-white/[0.06]">
      <div class="max-w-screen-xl mx-auto px-6 lg:px-16">
        <div class="flex gap-0 overflow-x-auto no-scrollbar">
          <button
            v-for="t in tabs" :key="t.id"
            class="flex-shrink-0 px-5 py-4 text-[11px] tracking-[0.15em] uppercase font-light transition-colors border-b-2"
            :class="activeTab === t.id
              ? 'text-green-400 border-green-500'
              : 'text-gray-500 border-transparent hover:text-gray-300'"
            @click="activeTab = t.id"
          >
            {{ t.label }}
          </button>
        </div>
      </div>
    </div>

    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-14">

      <!-- ── OVERVIEW ─────────────────────────────────────────────────────────── -->
      <section v-if="activeTab === 'overview'">
        <div class="mb-10">
          <p class="text-[10px] tracking-[0.25em] uppercase text-green-500 mb-2">The Case for Digital</p>
          <h2 class="text-2xl font-light text-white mb-3">Digital Art vs. Physical Art Market</h2>
          <p class="text-gray-400 text-sm max-w-2xl font-light leading-relaxed">
            The traditional art market generates significant hidden emissions — international shipping,
            climate-controlled storage, physical print production, and massive art fair events.
            Art Basel Geneva alone produces an estimated 30,000 tCO₂e per edition.
            ArtEx replaces all of this with a pure digital exchange.
          </p>
        </div>

        <!-- comparison table -->
        <div class="bg-[#111116] border border-white/[0.07] overflow-hidden mb-10">
          <div class="grid grid-cols-4 text-[10px] tracking-[0.2em] uppercase text-gray-500 px-5 py-3 border-b border-white/[0.06]">
            <span>Category</span>
            <span>Physical Art Market</span>
            <span>ArtEx (Digital)</span>
            <span class="text-green-500">Saved</span>
          </div>
          <div
            v-for="(row, i) in comparison" :key="row.category"
            class="grid grid-cols-4 px-5 py-4 text-sm"
            :class="i % 2 === 0 ? 'bg-white/[0.02]' : ''"
          >
            <span class="text-gray-300 font-light">{{ row.category }}</span>
            <span class="text-red-400/80 font-light text-xs flex items-center gap-1">
              <span class="w-1 h-1 rounded-full bg-red-500 flex-shrink-0" />
              {{ row.physical }}
            </span>
            <span class="text-green-400/80 font-light text-xs flex items-center gap-1">
              <span class="w-1 h-1 rounded-full bg-green-500 flex-shrink-0" />
              {{ row.digital }}
            </span>
            <span class="text-green-400 font-mono text-xs font-medium">{{ row.saved }}</span>
          </div>
        </div>

        <!-- art basel callout -->
        <div class="bg-[#111116] border border-red-500/20 p-8 flex flex-col lg:flex-row items-start lg:items-center gap-6">
          <div class="flex-shrink-0">
            <p class="text-6xl font-bold text-red-400 tabular-nums">30,000</p>
            <p class="text-lg text-red-400 font-mono">tCO₂e</p>
            <p class="text-xs text-gray-500 mt-1">Art Basel Geneva, per edition</p>
          </div>
          <div class="w-px h-16 bg-white/[0.07] hidden lg:block flex-shrink-0" />
          <div>
            <p class="text-white text-sm font-light leading-relaxed mb-2">
              This is equivalent to <span class="text-red-400 font-medium">6,500 return flights</span> from
              Paris to New York — for a single art fair. The traditional art world's carbon footprint
              is enormous and structurally embedded in how physical works are traded.
            </p>
            <p class="text-green-400 text-sm font-medium">
              ArtEx produces none of these emissions. Every transaction is digital.
            </p>
          </div>
        </div>
      </section>

      <!-- ── CARBON FOOTPRINT ──────────────────────────────────────────────────── -->
      <section v-else-if="activeTab === 'footprint'">
        <div class="mb-10">
          <p class="text-[10px] tracking-[0.25em] uppercase text-green-500 mb-2">Platform Energy Profile</p>
          <h2 class="text-2xl font-light text-white mb-3">Estimated Carbon Footprint</h2>
          <p class="text-gray-400 text-sm max-w-2xl font-light leading-relaxed">
            At 1,000 daily active users, ArtEx is estimated to produce 15–30 kg CO₂e per month.
            That's roughly equivalent to 8 km of transatlantic flying — negligible compared to
            any physical art marketplace.
          </p>
        </div>

        <!-- bar chart -->
        <div class="bg-[#111116] border border-white/[0.07] p-8 mb-8">
          <p class="text-[10px] tracking-[0.2em] uppercase text-gray-500 mb-6">Footprint by Source</p>
          <div class="space-y-5">
            <div v-for="s in footprintSources" :key="s.name">
              <div class="flex items-center justify-between mb-2">
                <span class="text-sm text-gray-300 font-light">{{ s.name }}</span>
                <span class="text-xs font-mono" :style="{ color: s.color }">{{ s.value }}</span>
              </div>
              <div class="h-2 bg-white/[0.05] rounded-full overflow-hidden">
                <div
                  class="h-full rounded-full transition-all duration-700"
                  :style="{ width: s.pct + '%', backgroundColor: s.color }"
                />
              </div>
              <p class="text-[10px] text-gray-600 mt-1 text-right">{{ s.pct }}% of total</p>
            </div>
          </div>
        </div>

        <!-- summary cards -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-4 mb-8">
          <div class="bg-[#111116] border border-green-500/20 p-6">
            <p class="text-[10px] tracking-[0.2em] uppercase text-gray-500 mb-3">Monthly Estimate (1K DAU)</p>
            <p class="text-4xl font-bold text-green-400 mb-1">15–30 kg</p>
            <p class="text-sm text-gray-500 font-light">CO₂e per month</p>
            <div class="mt-4 pt-4 border-t border-white/[0.06]">
              <p class="text-xs text-gray-500">≈ 8 km of transatlantic flight</p>
            </div>
          </div>
          <div class="bg-[#111116] border border-teal-500/20 p-6">
            <p class="text-[10px] tracking-[0.2em] uppercase text-gray-500 mb-3">With Green Hosting (Target)</p>
            <p class="text-4xl font-bold text-teal-400 mb-1">~0 kg</p>
            <p class="text-sm text-gray-500 font-light">Scope 2 CO₂e (Scope 1 already 0)</p>
            <div class="mt-4 pt-4 border-t border-white/[0.06]">
              <p class="text-xs text-gray-500">Vercel / Fly.io — 100% renewable energy</p>
            </div>
          </div>
          <div class="bg-[#111116] border border-red-500/20 p-6">
            <p class="text-[10px] tracking-[0.2em] uppercase text-gray-500 mb-3">Traditional Art Fair (reference)</p>
            <p class="text-4xl font-bold text-red-400 mb-1">30,000 t</p>
            <p class="text-sm text-gray-500 font-light">CO₂e per Art Basel Geneva edition</p>
            <div class="mt-4 pt-4 border-t border-white/[0.06]">
              <p class="text-xs text-gray-500">1,000,000× more than ArtEx per month</p>
            </div>
          </div>
        </div>

        <!-- Lifecycle Assessment -->
        <div>
          <p class="text-[10px] tracking-[0.25em] uppercase text-gray-500 mb-4">Lifecycle Assessment (ISO 14040/14044)</p>
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
            <div
              v-for="phase in lcaPhases" :key="phase.phase"
              class="bg-[#111116] border border-white/[0.07] p-6"
            >
              <div class="flex items-start justify-between mb-4">
                <div>
                  <p class="text-sm font-medium" :style="{ color: phase.color }">{{ phase.phase }}</p>
                  <p class="text-[10px] text-gray-500 mt-0.5">{{ phase.period }}</p>
                </div>
                <span
                  class="text-xs font-mono px-2 py-0.5 border font-medium"
                  :style="{ color: phase.color, borderColor: phase.color + '44' }"
                >{{ phase.impact }}</span>
              </div>
              <ul class="space-y-2">
                <li
                  v-for="item in phase.items" :key="item"
                  class="flex items-start gap-2 text-xs text-gray-400 font-light"
                >
                  <span class="w-1 h-1 rounded-full mt-1.5 flex-shrink-0" :style="{ backgroundColor: phase.color }" />
                  {{ item }}
                </li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      <!-- ── BLOCKCHAIN STRATEGY ───────────────────────────────────────────────── -->
      <section v-else-if="activeTab === 'blockchain'">
        <div class="mb-10">
          <p class="text-[10px] tracking-[0.25em] uppercase text-green-500 mb-2">A Deliberate Architectural Choice</p>
          <h2 class="text-2xl font-light text-white mb-3">Why We Avoided Proof-of-Work</h2>
          <p class="text-gray-400 text-sm max-w-2xl font-light leading-relaxed">
            One of the most significant environmental decisions in ArtEx's architecture was the
            explicit choice not to use Proof-of-Work blockchains for settlement.
            All ownership records are maintained in a PostgreSQL database in the current POC —
            producing zero blockchain-related emissions.
          </p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-4 mb-10">
          <div
            v-for="opt in blockchainOptions" :key="opt.name"
            class="bg-[#111116] border border-white/[0.07] p-6"
            :style="{ borderTopColor: opt.color, borderTopWidth: '2px' }"
          >
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-base font-medium text-white">{{ opt.name }}</h3>
              <span
                class="text-[9px] tracking-[0.15em] uppercase px-2 py-0.5 font-medium"
                :class="{
                  'bg-red-500/10 text-red-400': opt.status === 'not-used',
                  'bg-teal-500/10 text-teal-400': opt.status === 'planned',
                  'bg-green-500/10 text-green-400': opt.status === 'active',
                }"
              >{{ opt.statusLabel }}</span>
            </div>
            <ul class="space-y-3">
              <li
                v-for="fact in opt.facts" :key="fact"
                class="flex items-start gap-2.5 text-sm font-light"
                :class="opt.status === 'not-used' ? 'text-gray-400' : 'text-gray-300'"
              >
                <span
                  class="w-1.5 h-1.5 rounded-full mt-1.5 flex-shrink-0"
                  :style="{ backgroundColor: opt.color }"
                />
                {{ fact }}
              </li>
            </ul>
          </div>
        </div>

        <!-- Layer 2 note -->
        <div class="bg-teal-500/5 border border-teal-500/20 p-6">
          <p class="text-[10px] tracking-[0.2em] uppercase text-teal-500 mb-2">Future Roadmap</p>
          <p class="text-sm text-gray-300 font-light leading-relaxed">
            Layer 2 networks (Polygon, Arbitrum, Base) reduce energy consumption by a further ~99%
            compared to Ethereum L1 — approximately <span class="text-teal-400 font-medium">0.0003 kWh per transaction</span>.
            If on-chain settlement is introduced in Phase 4, ArtEx commits to using Layer 2 exclusively,
            making each trade energetically comparable to a Google search.
          </p>
        </div>
      </section>

      <!-- ── ECO-DESIGN ────────────────────────────────────────────────────────── -->
      <section v-else-if="activeTab === 'ecodesign'">
        <div class="mb-10">
          <p class="text-[10px] tracking-[0.25em] uppercase text-green-500 mb-2">Built Sustainably</p>
          <h2 class="text-2xl font-light text-white mb-3">Eco-Design Principles</h2>
          <p class="text-gray-400 text-sm max-w-2xl font-light leading-relaxed">
            Every architectural and engineering decision in ArtEx was evaluated for its
            environmental impact. These are the eight principles we applied throughout development.
          </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div
            v-for="item in ecoDesignItems" :key="item.title"
            class="bg-[#111116] border border-white/[0.07] p-6 flex gap-4"
          >
            <div
              class="text-2xl w-10 h-10 flex items-center justify-center flex-shrink-0"
            >{{ item.icon }}</div>
            <div>
              <h3 class="text-sm font-medium mb-1.5" :style="{ color: item.color }">{{ item.title }}</h3>
              <p class="text-xs text-gray-400 font-light leading-relaxed">{{ item.desc }}</p>
            </div>
          </div>
        </div>

        <!-- scope breakdown -->
        <div class="mt-10 bg-[#111116] border border-white/[0.07] p-8">
          <p class="text-[10px] tracking-[0.2em] uppercase text-gray-500 mb-5">GHG Protocol Scope Assessment</p>
          <div class="grid grid-cols-3 gap-6">
            <div v-for="scope in [
              { num: 1, label: 'Direct Emissions', value: '0', note: 'No owned vehicles, no fuel combustion, no industrial processes' },
              { num: 2, label: 'Electricity (Indirect)', value: '~0*', note: '*With planned green hosting (Vercel / Fly.io RE100)' },
              { num: 3, label: 'Value Chain', value: 'Minimised', note: 'No physical goods supply chain; AI inference is dominant residual' },
            ]" :key="scope.num">
              <div class="text-center">
                <p class="text-[10px] tracking-[0.2em] uppercase text-gray-500 mb-2">Scope {{ scope.num }}</p>
                <p class="text-3xl font-bold text-green-400 mb-1">{{ scope.value }}</p>
                <p class="text-xs text-gray-300 font-medium mb-2">{{ scope.label }}</p>
                <p class="text-[10px] text-gray-500 font-light leading-relaxed">{{ scope.note }}</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- ── COMMITMENTS ───────────────────────────────────────────────────────── -->
      <section v-else-if="activeTab === 'commitments'">
        <div class="mb-10">
          <p class="text-[10px] tracking-[0.25em] uppercase text-green-500 mb-2">Our Promises</p>
          <h2 class="text-2xl font-light text-white mb-3">Environmental Commitments</h2>
          <p class="text-gray-400 text-sm max-w-2xl font-light leading-relaxed">
            These are concrete, time-bound commitments made by the ArtEx team for our
            production deployment roadmap. We believe sustainability must be measurable.
          </p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-10">
          <div
            v-for="c in commitments" :key="c.title"
            class="bg-[#111116] border border-white/[0.07] p-6"
          >
            <div class="flex items-start justify-between mb-3">
              <h3 class="text-sm font-medium text-white pr-4">{{ c.title }}</h3>
              <span
                class="text-[9px] tracking-[0.15em] uppercase px-2 py-0.5 flex-shrink-0 font-medium border"
                :style="{ color: c.color, borderColor: c.color + '44' }"
              >{{ c.when }}</span>
            </div>
            <p class="text-xs text-gray-400 font-light leading-relaxed">{{ c.desc }}</p>
            <div class="mt-4 h-0.5 w-8" :style="{ backgroundColor: c.color }" />
          </div>
        </div>

        <!-- regulatory context -->
        <div class="bg-[#111116] border border-white/[0.07] p-8">
          <p class="text-[10px] tracking-[0.2em] uppercase text-gray-500 mb-5">Regulatory Context</p>
          <div class="space-y-3">
            <div
              v-for="reg in [
                { name: 'EU Taxonomy Regulation (2020/852)', status: 'Monitor', color: '#fbbf24', note: 'Digital platforms not yet classified; ArtEx aligns with taxonomy spirit' },
                { name: 'CSRD — Corporate Sustainability Reporting Directive', status: 'Future', color: '#38bdf8', note: 'Applicable if ArtEx scales beyond startup; Scope 1/2/3 reporting ready' },
                { name: 'French Loi REEN (2021)', status: 'Planned', color: '#22c55e', note: 'Annual digital sobriety audit committed from Phase 6 (>100K French users)' },
                { name: 'MiCA — Markets in Crypto-Assets (EU, 2023)', status: 'Low Risk', color: '#2dd4bf', note: 'No proprietary blockchain used; minimal environmental disclosure obligation' },
              ]" :key="reg.name"
              class="flex items-start justify-between gap-4 py-3 border-b border-white/[0.04] last:border-0"
            >
              <div>
                <p class="text-sm text-gray-300 font-light">{{ reg.name }}</p>
                <p class="text-xs text-gray-500 mt-0.5">{{ reg.note }}</p>
              </div>
              <span
                class="text-[9px] tracking-[0.15em] uppercase px-2 py-0.5 flex-shrink-0 font-medium"
                :style="{ color: reg.color, backgroundColor: reg.color + '18' }"
              >{{ reg.status }}</span>
            </div>
          </div>
        </div>

        <!-- closing quote -->
        <div class="mt-10 text-center py-10 border-t border-white/[0.06]">
          <p class="text-lg text-green-400 italic font-light max-w-2xl mx-auto leading-relaxed">
            "The most sustainable platform is one that replaces physical commerce entirely —
            that is ArtEx."
          </p>
          <p class="text-xs text-gray-600 mt-3">ArtEx Team · EFREI Paris Innovation Project 2025–2026</p>
        </div>
      </section>

    </div>
  </div>
</template>

<style scoped>
.no-scrollbar::-webkit-scrollbar { display: none; }
.no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
</style>
