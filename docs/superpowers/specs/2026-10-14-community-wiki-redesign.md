# Community Wiki Redesign — Design Spec

**Datum:** 2026-10-14  
**Status:** Genehmigt  

---

## Ziel

Die bestehende Community-Seite (`admin/knowledge.html`) wird grundlegend überarbeitet:

1. **Infosammlung → Wiki**: Artikel-Tab wird zu einem strukturierten Wiki für das Gesundheitswesen umgebaut — mit Kategorien, Tags, klickbaren Links und einem „Weiterführende Links"-Block.
2. **Rechte-Sync**: Fein­granulares Schreibrecht innerhalb von `community` wird per Tier gesteuert und in `alliance-config.html` konfigurierbar.
3. **Forum & Schwarzes Brett**: Auto-Link-Erkennung, Pin-Funktion für Threads, Schreibschutz für niedrige Tiers.

---

## Benutzerrollen & Schreibrechte

| Rolle | Wiki lesen | Wiki-Artikel erstellen/bearbeiten | Forum-Thread erstellen | Schwarzes Brett posten |
|---|---|---|---|---|
| Kunde (LEI) | ✗ (hidden) | ✗ | ✗ | ✗ |
| Standard-Partner | ✓ | ✗ | ✗ (nur lesen + antworten) | ✗ |
| Premium-Partner | ✓ | ✓ eigene Artikel | ✓ | ✓ |
| Strategisch-Partner | ✓ | ✓ alle Artikel | ✓ + pinnen | ✓ |
| Admin | ✓ | ✓ alle | ✓ + pinnen | ✓ |

**Änderung in `perm.js`:** `community` für `kunde` von `kDef:'read'` auf `kFixed:'hidden'` (Kunden haben keinen Community-Zugang).

**Kein neues `perm_id`** für Sub-Berechtigungen — die Granularität wird über `userRole`/`userTier` direkt im UI gesteuert (Buttons ein-/ausblenden, Hinweistext für gesperrte Aktionen).

---

## Datenbankschema

### Änderungen an `knowledge_articles`

```sql
ALTER TABLE knowledge_articles
  ADD COLUMN IF NOT EXISTS links       jsonb        DEFAULT '[]',
  ADD COLUMN IF NOT EXISTS updated_at  timestamptz  DEFAULT now(),
  ADD COLUMN IF NOT EXISTS updated_by  uuid         REFERENCES auth.users,
  ADD COLUMN IF NOT EXISTS min_tier    text         DEFAULT null;
```

**`links`**: JSONB-Array `[{"label": "Gematik Doku", "url": "https://..."}]`  
**`min_tier`**: `null` = alle Partner sehen den Artikel; `'premium'` = nur Premium+; `'strategisch'` = nur Strategisch+  
**`updated_at`** wird per Trigger oder manuell beim Update gesetzt.

### Änderungen an `forum_threads`

```sql
ALTER TABLE forum_threads
  ADD COLUMN IF NOT EXISTS pinned boolean DEFAULT false;
```

Gepinnte Threads erscheinen immer oben in der Thread-Liste, mit einem Pin-Badge.

---

## Wiki-Tab (Infosammlung → Wiki)

### Layout

```
┌─────────────────────────────────────────────────────────┐
│ [🔍 Suche in der Wiki…]              [+ Neuer Artikel]  │
├──────────────────┬──────────────────────────────────────┤
│ Kategorien       │ Artikel                              │
│ ─────────────    │ ──────────────────────────────────   │
│ • Alle           │ ┌─────────────────────────────────┐  │
│ • TI-Infrastruktur│ │ [TI-Infrastruktur]  [eHBA]      │  │
│ • KIM &          │ │ Titel des Artikels               │  │
│   Kommunikation  │ │ Beschreibungstext, URLs werden   │  │
│ • eHBA & Identität│ │ automatisch verlinkt.            │  │
│ • Konnektor &    │ │                                  │  │
│   Hardware       │ │ Weiterführende Links:            │  │
│ • Abrechnung & KV│ │ → Gematik Doku                  │  │
│ • Datenschutz &  │ │ → KBV Richtlinie                │  │
│   DSGVO          │ │                                  │  │
│ • Produkte &     │ │ Marco A. · 14.10.2026  [✏ Edit] │  │
│   Lösungen       │ └─────────────────────────────────┘  │
│ • Allgemein      │ ...                                  │
└──────────────────┴──────────────────────────────────────┘
```

### Feste Kategorien (im JS definiert)

```javascript
const WIKI_CATEGORIES = [
  'TI-Infrastruktur',
  'KIM & Kommunikation',
  'eHBA & Identität',
  'Konnektor & Hardware',
  'Abrechnung & KV',
  'Datenschutz & DSGVO',
  'Produkte & Lösungen',
  'Allgemein',
];
```

### Artikelkarte

Jede Karte zeigt (von oben nach unten):
1. Kategorie-Badge + Tag-Chips
2. Titel (`font-weight: 700`)
3. Inhalt (Fließtext, URLs automatisch als `<a href>` gerendert via `autoLink(text)`)
4. Block „Weiterführende Links" — nur wenn `links.length > 0`; je Link: `→ Label` als klickbarer Link, `target="_blank" rel="noopener"`
5. Footer-Zeile: Autor-Name · Datum (aus `updated_at` falls vorhanden, sonst `created_at`) · Edit-Button (nur für berechtigte Nutzer sichtbar)

