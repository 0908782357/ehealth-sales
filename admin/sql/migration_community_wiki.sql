-- Community Wiki Redesign Migration
-- AUSFÜHRUNG: Supabase Dashboard → SQL Editor → New query → Inhalt einfügen → Run
-- IDEMPOTENT: Alle ALTER TABLE nutzen IF NOT EXISTS, sicher wiederholbar.

ALTER TABLE knowledge_articles
  ADD COLUMN IF NOT EXISTS links       jsonb        DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS updated_at  timestamptz  DEFAULT now(),
  ADD COLUMN IF NOT EXISTS updated_by  uuid         REFERENCES auth.users(id),
  ADD COLUMN IF NOT EXISTS min_tier    text         DEFAULT null,
  ADD COLUMN IF NOT EXISTS tags        text[]       DEFAULT '{}';

ALTER TABLE forum_threads
  ADD COLUMN IF NOT EXISTS pinned boolean DEFAULT false;

-- Trigger für auto-update von updated_at
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_knowledge_articles_updated_at ON knowledge_articles;
CREATE TRIGGER trg_knowledge_articles_updated_at
  BEFORE UPDATE ON knowledge_articles
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
