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

## Applicare le migration Supabase

I file SQL sono in `supabase/migrations/`. Per applicarli al progetto:

1. Apri il dashboard Supabase → **SQL Editor** → **New query**
2. Copia il contenuto di `001_initial_schema.sql`, incolla, premi **Run**
3. Stessa cosa con `002_seed_data.sql`
4. Vai in **Authentication → Users → Add user** e crea i 3 account
   (es. `veronica@scuderiacarimate.it`, `siria@…`, `laura@…`)
5. Per assegnare il ruolo admin a Veronica, esegui in SQL Editor:
   ```sql
   update profiles set ruolo = 'admin' where id = (
     select id from auth.users where email = 'veronica@scuderiacarimate.it'
   );
   ```
   (gli altri due restano `istruttore` di default)

A questo punto aprendo `npm run dev` la pagina di setup mostra
**Schema applicato. Trovati 8 tipi pensione nel seed.**

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
2. ✅ Schema database (15 tabelle + RLS + contatori ricevute + seed)
3. ⏳ Auth con ruoli admin / istruttore
4. ⏳ Sezioni Clienti, Cavalli, Entrate, Uscite, Scuola
5. ⏳ Edge Function AI lettura fatture
6. ⏳ PDF ricevute e riepiloghi
7. ⏳ Deploy Vercel