### `autoLink(text)` Funktion

```javascript
function autoLink(text) {
  const escaped = esc(text);
  return escaped.replace(
    /(https?:\/\/[^\s<>"]+)/g,
    '<a href="$1" target="_blank" rel="noopener" style="color:var(--navy)">$1</a>'
  );
}
```

### Zugriffsfilter

Artikel mit `min_tier = 'premium'` werden für Standard-Nutzer ausgeblendet (Client-seitig gefiltert nach `userTier`). Artikel mit `min_tier = 'strategisch'` nur für Strategisch + Admin sichtbar.

---

## Artikel-Editor (Modal)

| Feld | Typ | Details |
|---|---|---|
| Titel | `<input type="text">` | Pflichtfeld |
| Kategorie | `<select>` | Werte aus `WIKI_CATEGORIES` |
| Tags | `<input type="text">` | Komma-getrennt, wird als Array gespeichert (Spalte `tags text[]` — bereits vorhanden oder neu anlegen) |
| Inhalt | `<textarea>` | Hinweistext: „URLs werden automatisch verlinkt" |
| Weiterführende Links | Dynamische Zeilen (Label + URL) | „+ Link hinzufügen"-Button fügt neue Zeile ein; × entfernt |
| Sichtbar ab | `<select>` | Alle / Premium+ / Strategisch |
| Veröffentlicht | `<input type="checkbox">` | Toggle |

**Speichern:** Schreibt `links`-Array als JSONB, setzt `updated_at = now()`, `updated_by = currentUser.id`.

---

## Forum-Verbesserungen

- **Auto-Link** im Thread-Inhalt und in Antworten (gleiche `autoLink()`-Funktion)
- **Pinnen**: Admin und Strategisch sehen einen Pin-Button (📌) im Thread-Header; setzt `pinned = true`; gepinnte Threads erscheinen oben mit Badge „📌 Angepinnt"
- **Schreibschutz für Standard**: Der „+ Neuer Beitrag"-Button wird für Standard-Nutzer ausgeblendet; stattdessen Hinweis: *„Premium-Account erforderlich, um neue Beiträge zu erstellen."*
- **Standard kann antworten** (bestehende Logik bleibt — `reply`-Box ist für alle sichtbaren Thread-Betrachter nutzbar)

---

## Schwarzes Brett — Verbesserungen

- **„+ Eintrag erstellen"**-Button nur für Premium+ / Strategisch / Admin sichtbar
- Standard und Kunden sehen Hinweistext: *„Zum Erstellen von Einträgen ist ein Premium-Account erforderlich."*
- Bestehende Eintragsanzeige bleibt unverändert

---

## Änderungen an `perm.js`

```javascript
// Vorher:
{ id: 'community', kDef:'read', sDef:'read', prDef:'edit', stDef:'edit' },

// Nachher:
{ id: 'community', kFixed:'hidden', sDef:'read', prDef:'edit', stDef:'edit' },
```

---

## Änderungen an `alliance-config.html`

In der Tier-Karte für jeden Tier (Standard, Premium, Strategisch) wird ein **Community-Block** ergänzt, der die konfigurierbaren Schreibrechte anzeigt:

- Wiki-Artikel bearbeiten: `read` / `edit`
- Forum-Thread erstellen: `read` / `edit`
- Schwarzes Brett posten: `read` / `edit`

Diese werden über die bestehende `portal_permissions`-Tabelle gespeichert (kein Schema-Change nötig — die Werte werden unter dem bestehenden `perm_id = 'community'` als Felder `standard`, `premium`, `strategisch` verwaltet, wobei `'read'` = nur lesen, `'edit'` = Schreiben erlaubt).

**Hinweis:** Da Sub-Berechtigungen (wiki/forum/board) in der aktuellen Architektur nicht als separate `perm_id`s abgebildet werden, bleibt `alliance-config.html` für den `community`-Block eine UI-Darstellung des Tier-Niveaus. Die tatsächliche Steuerung liegt in `perm.js` + Tier-Vergleich im UI.

---

## Nicht im Scope

- Versionierung von Wiki-Artikeln (kein History-Trail)
- Dateianhänge / Bilder in Artikeln
- E-Mail-Benachrichtigungen bei neuen Threads
- Öffentlich zugängliche Wiki-Seite (alles bleibt hinter Login)

Diese können in einem späteren Schritt ergänzt werden.

---

## Betroffene Dateien

| Datei | Änderung |
|---|---|
| `admin/knowledge.html` | Wiki-Redesign (Tab, Karten, Modal, Forum-Verbesserungen, Board-Rechte) |
| `admin/perm.js` | `community` für `kunde` → `hidden` |
| `admin/alliance-config.html` | Community-Block in Tier-Karten |
| `admin/sql/migration_community_wiki.sql` | ALTER TABLE knowledge_articles + forum_threads |
