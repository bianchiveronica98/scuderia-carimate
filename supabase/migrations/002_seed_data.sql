-- =====================================================================
-- Scuderia Carimate - Seed data
-- =====================================================================
-- Inserisce: 8 tipi pensione, 11 categorie uscite, 7 tipi pacchetto
-- Idempotente (ON CONFLICT DO NOTHING) — sicuro da rieseguire.
-- =====================================================================

-- ---------------------------------------------------------------------
-- TIPI PENSIONE
-- ---------------------------------------------------------------------
insert into tipi_pensione (id, nome, prezzo, ordine) values
  ('p1', 'Pensione italiana',              870, 1),
  ('p2', 'Pensione inglese',               750, 2),
  ('p3', 'Pensione 2° cavallo',            710, 3),
  ('p4', 'Pensione no mangime',            710, 4),
  ('p5', 'Pensione commercio',             650, 5),
  ('p6', 'Pensione commercio no mangime',  620, 6),
  ('p7', 'Mezzafida',                      390, 7),
  ('p8', 'Pensione personalizzata',          0, 8)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- CATEGORIE USCITE
-- ---------------------------------------------------------------------
insert into categorie_uscite (id, nome, icona, ordine) values
  ('u1',  'Foraggio / fieno / paglia',  '🌾', 1),
  ('u2',  'Mangimi',                    '🥣', 2),
  ('u3',  'Veterinario',                '💉', 3),
  ('u4',  'Farmaci e medicinali',       '💊', 4),
  ('u5',  'Ferratura',                  '🔨', 5),
  ('u6',  'Manutenzione strutture',     '🔧', 6),
  ('u7',  'Utenze (luce, acqua, gas)',  '⚡', 7),
  ('u8',  'Personale / collaboratori',  '👷', 8),
  ('u9',  'Attrezzatura e selleria',    '🏇', 9),
  ('u10', 'Affitto',                    '🏠', 10),
  ('u11', 'Altro',                      '📋', 11)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- TIPI PACCHETTO
-- ---------------------------------------------------------------------
insert into tipi_pacchetto (id, nome, lezioni, prezzo, ordine) values
  ('pk1', '1 lezione',                1,  20, 1),
  ('pk2', '4 lezioni',                4,  80, 2),
  ('pk3', '10 lezioni',              10, 180, 3),
  ('pk4', '20 lezioni',              20, 260, 4),
  ('pk5', 'Lezione prova',            1,  15, 5),
  ('pk6', 'Pacchetto welcome',        5, 110, 6),
  ('pk7', 'Pacchetto personalizzato', 0,   0, 7)
on conflict (id) do nothing;
