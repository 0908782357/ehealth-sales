-- TI Störungs-Alert Abonnements
CREATE TABLE IF NOT EXISTS ti_alert_subscriptions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  email           TEXT NOT NULL,
  active          BOOLEAN NOT NULL DEFAULT true,
  last_alerted_at TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id)
);

ALTER TABLE ti_alert_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "ti_alert_own_select" ON ti_alert_subscriptions
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "ti_alert_own_insert" ON ti_alert_subscriptions
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "ti_alert_own_update" ON ti_alert_subscriptions
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "ti_alert_own_delete" ON ti_alert_subscriptions
  FOR DELETE USING (user_id = auth.uid());
