import { isSupabaseReady } from './lib/supabase'

export default function App() {
  const supabaseReady = isSupabaseReady()

  return (
    <div className="min-h-screen flex items-center justify-center px-4 py-12">
      <div className="w-full max-w-2xl bg-brand-beige rounded-2xl shadow-xl border border-brand-green/10 overflow-hidden">
        <div className="bg-brand-green text-brand-beige px-8 py-10 text-center">
          <p className="font-sans text-xs tracking-[0.3em] uppercase opacity-80 mb-2">
            Gestionale
          </p>
          <h1 className="font-display text-5xl md:text-6xl italic">
            Scuderia Carimate
          </h1>
          <p className="font-sans text-sm mt-3 opacity-80">Carimate (CO)</p>
        </div>

        <div className="px-8 py-8 space-y-6">
          <section>
            <h2 className="font-display text-2xl mb-2">Setup completato</h2>
            <p className="font-sans text-sm leading-relaxed text-brand-green/80">
              Progetto inizializzato con Vite + React, Tailwind v4 con palette
              brand e font Cormorant Garamond / DM Sans. Client Supabase
              configurato e pronto.
            </p>
          </section>

          <section className="bg-brand-beige-soft rounded-xl p-5 border border-brand-green/10">
            <h3 className="font-display text-lg mb-3">Stato connessione</h3>
            <div className="flex items-center gap-3 font-sans text-sm">
              <span
                className={`inline-block w-2.5 h-2.5 rounded-full ${
                  supabaseReady ? 'bg-emerald-600' : 'bg-brand-red'
                }`}
              />
              {supabaseReady ? (
                <span>
                  Variabili Supabase rilevate — client pronto all'uso.
                </span>
              ) : (
                <span>
                  Variabili Supabase non configurate. Copia{' '}
                  <code className="px-1.5 py-0.5 bg-brand-green/5 rounded">
                    .env.example
                  </code>{' '}
                  in{' '}
                  <code className="px-1.5 py-0.5 bg-brand-green/5 rounded">
                    .env.local
                  </code>{' '}
                  e compila <code>VITE_SUPABASE_URL</code> e{' '}
                  <code>VITE_SUPABASE_ANON_KEY</code>.
                </span>
              )}
            </div>
          </section>

          <section>
            <h3 className="font-display text-lg mb-3">Prossime fasi</h3>
            <ol className="font-sans text-sm space-y-1.5 text-brand-green/80 list-decimal list-inside">
              <li>Schema Supabase (15 tabelle + RLS + contatori ricevute)</li>
              <li>Autenticazione (admin + istruttori)</li>
              <li>Sezione Clienti / Cavalli / Relazioni</li>
              <li>Entrate, Uscite, Scuola, AI fatture, PDF, Deploy</li>
            </ol>
          </section>

          <div className="pt-2 flex gap-3 flex-wrap">
            <span className="px-3 py-1.5 rounded-full bg-brand-green text-brand-beige text-xs font-sans">
              #192D1F
            </span>
            <span className="px-3 py-1.5 rounded-full bg-brand-beige-soft border border-brand-green/20 text-xs font-sans">
              #E2D8C6
            </span>
            <span className="px-3 py-1.5 rounded-full border border-brand-green/30 text-xs font-sans">
              Cormorant Garamond + DM Sans
            </span>
          </div>
        </div>
      </div>
    </div>
  )
}
