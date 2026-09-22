-- Migration: template_configs column for Feld-Wizard
-- Run in Supabase SQL Editor
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS template_configs jsonb DEFAULT '{}'::jsonb;
