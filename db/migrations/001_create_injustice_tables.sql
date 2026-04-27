BEGIN;


CREATE TABLE IF NOT EXISTS account_profile (
  singleton_key SMALLINT PRIMARY KEY DEFAULT 1 CHECK (singleton_key = 1),
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  display_name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  level INTEGER NOT NULL CHECK (level >= 1),
  gold NUMERIC(14, 2) NOT NULL CHECK (gold >= 0),
  gems INTEGER NOT NULL CHECK (gems >= 0),
  energy INTEGER NOT NULL CHECK (energy >= 0)
);


CREATE TABLE IF NOT EXISTS characters (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  character_class TEXT NOT NULL CHECK (
    character_class IN ('poderoso', 'metaHumano', 'agilidade', 'arcano', 'tecnologico')
  ),
  rarity TEXT NOT NULL CHECK (
    rarity IN ('prata', 'ouro', 'lendario')
  ),
  level INTEGER NOT NULL CHECK (level BETWEEN 1 AND 80),
  threat INTEGER NOT NULL CHECK (threat >= 0),
  attack INTEGER NOT NULL CHECK (attack >= 0),
  health INTEGER NOT NULL CHECK (health >= 0),
  stars INTEGER NOT NULL CHECK (stars BETWEEN 1 AND 14),
  alignment TEXT NOT NULL CHECK (
    alignment IN ('heroi', 'vilao', 'antiHeroi')
  ),
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_characters_name ON characters (name);
CREATE INDEX IF NOT EXISTS idx_characters_updated_at ON characters (updated_at DESC);

COMMIT;
