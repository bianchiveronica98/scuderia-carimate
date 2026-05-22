-- =====================================================================
-- Scuderia Carimate - Schema iniziale
-- =====================================================================
-- Crea: 15 tabelle dati + 1 tabella contatori + funzioni + trigger + RLS
-- Da applicare nel SQL Editor di Supabase (project fpxncssulxwegveljvhv).
-- =====================================================================

-- ---------------------------------------------------------------------
-- ESTENSIONI
-- ---------------------------------------------------------------------
create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------
-- 1. PROFILES (estensione di auth.users con ruoli)
-- ---------------------------------------------------------------------
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nome text not null,
  ruolo text not null default 'istruttore' check (ruolo in ('admin', 'istruttore')),
  created_at timestamptz default now()
);

-- Trigger: alla creazione di un utente in auth.users crea un profilo di default
create or replace function handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, nome, ruolo)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'nome', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data->>'ruolo', 'istruttore')
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- Helper functions per RLS
create or replace function user_ruolo()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select ruolo from profiles where id = auth.uid()
$$;

create or replace function is_admin()
returns boolean
language sql
stable
as $$
  select user_ruolo() = 'admin'
$$;

create or replace function is_istruttore()
returns boolean
language sql
stable
as $$
  select user_ruolo() = 'istruttore'
$$;

