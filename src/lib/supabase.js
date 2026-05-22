import { createClient } from '@supabase/supabase-js'

const url = import.meta.env.VITE_SUPABASE_URL
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = url && anonKey
  ? createClient(url, anonKey, {
      auth: { persistSession: true, autoRefreshToken: true },
    })
  : null

export const isSupabaseReady = () => supabase !== null

// Verifica che lo schema iniziale sia applicato leggendo i tipi pensione (seed).
// Ritorna { ok: true, count } se la query va a buon fine,
// altrimenti { ok: false, error: string }.
export async function pingSchema() {
  if (!supabase) return { ok: false, error: 'Client non configurato' }
  const { count, error } = await supabase
    .from('tipi_pensione')
    .select('*', { count: 'exact', head: true })
  if (error) return { ok: false, error: error.message }
  return { ok: true, count: count ?? 0 }
}
