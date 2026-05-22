# Scuderia Carimate — Gestionale

Web app per la gestione di Scuderia Carimate (Carimate, CO): clienti, cavalli,
pensioni, entrate/uscite, scuola equitazione, ricevute e fatture con AI.

## Stack

- **Frontend**: React 19 + Vite + Tailwind v4
- **Database / Auth / Realtime**: Supabase
- **AI fatture**: Claude (via Supabase Edge Function)
- **PDF**: jsPDF
- **Deploy**: Vercel

## Colori & Font

- Verde scuro brand `#192D1F`
- Beige brand `#E2D8C6`
- Titoli: Cormorant Garamond
- Testo: DM Sans

## Sviluppo locale

```bash
npm install
cp .env.example .env.local   # poi compila VITE_SUPABASE_URL e VITE_SUPABASE_ANON_KEY
npm run dev
```

Build di produzione:

```bash
npm run build
npm run preview
```

## Struttura

```
src/
├── lib/         client Supabase, auth, PDF, AI, matching fuzzy
├── hooks/       useClienti, useCavalli, useEntrate, ...
├── pages/       Login, Clienti, Cavalli, Entrate, Uscite, Scuola
├── components/  Layout, RelCard, Toast, modali
└── styles/      CSS aggiuntivo

supabase/
├── migrations/  schema SQL
└── functions/   Edge Functions (parse-document per Claude AI)
```

## Roadmap

1. ✅ Setup Vite + Tailwind + Supabase client
2. ⏳ Schema database (15 tabelle, RLS, contatori ricevute)
3. ⏳ Auth con ruoli admin / istruttore
4. ⏳ Sezioni Clienti, Cavalli, Entrate, Uscite, Scuola
5. ⏳ Edge Function AI lettura fatture
6. ⏳ PDF ricevute e riepiloghi
7. ⏳ Deploy Vercel