-- ---------------------------------------------------------------------
-- 2. CLIENTI
-- ---------------------------------------------------------------------
create table if not exists clienti (
  id uuid primary key default gen_random_uuid(),
  codice text unique,                         -- "c01" leggibile in UI
  nome text not null,
  cognome text not null default '',
  telefono text,
  email text,
  note text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ---------------------------------------------------------------------
-- 3. CAVALLI
-- ---------------------------------------------------------------------
create table if not exists cavalli (
  id uuid primary key default gen_random_uuid(),
  codice text unique,                         -- "h01" leggibile in UI
  nome text not null,
  note text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ---------------------------------------------------------------------
-- 4. TIPI PENSIONE
-- ---------------------------------------------------------------------
create table if not exists tipi_pensione (
  id text primary key,                        -- "p1", "p2", ...
  nome text not null,
  prezzo numeric(10, 2) not null default 0,
  ordine int default 0,
  attivo boolean default true
);

-- ---------------------------------------------------------------------
-- 5. RELAZIONI cliente-cavallo
-- ---------------------------------------------------------------------
create table if not exists relazioni (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid not null references clienti(id) on delete cascade,
  cavallo_id uuid not null references cavalli(id) on delete cascade,
  tipo_pensione_id text references tipi_pensione(id),
  prezzo_custom numeric(10, 2),               -- se valorizzato, sovrascrive tipo_pensione.prezzo
  mangime numeric(10, 2) default 0,
  created_at timestamptz default now()
);

create index if not exists idx_relazioni_cliente on relazioni(cliente_id);
create index if not exists idx_relazioni_cavallo on relazioni(cavallo_id);

-- ---------------------------------------------------------------------
-- 6. EXTRAS (servizi extra mensili)
-- ---------------------------------------------------------------------
create table if not exists extras (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid not null references clienti(id) on delete cascade,
  cavallo_id uuid not null references cavalli(id) on delete cascade,
  nome text not null,
  prezzo numeric(10, 2) not null default 0,
  quantita numeric(10, 2) default 1,
  data date not null,
  note text,
  created_at timestamptz default now()
);

create index if not exists idx_extras_cliente_data on extras(cliente_id, data);
create index if not exists idx_extras_cavallo_data on extras(cavallo_id, data);

-- ---------------------------------------------------------------------
-- 7. PAGAMENTI (entrate clienti per mese)
-- ---------------------------------------------------------------------
create table if not exists pagamenti (
  id uuid primary key default gen_random_uuid(),
  mese text not null,                         -- "YYYY-MM"
  cliente_id uuid not null references clienti(id) on delete cascade,
  importo numeric(10, 2) not null,
  metodo text not null check (metodo in ('Bonifico', 'POS', 'Contanti', 'Manuale')),
  data date default current_date,
  created_at timestamptz default now(),
  unique(mese, cliente_id)
);

create index if not exists idx_pagamenti_mese on pagamenti(mese);

-- ---------------------------------------------------------------------
-- 8. RICEVUTE (clienti)
-- ---------------------------------------------------------------------
create table if not exists ricevute (
  id uuid primary key default gen_random_uuid(),
  numero text unique not null,                -- "BON-2026-0001"
  anno int not null,
  prefisso text not null check (prefisso in ('BON', 'POS', 'CON', 'MAN')),
  contatore int not null,
  cliente_id uuid not null references clienti(id),
  mese text not null,
  metodo text not null,
  importo numeric(10, 2) not null,
  data date default current_date,
  created_at timestamptz default now()
);

create index if not exists idx_ricevute_cliente on ricevute(cliente_id);
create index if not exists idx_ricevute_anno_prefisso on ricevute(anno, prefisso);

-- ---------------------------------------------------------------------
-- 9. CATEGORIE USCITE
-- ---------------------------------------------------------------------
create table if not exists categorie_uscite (
  id text primary key,                        -- "u1", "u2", ...
  nome text not null,
  icona text,
  ordine int default 0,
  attivo boolean default true
);

-- ---------------------------------------------------------------------
-- 10. USCITE
-- ---------------------------------------------------------------------
create table if not exists uscite (
  id uuid primary key default gen_random_uuid(),
  mese text not null,                         -- "YYYY-MM"
  data date not null,
  categoria_id text references categorie_uscite(id),
  descrizione text,
  importo numeric(10, 2) not null,
  fornitore text,
  created_at timestamptz default now()
);

create index if not exists idx_uscite_mese on uscite(mese);

-- ---------------------------------------------------------------------
-- 11. FATTURE
-- ---------------------------------------------------------------------
create table if not exists fatture (
  id uuid primary key default gen_random_uuid(),
  fornitore text,
  importo numeric(10, 2),
  data date,
  numero text,
  descrizione text,
  file_url text,                              -- URL Supabase Storage
  file_name text,
  stato text not null default 'da pagare' check (stato in ('da pagare', 'pagata')),
  mese_rif text,                              -- "YYYY-MM"
  created_at timestamptz default now()
);

-- ---------------------------------------------------------------------
-- 12. ALLIEVI (scuola)
-- ---------------------------------------------------------------------
create table if not exists allievi (
  id uuid primary key default gen_random_uuid(),
  codice text unique,                         -- "a01" leggibile
  nome text not null,
  cognome text default '',
  livello text default 'Principiante' check (
    livello in ('Principiante', 'Base', 'Intermedio', 'Avanzato', 'Agonista')
  ),
  istruttrice text default 'Siria' check (istruttrice in ('Siria', 'Laura')),
  telefono text,
  note text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ---------------------------------------------------------------------
-- 13. TIPI PACCHETTO
-- ---------------------------------------------------------------------
create table if not exists tipi_pacchetto (
  id text primary key,                        -- "pk1", "pk2", ...
  nome text not null,
  lezioni int default 0,                      -- 0 = illimitato (personalizzato)
  prezzo numeric(10, 2) default 0,
  ordine int default 0,
  attivo boolean default true
);

-- ---------------------------------------------------------------------
-- 14. PACCHETTI (lezioni acquistati dall'allievo)
-- ---------------------------------------------------------------------
create table if not exists pacchetti (
  id uuid primary key default gen_random_uuid(),
  allievo_id uuid not null references allievi(id) on delete cascade,
  tipo_pacchetto_id text references tipi_pacchetto(id),
  nome text not null,
  lezioni_totali int default 0,
  lezioni_usate int default 0,
  prezzo numeric(10, 2) default 0,
  istruttrice text not null check (istruttrice in ('Siria', 'Laura')),
  data_inizio date default current_date,
  mese_vendita text not null,                 -- "YYYY-MM"
  pagato boolean default false,
  created_at timestamptz default now()
);

create index if not exists idx_pacchetti_allievo on pacchetti(allievo_id);
create index if not exists idx_pacchetti_mese on pacchetti(mese_vendita);

-- ---------------------------------------------------------------------
-- 15. PAGAMENTI SCUOLA
-- ---------------------------------------------------------------------
create table if not exists pagamenti_scuola (
  id uuid primary key default gen_random_uuid(),
  mese text not null,                         -- "YYYY-MM"
  allievo_id uuid not null references allievi(id) on delete cascade,
  importo numeric(10, 2) not null,
  metodo text not null check (metodo in ('Bonifico', 'POS', 'Contanti', 'Manuale')),
  data date default current_date,
  created_at timestamptz default now(),
  unique(mese, allievo_id)
);

create index if not exists idx_pag_scuola_mese on pagamenti_scuola(mese);

-- ---------------------------------------------------------------------
-- 16. RICEVUTE SCUOLA
-- ---------------------------------------------------------------------
create table if not exists ricevute_scuola (
  id uuid primary key default gen_random_uuid(),
  numero text unique not null,                -- "SCU-BON-2026-0001"
  anno int not null,
  prefisso text not null check (prefisso in ('BON', 'POS', 'CON', 'MAN')),
  contatore int not null,
  allievo_id uuid not null references allievi(id),
  mese text not null,
  metodo text not null,
  importo numeric(10, 2) not null,
  data date default current_date,
  created_at timestamptz default now()
);

create index if not exists idx_ricevute_scuola_allievo on ricevute_scuola(allievo_id);
create index if not exists idx_ricevute_scuola_anno_prefisso on ricevute_scuola(anno, prefisso);

-- ---------------------------------------------------------------------
-- 17. CONTATORI RICEVUTE (atomicità per numerazione progressiva)
-- ---------------------------------------------------------------------
create table if not exists contatori_ricevute (
  scope text not null check (scope in ('cliente', 'scuola')),
  prefisso text not null check (prefisso in ('BON', 'POS', 'CON', 'MAN')),
  anno int not null,
  valore int not null default 0,
  primary key (scope, prefisso, anno)
);

-- ---------------------------------------------------------------------
-- FUNZIONE: genera_numero_ricevuta
-- Atomica grazie all'UPSERT su contatori_ricevute.
-- Restituisce il numero formattato pronto da scrivere in ricevute/ricevute_scuola.
-- ---------------------------------------------------------------------
create or replace function genera_numero_ricevuta(
  p_metodo text,
  p_scope text default 'cliente'
)
returns table(numero text, prefisso text, anno int, contatore int)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_prefisso text;
  v_anno int := extract(year from current_date)::int;
  v_contatore int;
  v_numero text;
begin
  v_prefisso := case p_metodo
    when 'Bonifico' then 'BON'
    when 'POS' then 'POS'
    when 'Contanti' then 'CON'
    else 'MAN'
  end;

  insert into contatori_ricevute (scope, prefisso, anno, valore)
  values (p_scope, v_prefisso, v_anno, 1)
  on conflict (scope, prefisso, anno) do update
    set valore = contatori_ricevute.valore + 1
  returning valore into v_contatore;

  if p_scope = 'scuola' then
    v_numero := 'SCU-' || v_prefisso || '-' || v_anno::text || '-' || lpad(v_contatore::text, 4, '0');
  else
    v_numero := v_prefisso || '-' || v_anno::text || '-' || lpad(v_contatore::text, 4, '0');
  end if;

  return query select v_numero, v_prefisso, v_anno, v_contatore;
end;
$$;

-- =====================================================================
-- ROW LEVEL SECURITY
-- =====================================================================
-- admin (Veronica): pieno accesso a tutto
-- istruttore (Siria, Laura): accesso solo a allievi/pacchetti/pagamenti_scuola/
--                           ricevute_scuola/tipi_pacchetto (read)
-- =====================================================================

alter table profiles enable row level security;
alter table clienti enable row level security;
alter table cavalli enable row level security;
alter table tipi_pensione enable row level security;
alter table relazioni enable row level security;
alter table extras enable row level security;
alter table pagamenti enable row level security;
alter table ricevute enable row level security;
alter table categorie_uscite enable row level security;
alter table uscite enable row level security;
alter table fatture enable row level security;
alter table allievi enable row level security;
alter table tipi_pacchetto enable row level security;
alter table pacchetti enable row level security;
alter table pagamenti_scuola enable row level security;
alter table ricevute_scuola enable row level security;
alter table contatori_ricevute enable row level security;

-- ---------- profiles ----------
drop policy if exists "view own profile" on profiles;
create policy "view own profile" on profiles
  for select using (id = auth.uid());

drop policy if exists "admin view all profiles" on profiles;
create policy "admin view all profiles" on profiles
  for select using (is_admin());

drop policy if exists "admin manage profiles" on profiles;
create policy "admin manage profiles" on profiles
  for all using (is_admin()) with check (is_admin());

-- ---------- entità solo-admin (pensione/clienti/cavalli/relazioni/...) ----------
do $$
declare
  t text;
  tables_admin_only text[] := array[
    'clienti', 'cavalli', 'tipi_pensione', 'relazioni', 'extras',
    'pagamenti', 'ricevute', 'categorie_uscite', 'uscite', 'fatture'
  ];
begin
  foreach t in array tables_admin_only loop
    execute format('drop policy if exists "admin full access" on %I', t);
    execute format(
      'create policy "admin full access" on %I for all using (is_admin()) with check (is_admin())',
      t
    );
  end loop;
end $$;

-- ---------- entità condivise (admin + istruttore) ----------
do $$
declare
  t text;
  tables_shared text[] := array[
    'allievi', 'pacchetti', 'pagamenti_scuola', 'ricevute_scuola'
  ];
begin
  foreach t in array tables_shared loop
    execute format('drop policy if exists "auth access" on %I', t);
    execute format(
      'create policy "auth access" on %I for all using (is_admin() or is_istruttore()) with check (is_admin() or is_istruttore())',
      t
    );
  end loop;
end $$;

-- ---------- tipi_pacchetto (read auth, write admin) ----------
drop policy if exists "tipi_pacchetto read" on tipi_pacchetto;
create policy "tipi_pacchetto read" on tipi_pacchetto
  for select using (is_admin() or is_istruttore());

drop policy if exists "tipi_pacchetto write" on tipi_pacchetto;
create policy "tipi_pacchetto write" on tipi_pacchetto
  for all using (is_admin()) with check (is_admin());

-- ---------- contatori_ricevute (nessuna policy = accesso solo via SECURITY DEFINER) ----------
-- La funzione genera_numero_ricevuta() è SECURITY DEFINER e bypassa RLS.
-- Nessun client può accedere direttamente alla tabella, evitando race condition manuali.

-- ---------------------------------------------------------------------
-- TRIGGER updated_at
-- ---------------------------------------------------------------------
create or replace function set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

do $$
declare
  t text;
  tables_with_updated text[] := array['clienti', 'cavalli', 'allievi'];
begin
  foreach t in array tables_with_updated loop
    execute format('drop trigger if exists trg_%I_updated_at on %I', t, t);
    execute format(
      'create trigger trg_%I_updated_at before update on %I
       for each row execute function set_updated_at()',
      t, t
    );
  end loop;
end $$;
