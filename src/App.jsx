import { useEffect, useState } from 'react'
import { isSupabaseReady, pingSchema } from './lib/supabase'

export default function App() {
  const supabaseReady = isSupabaseReady()
  const [schema, setSchema] = useState({ status: 'loading' })

  useEffect(() => {
    if (!supabaseReady) {
      setSchema({ status: 'no-env' })
      return
    }
    pingSchema().then((r) => {
      if (r.ok) {
        setSchema({ status: 'ok', count: r.count })
      } else {
        setSchema({ status: 'error', error: r.error })
      }
    })
  }, [supabaseReady])

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

        <div className="px-8 py-8 space-y-5">
          <section className="bg-brand-beige-soft rounded-xl p-5 border border-brand-green/10">
            <h3 className="font-display text-lg mb-3">Variabili d'ambiente</h3>
            <div className="flex items-center gap-3 font-sans text-sm">
              <span
                className={`inline-block w-2.5 h-2.5 rounded-full ${
                  supabaseReady ? 'bg-emerald-600' : 'bg-brand-red'
                }`}
              />
              {supabaseReady
                ? "URL e chiave anon rilevate."
                : "Manca .env.local con VITE_SUPABASE_URL e VITE_SUPABASE_ANON_KEY."}
            </div>
          </section>

          <section className="bg-brand-beige-soft rounded-xl p-5 border border-brand-green/10">
            <h3 className="font-display text-lg mb-3">Schema database</h3>
            <div className="flex items-start gap-3 font-sans text-sm">
              <span
                className={`mt-1 inline-block w-2.5 h-2.5 rounded-full flex-shrink-0 ${
                  schema.status === 'ok'
                    ? 'bg-emerald-600'
                    : schema.status === 'loading'
                    ? 'bg-amber-500 animate-pulse'
                    : 'bg-brand-red'
                }`}
              />
              <div>
                {schema.status === 'loading' && 'Test connessione in corso…'}
                {schema.status === 'ok' && (
                  <>
                    Schema applicato. Trovati{' '}
                    <strong>{schema.count}</strong> tipi pensione nel seed.
                  </>
                )}
                {schema.status === 'no-env' && 'Configura prima le variabili sopra.'}
                {schema.status === 'error' && (
                  <>
                    Errore: <code className="text-xs">{schema.error}</code>
                    <br />
                    <span className="text-xs opacity-70">
                      Probabilmente la migration non è stata applicata. Vedi
                      istruzioni nel README.
                    </span>
                  </>
                )}
              </div>
            </div>
          </section>

          <section>
            <h3 className="font-display text-lg mb-3">Prossime fasi</h3>
            <ol className="font-sans text-sm space-y-1.5 text-brand-green/80 list-decimal list-inside">
              <li>Autenticazione (admin + istruttori)</li>
              <li>Sezione Clienti, Cavalli, Relazioni</li>
              <li>Entrate, Uscite, Fatture</li>
              <li>Scuola equitazione</li>
              <li>AI fatture (Edge Function), PDF, Deploy</li>
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
