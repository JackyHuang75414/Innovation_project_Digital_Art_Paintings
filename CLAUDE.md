# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Digital Art Paintings** — AI-powered digital art marketplace (POC, EFREI 2025–2026).  
Customers browse and buy digital art prints; an AI agent recommends artworks based on preferences; orders are fulfilled via print-on-demand (Gelato / Printful). AI customer service and recommendation workflows are built in **Dify** and embedded into the frontend.

## Repository layout

```
/
├── frontend/   # Vue 3 + Tailwind CSS SPA
└── backend/    # Python (FastAPI) REST API
```

Two long-lived branches mirror this split: `frontend` and `backend`. Feature work branches off the relevant branch and is merged back via PR.

## Frontend (`frontend/`)

**Stack:** Vue 3 (Composition API, `<script setup>`) · Vite · Tailwind CSS · Vue Router · Pinia

```bash
cd frontend
npm install
npm run dev        # dev server on http://localhost:5173
npm run build      # production build -> dist/
npm run preview    # preview production build
npm run lint       # ESLint
```

Key conventions:
- Components live in `src/components/`, pages in `src/views/`, global state in `src/stores/` (Pinia).
- Tailwind utility classes only — no custom CSS files unless unavoidable.
- Dify chatbot widget is embedded via a `<script>` snippet in `index.html`; a dedicated `DifyChat.vue` wrapper component exposes it to the Vue app. Reserve space for it on every page via a fixed bottom-right container (`#dify-chat-root`).
- API calls go through `src/api/` (one file per domain, e.g. `artworks.js`, `orders.js`) using `fetch` or `axios` with a shared base URL from `import.meta.env.VITE_API_BASE_URL`.

## Backend (`backend/`)

**Stack:** Python 3.11+ · FastAPI · SQLAlchemy (async) · Alembic · PostgreSQL · Redis (cache)

```bash
cd backend
python -m venv .venv && source .venv/Scripts/activate  # Windows
pip install -r requirements.txt
alembic upgrade head          # run migrations
uvicorn app.main:app --reload # dev server on http://localhost:8000
pytest                        # run all tests
pytest tests/test_artworks.py # run a single test file
```

Structure: `app/main.py` mounts routers; routers live in `app/routers/`; business logic in `app/services/`; DB models in `app/models/`; Pydantic schemas in `app/schemas/`.

Environment variables are loaded from `.env` (never committed). Required keys: `DATABASE_URL`, `REDIS_URL`, `ETSY_API_KEY`, `PRINTFUL_API_KEY`, `DIFY_API_KEY`.

## Dify AI integration

Dify hosts two workflows:
1. **AI Recommendation Agent** — takes user preference profile, returns ranked artwork IDs.
2. **AI Customer Service Chatbot** — conversational support embedded in the site.

Both are called from the frontend via Dify's public embed script / REST API. The backend may also call the recommendation workflow server-side (via `DIFY_API_KEY`). Do not re-implement recommendation logic in Python; delegate to Dify.

## External APIs

| Service | Purpose | Env var |
|---------|---------|---------|
| Etsy API | Sync listings, fetch reviews | `ETSY_API_KEY` |
| Printful / Gelato | Print-on-demand order fulfilment | `PRINTFUL_API_KEY` |
| Dify | AI workflows + chatbot | `DIFY_API_KEY` |

## Branch strategy

| Branch | Purpose |
|--------|---------|
| `main` | Stable, demo-ready |
| `frontend` | All Vue/Tailwind work |
| `backend` | All FastAPI work |
| `feature/*` | Short-lived feature branches off `frontend` or `backend` |
