# Community Wiki Redesign — Implementierungsplan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `admin/knowledge.html` zu einem strukturierten Wiki umbauen, Schreibrechte nach Tier steuern, Forum mit Pin-Funktion und Auto-Link ausstatten, Schwarzes Brett absichern und `alliance-config.html` um einen Community-Block erweitern.

**Architecture:** Vanilla JS + Supabase. Neue DB-Spalten via SQL-Migration. Alle UI-Änderungen in zwei bestehenden HTML-Dateien plus einer kleinen Anpassung in `perm.js`. Kein neuer Routing-Layer, kein Framework.

**Tech Stack:** Supabase JS v2, Vanilla JS (ES6), HTML/CSS (inline), kein Build-Step.

**Spec:** `docs/superpowers/specs/2026-10-14-community-wiki-redesign.md`

## Global Constraints

- Kein Schreiben des Resend-API-Keys in HTML-Dateien.
- Supabase ANON Key darf in HTML stehen (ist schon so, bleibt so).
- Kein `localStorage` für Sitzungstoken — `sessionStorage` bereits so genutzt.
- Alle `esc()`-Aufrufe vor HTML-Ausgabe (XSS-Schutz beibehalten).
- `autoLink()` muss erst `esc()` aufrufen, dann URL-Regex anwenden.
- Keine Rückwärtskompatibilitätshacks — direkt ändern.

---

### Task 1: SQL-Migration

**Files:**
- Create: `admin/sql/migration_community_wiki.sql`

**Interfaces:**
- Produces: Spalten `links jsonb`, `updated_at timestamptz`, `updated_by uuid`, `min_tier text`, `tags text[]` auf `knowledge_articles`; Spalte `pinned boolean` auf `forum_threads`.
- Consumes: nichts aus anderen Tasks.

- [ ] **Step 1: Verzeichnis prüfen und Datei anlegen**

```bash
ls admin/sql/
```

Wenn `admin/sql/` nicht existiert: `mkdir -p admin/sql`.

- [ ] **Step 2: SQL-Datei schreiben**

Datei `admin/sql/migration_community_wiki.sql`:

```sql
-- Community Wiki Redesign Migration
-- Ausführen in Supabase Dashboard → SQL Editor

ALTER TABLE knowledge_articles
  ADD COLUMN IF NOT EXISTS links       jsonb        DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS updated_at  timestamptz  DEFAULT now(),
  ADD COLUMN IF NOT EXISTS updated_by  uuid         REFERENCES auth.users(id),
  ADD COLUMN IF NOT EXISTS min_tier    text         DEFAULT null,
  ADD COLUMN IF NOT EXISTS tags        text[]       DEFAULT '{}';

ALTER TABLE forum_threads
  ADD COLUMN IF NOT EXISTS pinned boolean DEFAULT false;

-- Optional: Trigger für auto-update von updated_at
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
```

- [ ] **Step 3: Manuelle Ausführung durch den Nutzer**

Dieser SQL muss **einmalig** im Supabase Dashboard unter `SQL Editor` ausgeführt werden. Die Datei dient als Dokumentation und kann nicht automatisch deployed werden.

Hinweis in die Datei schreiben (oben):

```sql
-- AUSFÜHRUNG: Supabase Dashboard → SQL Editor → New query → Inhalt einfügen → Run
-- IDEMPOTENT: Alle ALTER TABLE nutzen IF NOT EXISTS, sicher wiederholbar.
```

- [ ] **Step 4: Commit**

```bash
git add admin/sql/migration_community_wiki.sql
git commit -m "feat: SQL-Migration für Community Wiki (links, tags, min_tier, pinned)

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

### Task 2: perm.js — `community` für `kunde` auf `hidden`

**Files:**
- Modify: `admin/perm.js:22`

**Interfaces:**
- Consumes: nichts.
- Produces: `getPagePerm('kunde', null, 'community')` gibt `'hidden'` zurück (führt zum Dashboard-Redirect in `enforcePage`).

- [ ] **Step 1: Zeile 22 in perm.js ändern**

Aktuell (Zeile 22):
```javascript
{ id: 'community',     kDef:'read',     sDef:'read',     prDef:'edit',     stDef:'edit'     },
```

Ersetzen durch:
```javascript
{ id: 'community',     kFixed:'hidden', sDef:'read',     prDef:'edit',     stDef:'edit'     },
```

- [ ] **Step 2: Manuelle Verifikation**

In der Browser-DevConsole auf einer Admin-Seite prüfen:
```javascript
getPagePerm('kunde', null, 'community')   // → 'hidden'
getPagePerm('partner', 'standard', 'community') // → 'read'
getPagePerm('partner', 'premium', 'community')  // → 'edit'
getPagePerm('admin', null, 'community')         // → 'edit'
```

- [ ] **Step 3: Commit**

```bash
git add admin/perm.js
git commit -m "feat: community perm für Kunden auf hidden gesetzt

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

### Task 3: knowledge.html — Wiki CSS, Layout, Artikel-Rendering

**Files:**
- Modify: `admin/knowledge.html` (CSS-Block Zeilen 84–93, HTML Tab-pane Zeilen 290–302, JS-Block Zeilen 476–517)

**Interfaces:**
- Consumes: neue DB-Spalten aus Task 1 (`links`, `tags`, `min_tier`, `updated_at`).
- Produces:
  - `allArticles` enthält alle neuen Felder (wird von Task 4 für Modal benötigt).
  - `canWriteWiki()`, `canPin()` — boolesche Helfer (werden von Task 4 + 5 genutzt).
  - `autoLink(text): string` — escaped HTML mit `<a>`-Tags für URLs.
  - `WIKI_CATEGORIES: string[]` — feste Kategorienliste (wird von Task 4 im Modal genutzt).
  - `wikiCatFilter: string` — aktuell gewählte Kategorie.

- [ ] **Step 1: CSS für Wiki-Layout und Artikelkarten einfügen**

In `admin/knowledge.html` den Abschnitt `/* Infosammlung */` (Zeilen 84–93) **ersetzen** durch:

```css
  /* Wiki */
  .wiki-layout { display: grid; grid-template-columns: 200px 1fr; gap: 24px; align-items: start; }
  @media (max-width: 700px) { .wiki-layout { grid-template-columns: 1fr; } }
  .wiki-sidebar { position: sticky; top: 84px; }
  .wiki-cat { padding: 7px 12px; border-radius: 9px; font-size: 0.83rem; font-weight: 500; cursor: pointer; color: var(--gray-500); transition: all 0.15s; display: flex; align-items: center; justify-content: space-between; gap: 8px; }
  .wiki-cat:hover { background: var(--gray-100); color: var(--navy); }
  .wiki-cat.active { background: #eef0f7; color: var(--navy); font-weight: 700; }
  .wiki-search { display: flex; gap: 10px; align-items: center; margin-bottom: 20px; flex-wrap: wrap; }
  .wiki-search input { flex: 1; min-width: 200px; padding: 9px 14px; border: 1.5px solid var(--gray-200); border-radius: 9px; font-size: 0.875rem; outline: none; font-family: inherit; }
  .wiki-search input:focus { border-color: var(--navy); }
  .wiki-article-card { background: white; border-radius: 14px; border: 1px solid var(--gray-200); padding: 22px 24px; box-shadow: 0 1px 6px rgba(0,0,0,0.04); margin-bottom: 14px; }
  .wiki-article-card:last-child { margin-bottom: 0; }
  .wiki-article-card h3 { font-size: 1rem; font-weight: 700; color: var(--navy); margin-bottom: 8px; }
  .wiki-article-content { font-size: 0.875rem; color: var(--gray-500); line-height: 1.6; margin-bottom: 12px; white-space: pre-wrap; word-break: break-word; }
  .wiki-article-content a { color: var(--navy); }
  .wiki-links-block { border-top: 1px solid var(--gray-100); margin-top: 12px; padding-top: 12px; }
  .wiki-links-label { font-size: 0.68rem; font-weight: 700; color: var(--gray-400); text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 6px; }
  .wiki-link { display: block; font-size: 0.82rem; color: var(--navy); font-weight: 500; padding: 3px 0; text-decoration: none; }
  .wiki-link:hover { text-decoration: underline; }
  .tag-chip { display: inline-block; background: var(--gray-100); color: var(--gray-500); border-radius: 20px; padding: 2px 8px; font-size: 0.7rem; font-weight: 600; margin-right: 4px; margin-bottom: 4px; }
  .article-footer { display: flex; align-items: center; justify-content: space-between; margin-top: 14px; flex-wrap: wrap; gap: 8px; }
  .article-meta { font-size: 0.75rem; color: var(--gray-400); }
  /* Infosammlung legacy (Schwarzes Brett filter-chips) */
  .filter-bar { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 20px; }
  .filter-chip { padding: 5px 14px; border-radius: 20px; border: 1.5px solid var(--gray-200); background: white; font-size: 0.78rem; font-weight: 600; cursor: pointer; color: var(--gray-500); transition: all 0.15s; }
  .filter-chip.active { background: var(--navy); color: white; border-color: var(--navy); }
```

- [ ] **Step 2: Tab-Label von „📚 Infosammlung" auf „📖 Wiki" ändern**

Zeile 285 in `knowledge.html`:
```html
      <button class="tab-btn active" onclick="switchTab('info')">📚 Infosammlung</button>
```
Ersetzen durch:
```html
      <button class="tab-btn active" onclick="switchTab('info')">📖 Wiki</button>
```

- [ ] **Step 3: HTML des Tab-Pane `tab-info` (Zeilen 291–302) ersetzen**

Altes HTML:
```html
    <!-- ===== TAB: INFOSAMMLUNG ===== -->
    <div class="tab-pane active" id="tab-info">
      <div class="section-header">
        <span class="section-title">Artikel & Ressourcen</span>
        <button class="btn btn-primary" id="btn-new-article" onclick="openArticleModal()" style="display:none">+ Neuer Artikel</button>
      </div>
      <div class="filter-bar" id="article-filter-bar">
        <button class="filter-chip active" onclick="filterArticles('')">Alle</button>
      </div>
      <div class="articles-grid" id="articles-grid">
        <div class="empty" style="grid-column:1/-1">Laden…</div>
      </div>
    </div>
```

Ersetzen durch:
```html
    <!-- ===== TAB: WIKI ===== -->
    <div class="tab-pane active" id="tab-info">
      <div class="wiki-search">
        <input type="text" id="wiki-search-input" placeholder="🔍 Wiki durchsuchen …" oninput="filterWiki()">
        <button class="btn btn-primary" id="btn-new-article" onclick="openArticleModal()" style="display:none">+ Neuer Artikel</button>
      </div>
      <div class="wiki-layout">
        <div class="wiki-sidebar" id="wiki-sidebar"></div>
        <div id="articles-list"><div class="empty">Laden…</div></div>
      </div>
    </div>
```

- [ ] **Step 4: JS — Konstanten und Helfer-Funktionen einfügen**

Direkt **nach** Zeile 436 (`let currentArticleId = null, currentChannelId = null, currentThreadId = null;`) einfügen:

```javascript
  const WIKI_CATEGORIES = [
    'TI-Infrastruktur', 'KIM & Kommunikation', 'eHBA & Identität',
    'Konnektor & Hardware', 'Abrechnung & KV', 'Datenschutz & DSGVO',
    'Produkte & Lösungen', 'Allgemein',
  ];
  let wikiCatFilter = '';
  let wikiSearchQuery = '';

  function canWriteWiki() {
    if (userRole === 'admin') return true;
    if (userRole === 'partner') return userTier === 'premium' || userTier === 'strategisch';
    return false;
  }
  function canWriteForum() { return canWriteWiki(); }
  function canWriteBoard() { return canWriteWiki(); }
  function canPin() { return userRole === 'admin' || (userRole === 'partner' && userTier === 'strategisch'); }

  function autoLink(text) {
    const escaped = esc(text);
    return escaped.replace(
      /(https?:\/\/[^\s<>"]+)/g,
      '<a href="$1" target="_blank" rel="noopener">$1</a>'
    );
  }
```

- [ ] **Step 5: `loadArticles()` ersetzen (Zeilen 476–483)**

Altes `loadArticles`:
```javascript
  async function loadArticles() {
    let q = sb.from('knowledge_articles').select('*').order('created_at', { ascending: false });
    if (userRole !== 'admin') q = q.eq('published', true);
    const { data } = await q;
    allArticles = data || [];
    buildCategoryFilter();
    renderArticles(allArticles);
  }
```

Ersetzen durch:
```javascript
  async function loadArticles() {
    let q = sb.from('knowledge_articles')
      .select('id,title,category,content,links,tags,published,created_at,updated_at,updated_by,min_tier,author_id')
      .order('category').order('created_at', { ascending: false });
    if (userRole !== 'admin') q = q.eq('published', true);
    const { data } = await q;
    allArticles = (data || []).filter(a => {
      if (!a.min_tier) return true;
      if (a.min_tier === 'premium') return userTier === 'premium' || userTier === 'strategisch' || userRole === 'admin';
      if (a.min_tier === 'strategisch') return userTier === 'strategisch' || userRole === 'admin';
      return true;
    });
    buildWikiSidebar();
    renderArticles(allArticles);
    if (canWriteWiki()) document.getElementById('btn-new-article').style.display = '';
  }
```

- [ ] **Step 6: `buildCategoryFilter()` und `filterArticles()` ersetzen (Zeilen 485–497)**

Die Funktionen `buildCategoryFilter` und `filterArticles` vollständig ersetzen durch:

```javascript
  function buildWikiSidebar() {
    const sidebar = document.getElementById('wiki-sidebar');
    const allCats = [''].concat(WIKI_CATEGORIES);
    sidebar.innerHTML = allCats.map(cat => {
      const label = cat || 'Alle';
      const count = cat ? allArticles.filter(a => a.category === cat).length : allArticles.length;
      const safecat = cat.replace(/'/g, "\\'");
      return `<div class="wiki-cat${cat === wikiCatFilter ? ' active' : ''}" onclick="setWikiCat('${safecat}')">${esc(label)} <span style="font-size:0.7rem;color:var(--gray-400);">(${count})</span></div>`;
    }).join('');
  }

  function setWikiCat(cat) {
    wikiCatFilter = cat;
    buildWikiSidebar();
    applyWikiFilters();
  }

  function filterWiki() {
    wikiSearchQuery = (document.getElementById('wiki-search-input').value || '').toLowerCase();
    applyWikiFilters();
  }

  function applyWikiFilters() {
    let filtered = allArticles;
    if (wikiCatFilter) filtered = filtered.filter(a => a.category === wikiCatFilter);
    if (wikiSearchQuery) filtered = filtered.filter(a => {
      const hay = [a.title, a.content, a.category].concat(a.tags || []).join(' ').toLowerCase();
      return hay.includes(wikiSearchQuery);
    });
    renderArticles(filtered);
  }
```

- [ ] **Step 7: `renderArticles()` ersetzen (Zeilen 499–517)**

Altes `renderArticles`:
```javascript
  function renderArticles(items) {
    const grid = document.getElementById('articles-grid');
    if (!items.length) { grid.innerHTML = '<div class="empty" style="grid-column:1/-1">Noch keine Artikel vorhanden.</div>'; return; }
    grid.innerHTML = items.map(a => `
      <div class="article-card">
        <h3>${esc(a.title)}</h3>
        <div class="meta-row">
          ${a.published ? '<span class="badge badge-green">Veröffentlicht</span>' : '<span class="badge badge-gray">Entwurf</span>'}
          ${a.category ? `<span>${esc(a.category)}</span>` : ''}
          <span>${fmtDate(a.created_at)}</span>
        </div>
        <p>${a.content ? esc(a.content).substring(0,180) + '…' : '(Kein Inhalt)'}</p>
        ${userRole === 'admin' ? `
        <div class="article-actions">
          <button class="btn btn-sm btn-ghost" onclick="openArticleModal('${a.id}')">Bearbeiten</button>
          <button class="btn btn-sm btn-danger" onclick="deleteArticle('${a.id}','${a.title.replace(/'/g,"\\'")}')">Löschen</button>
        </div>` : ''}
      </div>`).join('');
  }
```

Ersetzen durch:
```javascript
  function renderArticles(items) {
    const list = document.getElementById('articles-list');
    if (!items.length) { list.innerHTML = '<div class="empty">Keine Artikel gefunden.</div>'; return; }
    list.innerHTML = items.map(a => {
      const tags = (a.tags || []).map(t => `<span class="tag-chip">${esc(t)}</span>`).join('');
      const links = a.links || [];
      const linksBlock = links.length ? `
        <div class="wiki-links-block">
          <div class="wiki-links-label">Weiterführende Links</div>
          ${links.map(l => `<a class="wiki-link" href="${esc(l.url)}" target="_blank" rel="noopener">→ ${esc(l.label || l.url)}</a>`).join('')}
        </div>` : '';
      const date = a.updated_at || a.created_at;
      const dateStr = date ? new Date(date).toLocaleDateString('de-DE') : '';
      const pubBadge = !a.published ? '<span class="badge badge-gray" style="margin-right:6px">Entwurf</span>' : '';
      const tierBadge = a.min_tier ? `<span class="badge" style="background:#ede9fe;color:#6d28d9;margin-right:6px">${esc(a.min_tier)}</span>` : '';
      const catBadge = a.category ? `<span class="badge badge-gray">${esc(a.category)}</span>` : '';
      const canEdit = canWriteWiki() && (userRole === 'admin' || userTier === 'strategisch' || a.author_id === currentUser?.id);
      const safeTitle = (a.title || '').replace(/'/g, "\\'");
      return `<div class="wiki-article-card">
        <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px;margin-bottom:8px;">
          <h3>${esc(a.title)}</h3>
          <div style="display:flex;align-items:center;gap:6px;flex-shrink:0;">${pubBadge}${tierBadge}${catBadge}</div>
        </div>
        ${tags ? `<div style="margin-bottom:10px;">${tags}</div>` : ''}
        <div class="wiki-article-content">${autoLink(a.content || '')}</div>
        ${linksBlock}
        <div class="article-footer">
          <span class="article-meta">${dateStr ? 'Geändert: ' + dateStr : ''}</span>
          <div style="display:flex;gap:6px;">
            ${canEdit ? `<button class="btn btn-sm btn-ghost" onclick="openArticleModal('${a.id}')">✏ Bearbeiten</button>` : ''}
            ${userRole === 'admin' ? `<button class="btn btn-sm btn-danger" onclick="deleteArticle('${a.id}','${safeTitle}')">Löschen</button>` : ''}
          </div>
        </div>
      </div>`;
    }).join('');
  }
```

- [ ] **Step 8: Commit**

```bash
git add admin/knowledge.html
git commit -m "feat: Wiki-Layout, Kategorien-Sidebar, autoLink, Tier-Filter in knowledge.html

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

### Task 4: knowledge.html — Artikel-Editor Modal (Tags, Links, min_tier)

**Files:**
- Modify: `admin/knowledge.html` (Modal HTML Zeilen 372–385, JS Zeilen 519–549)

**Interfaces:**
- Consumes: `WIKI_CATEGORIES` (aus Task 3), `allArticles` mit neuen Feldern (aus Task 3).
- Produces:
  - `openArticleModal(id?)` — öffnet Modal mit neuen Feldern vorausgefüllt.
  - `saveArticle()` — speichert `links`, `tags`, `min_tier`, `updated_by`.
  - `addLinkRow(label, url)` — fügt eine Link-Zeile im Modal hinzu.
  - `buildLinksFromModal()` — liest alle Link-Zeilen aus.

- [ ] **Step 1: Modal-HTML ersetzen (Zeilen 372–385)**

Altes Modal-HTML:
```html
<!-- Modal: Artikel -->
<div class="modal-bg" id="article-modal" onclick="if(event.target===this)closeArticleModal()">
  <div class="modal">
    <h2 id="article-modal-title">Neuer Artikel</h2>
    <div id="article-msg" class="msg"></div>
    <div class="form-group"><label>Titel *</label><input type="text" id="f-title" placeholder="Artikeltitel"></div>
    <div class="form-group"><label>Kategorie</label><input type="text" id="f-category" placeholder="z.B. TI, Security, Allgemein"></div>
    <div class="form-group"><label>Inhalt</label><textarea id="f-content" placeholder="Artikeltext…"></textarea></div>
    <label class="toggle-row"><input type="checkbox" id="f-art-published"> Veröffentlicht</label>
    <div class="modal-actions">
      <button class="btn btn-ghost" onclick="closeArticleModal()">Abbrechen</button>
      <button class="btn btn-primary" onclick="saveArticle()">Speichern</button>
    </div>
  </div>
</div>
```

Ersetzen durch:
```html
<!-- Modal: Artikel -->
<div class="modal-bg" id="article-modal" onclick="if(event.target===this)closeArticleModal()">
  <div class="modal">
    <h2 id="article-modal-title">Neuer Artikel</h2>
    <div id="article-msg" class="msg"></div>
    <div class="form-group"><label>Titel *</label><input type="text" id="f-title" placeholder="Artikeltitel"></div>
    <div class="form-group">
      <label>Kategorie</label>
      <select id="f-category">
        <option value="">– keine –</option>
      </select>
    </div>
    <div class="form-group">
      <label>Tags <span style="font-weight:400;text-transform:none;">(kommagetrennt)</span></label>
      <input type="text" id="f-tags" placeholder="z.B. eHBA, KIM, Konnektor">
    </div>
    <div class="form-group">
      <label>Inhalt <span style="font-weight:400;text-transform:none;">(URLs werden automatisch verlinkt)</span></label>
      <textarea id="f-content" placeholder="Artikeltext…"></textarea>
    </div>
    <div class="form-group">
      <label>Weiterführende Links</label>
      <div id="links-container"></div>
      <button type="button" class="btn btn-ghost btn-sm" style="margin-top:6px" onclick="addLinkRow()">+ Link hinzufügen</button>
    </div>
    <div class="form-group">
      <label>Sichtbar für</label>
      <select id="f-min-tier">
        <option value="">Alle Partner</option>
        <option value="premium">Premium+</option>
        <option value="strategisch">Nur Strategisch</option>
      </select>
    </div>
    <label class="toggle-row"><input type="checkbox" id="f-art-published"> Veröffentlicht</label>
    <div class="modal-actions">
      <button class="btn btn-ghost" onclick="closeArticleModal()">Abbrechen</button>
      <button class="btn btn-primary" onclick="saveArticle()">Speichern</button>
    </div>
  </div>
</div>
```

- [ ] **Step 2: Kategorie-Select im Modal mit WIKI_CATEGORIES befüllen**

In der `init()`-Funktion (Zeile 459, nach `loadArticles(); loadChannels(); loadBoard();`) folgendes einfügen:

```javascript
    // Kategorie-Select im Artikel-Modal befüllen
    const catSel = document.getElementById('f-category');
    if (catSel) {
      WIKI_CATEGORIES.forEach(c => {
        const opt = document.createElement('option');
        opt.value = c; opt.textContent = c;
        catSel.appendChild(opt);
      });
    }
```

- [ ] **Step 3: Hilfsfunktionen `addLinkRow` und `buildLinksFromModal` hinzufügen**

Direkt **vor** `openArticleModal` (Zeile 519) einfügen:

```javascript
  function addLinkRow(label, url) {
    const container = document.getElementById('links-container');
    const div = document.createElement('div');
    div.className = 'link-row';
    div.style.cssText = 'display:flex;gap:6px;margin-bottom:6px;align-items:center;';
    div.innerHTML = `
      <input class="link-label" type="text" placeholder="Bezeichnung" value="${esc(label||'')}"
        style="flex:1;padding:7px 10px;border:1.5px solid var(--gray-200);border-radius:9px;font-size:0.83rem;outline:none;font-family:inherit;">
      <input class="link-url" type="url" placeholder="https://…" value="${esc(url||'')}"
        style="flex:2;padding:7px 10px;border:1.5px solid var(--gray-200);border-radius:9px;font-size:0.83rem;outline:none;font-family:inherit;">
      <button type="button" onclick="this.closest('.link-row').remove()"
        style="padding:4px 8px;border:none;background:var(--gray-100);border-radius:6px;cursor:pointer;font-size:1rem;color:var(--red);line-height:1;">×</button>`;
    container.appendChild(div);
  }

  function buildLinksFromModal() {
    return Array.from(document.querySelectorAll('.link-row')).map(row => ({
      label: row.querySelector('.link-label').value.trim(),
      url:   row.querySelector('.link-url').value.trim(),
    })).filter(l => l.url);
  }
```

- [ ] **Step 4: `openArticleModal()` ersetzen (Zeilen 519–535)**

Altes `openArticleModal`:
```javascript
  function openArticleModal(id) {
    currentArticleId = id || null;
    document.getElementById('article-modal-title').textContent = id ? 'Artikel bearbeiten' : 'Neuer Artikel';
    document.getElementById('article-msg').className = 'msg';
    if (id) {
      const a = allArticles.find(x => x.id === id);
      if (!a) return;
      document.getElementById('f-title').value = a.title || '';
      document.getElementById('f-category').value = a.category || '';
      document.getElementById('f-content').value = a.content || '';
      document.getElementById('f-art-published').checked = !!a.published;
    } else {
      ['f-title','f-category','f-content'].forEach(i => document.getElementById(i).value = '');
      document.getElementById('f-art-published').checked = false;
    }
    document.getElementById('article-modal').classList.add('open');
  }
```

Ersetzen durch:
```javascript
  function openArticleModal(id) {
    currentArticleId = id || null;
    document.getElementById('article-modal-title').textContent = id ? 'Artikel bearbeiten' : 'Neuer Artikel';
    document.getElementById('article-msg').className = 'msg';
    document.getElementById('links-container').innerHTML = '';
    if (id) {
      const a = allArticles.find(x => x.id === id);
      if (!a) return;
      document.getElementById('f-title').value = a.title || '';
      document.getElementById('f-category').value = a.category || '';
      document.getElementById('f-tags').value = (a.tags || []).join(', ');
      document.getElementById('f-content').value = a.content || '';
      document.getElementById('f-min-tier').value = a.min_tier || '';
      document.getElementById('f-art-published').checked = !!a.published;
      (a.links || []).forEach(l => addLinkRow(l.label, l.url));
    } else {
      ['f-title', 'f-tags', 'f-content'].forEach(i => document.getElementById(i).value = '');
      document.getElementById('f-category').value = '';
      document.getElementById('f-min-tier').value = '';
      document.getElementById('f-art-published').checked = false;
    }
    document.getElementById('article-modal').classList.add('open');
  }
```

- [ ] **Step 5: `saveArticle()` ersetzen (Zeilen 538–549)**

Altes `saveArticle`:
```javascript
  async function saveArticle() {
    const title = document.getElementById('f-title').value.trim();
    if (!title) { showMsg('article-msg','Bitte Titel eingeben.','error'); return; }
    const payload = { title, category: document.getElementById('f-category').value.trim() || null, content: document.getElementById('f-content').value.trim() || null, published: document.getElementById('f-art-published').checked, updated_at: new Date().toISOString() };
    if (!currentArticleId) payload.author_id = currentUser.id;
    let error;
    if (currentArticleId) ({ error } = await sb.from('knowledge_articles').update(payload).eq('id', currentArticleId));
    else ({ error } = await sb.from('knowledge_articles').insert(payload));
    if (error) { showMsg('article-msg', error.message, 'error'); return; }
    showMsg('article-msg','Gespeichert!','success');
    setTimeout(() => { closeArticleModal(); loadArticles(); }, 700);
  }
```

Ersetzen durch:
```javascript
  async function saveArticle() {
    const title = document.getElementById('f-title').value.trim();
    if (!title) { showMsg('article-msg','Bitte Titel eingeben.','error'); return; }
    const tags = document.getElementById('f-tags').value.split(',').map(t => t.trim()).filter(Boolean);
    const payload = {
      title,
      category:   document.getElementById('f-category').value || null,
      content:    document.getElementById('f-content').value.trim() || null,
      links:      buildLinksFromModal(),
      tags,
      min_tier:   document.getElementById('f-min-tier').value || null,
      published:  document.getElementById('f-art-published').checked,
      updated_at: new Date().toISOString(),
      updated_by: currentUser.id,
    };
    if (!currentArticleId) payload.author_id = currentUser.id;
    let error;
    if (currentArticleId) ({ error } = await sb.from('knowledge_articles').update(payload).eq('id', currentArticleId));
    else ({ error } = await sb.from('knowledge_articles').insert(payload));
    if (error) { showMsg('article-msg', error.message, 'error'); return; }
    showMsg('article-msg','Gespeichert!','success');
    setTimeout(() => { closeArticleModal(); loadArticles(); }, 700);
  }
```

- [ ] **Step 6: Commit**

```bash
git add admin/knowledge.html
git commit -m "feat: Artikel-Editor mit Tags, Links-Block, min_tier und Kategorie-Select

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

### Task 5: knowledge.html — Forum Pin + Schreibschutz + Schwarzes Brett Schreibschutz

**Files:**
- Modify: `admin/knowledge.html` (HTML Zeilen 308–348 + 352–367, JS Zeilen 557–681, 719–724)

**Interfaces:**
- Consumes: `canWriteForum()`, `canWriteBoard()`, `canPin()` (aus Task 3); neue DB-Spalte `pinned` auf `forum_threads` (aus Task 1).
- Produces: Forum-Threads mit Pin-Badge; Pin-Button im Thread-Detail; Schreibschutz-Hinweis für Standard.

- [ ] **Step 1: Forum-Channels-View — "+ Neuer Beitrag" für Standard ausblenden**

Im HTML (Zeile 310–312) den Button mit Schreibschutz versehen. Ersetzen:
```html
        <div class="section-header">
          <span class="section-title">Themenkanäle</span>
          <button class="btn btn-primary" onclick="openThreadModal()">+ Neuer Beitrag</button>
        </div>
```
Durch:
```html
        <div class="section-header">
          <span class="section-title">Themenkanäle</span>
          <span id="forum-write-hint" style="display:none;font-size:0.78rem;color:var(--gray-400);">Premium-Account erforderlich, um neue Beiträge zu erstellen.</span>
          <button class="btn btn-primary" id="btn-new-thread-channels" onclick="openThreadModal()">+ Neuer Beitrag</button>
        </div>
```

Im HTML (Zeile 322–324) für Thread-List-View dasselbe:
```html
          <span id="forum-write-hint2" style="display:none;font-size:0.78rem;color:var(--gray-400);">Premium-Account erforderlich.</span>
          <button class="btn btn-primary" id="btn-new-thread-threads" onclick="openThreadModal()">+ Neuer Beitrag</button>
```

(Aktuelles HTML Zeile 323 `<button class="btn btn-primary" onclick="openThreadModal()">+ Neuer Beitrag</button>` durch die zwei Zeilen oben ersetzen.)

- [ ] **Step 2: Schwarzes Brett — "+ Eintrag erstellen" für Standard ausblenden**

Im HTML (Zeile 354) ersetzen:
```html
        <button class="btn btn-primary" onclick="openBoardModal()">+ Eintrag erstellen</button>
```
Durch:
```html
          <span id="board-write-hint" style="display:none;font-size:0.78rem;color:var(--gray-400);">Zum Erstellen von Einträgen ist ein Premium-Account erforderlich.</span>
          <button class="btn btn-primary" id="btn-board-create" onclick="openBoardModal()">+ Eintrag erstellen</button>
```

- [ ] **Step 3: Pin-Badge CSS einfügen**

Im `<style>`-Block nach `.thread-replies { ... }` (Zeile ~109) einfügen:

```css
  .pin-badge { display: inline-flex; align-items: center; gap: 4px; font-size: 0.7rem; font-weight: 700; background: #fffbeb; color: #92400e; border-radius: 20px; padding: 2px 8px; }
  .btn-pin { padding: 4px 10px; font-size: 0.75rem; background: #fffbeb; color: #92400e; border: 1px solid #fde68a; border-radius: 7px; cursor: pointer; font-family: inherit; }
  .btn-pin:hover { background: #fef3c7; }
```

- [ ] **Step 4: `init()` — Schreibschutz-Buttons nach Tier ein/ausblenden**

In `init()` nach `pagePerm = enforcePage(...)` (Zeile 448) folgendes einfügen:

```javascript
    // Schreibschutz: Forum + Schwarzes Brett
    if (!canWriteForum()) {
      ['btn-new-thread-channels','btn-new-thread-threads'].forEach(id => {
        const el = document.getElementById(id); if (el) el.style.display = 'none';
      });
      ['forum-write-hint','forum-write-hint2'].forEach(id => {
        const el = document.getElementById(id); if (el) el.style.display = '';
      });
    }
    if (!canWriteBoard()) {
      const btn = document.getElementById('btn-board-create'); if (btn) btn.style.display = 'none';
      const hint = document.getElementById('board-write-hint'); if (hint) hint.style.display = '';
    }
```

- [ ] **Step 5: `showThreads()` — gepinnte Threads zuerst, mit Badge**

Die Zeile im `showThreads`-Query (Zeile 596–610) anpassen. Den Query-Teil:
```javascript
    const { data } = await sb.from('forum_threads')
      .select('*, forum_posts(count)')
      .eq('channel_id', currentChannelId)
      .order('created_at', { ascending: false });
```
Ersetzen durch:
```javascript
    const { data } = await sb.from('forum_threads')
      .select('*, forum_posts(count)')
      .eq('channel_id', currentChannelId)
      .order('pinned', { ascending: false })
      .order('created_at', { ascending: false });
```

Und die Thread-Row-Karte (Zeilen 601–610) ersetzen:
```javascript
    list.innerHTML = data.map(t => {
      const replies = t.forum_posts?.[0]?.count || 0;
      const pinBadge = t.pinned ? '<span class="pin-badge">📌 Angepinnt</span>' : '';
      return `<div class="thread-row" onclick="showThread('${t.id}')">
        <div class="thread-row-body">
          <h4>${esc(t.titel)}${t.pinned ? ' 📌' : ''}</h4>
          <div class="meta-row">${pinBadge}${pinBadge ? ' ' : ''}${esc(t.autor_name || '–')} · ${fmtDate(t.created_at)}</div>
        </div>
        <div class="thread-replies">${replies} Antworten</div>
      </div>`;
    }).join('');
```

- [ ] **Step 6: `loadThread()` — Pin-Button im Thread-Header + autoLink**

Im Thread-Header (Zeile 625–628) nach dem `document.getElementById('thread-detail-meta')` Aufruf:
```javascript
    document.getElementById('thread-detail-meta').textContent = (t.autor_name || '–') + ' · ' + fmtDate(t.created_at);
    document.getElementById('thread-detail-content').textContent = t.inhalt || '';
```
Ersetzen durch:
```javascript
    const metaEl = document.getElementById('thread-detail-meta');
    const pinBtn = canPin()
      ? `<button class="btn-pin" onclick="toggleThreadPin('${t.id}',${!t.pinned})">${t.pinned ? '📌 Anpinnen aufheben' : '📌 Anpinnen'}</button>`
      : '';
    metaEl.innerHTML = `<span>${esc(t.autor_name || '–')} · ${fmtDate(t.created_at)}</span>${t.pinned ? ' <span class="pin-badge">📌 Angepinnt</span>' : ''} ${pinBtn}`;
    document.getElementById('thread-detail-content').innerHTML = autoLink(t.inhalt || '');
```

- [ ] **Step 7: `toggleThreadPin()` Funktion einfügen**

Direkt **vor** `openThreadModal` (Zeile 660) einfügen:

```javascript
  async function toggleThreadPin(threadId, pinValue) {
    const { error } = await sb.from('forum_threads').update({ pinned: pinValue }).eq('id', threadId);
    if (error) { alert('Fehler: ' + error.message); return; }
    loadThread();
  }
```

- [ ] **Step 8: Post-Inhalt autoLink in `loadThread()`**

In `loadThread()` (Zeile 632–640) die Post-Karte anpassen — `esc(p.inhalt)` ersetzen durch `autoLink(p.inhalt || '')`:

```javascript
    postList.innerHTML = posts.map(p => `
      <div class="post-card">
        <div class="meta-row">
          <span class="post-author">${esc(p.autor_name || '–')}</span>
          <span>${fmtDate(p.created_at)}</span>
          ${p.created_by === currentUser.id || userRole === 'admin' ? `<button class="btn btn-sm btn-danger" style="margin-left:auto" onclick="deletePost('${p.id}')">Löschen</button>` : ''}
        </div>
        <div class="post-content">${autoLink(p.inhalt || '')}</div>
      </div>`).join('');
```

- [ ] **Step 9: Commit**

```bash
git add admin/knowledge.html
git commit -m "feat: Forum Pin-Funktion, autoLink, Schreibschutz Standard in Forum+Brett

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

### Task 6: alliance-config.html — Community-Berechtigungsblock

**Files:**
- Modify: `admin/alliance-config.html` (HTML Zeile 332 vor `</main>`, JS nach Zeile 580)

**Interfaces:**
- Consumes: `portal_permissions`-Tabelle (Supabase) mit Spalten `perm_id`, `standard`, `premium`, `strategisch`.
- Produces: Sichtbare Tabelle pro Tier mit aktuellem Community-Level (read/edit); Speichern-Button schreibt zurück.

- [ ] **Step 1: CSS für Community-Block einfügen**

Im `<style>`-Block (vor dem schließenden `</style>`) hinzufügen:

```css
  .community-perm-block { margin-top: 32px; }
  .perm-row { display: flex; align-items: center; gap: 16px; padding: 12px 0; border-bottom: 1px solid var(--gray-100); }
  .perm-row:last-child { border-bottom: none; }
  .perm-tier-label { font-weight: 700; color: var(--navy); font-size: 0.875rem; min-width: 120px; }
  .perm-select { padding: 7px 12px; border: 1.5px solid var(--gray-200); border-radius: 9px; font-size: 0.83rem; font-family: inherit; outline: none; cursor: pointer; }
  .perm-select:focus { border-color: var(--navy); }
  .perm-hint { font-size: 0.75rem; color: var(--gray-400); }
```

- [ ] **Step 2: HTML-Block vor `</main>` (Zeile 332) einfügen**

Direkt **vor** `</main>` (Zeile 332) einfügen:

```html
    <!-- ========== Community-Berechtigungen ========== -->
    <div class="section-block community-perm-block">
      <p class="section-label">Portal-Berechtigungen</p>
      <h2>Community-Zugang je Stufe</h2>
      <p class="page-sub" style="margin-bottom:16px;">Legt fest, ob Partner einer Stufe die Community lesen (read) oder auch schreiben können (edit). Standard hat Lesezugriff, Premium und Strategisch haben Schreibzugriff.</p>
      <div id="community-perm-rows">
        <p style="color:var(--gray-400);">Lade…</p>
      </div>
      <div style="margin-top:16px;display:flex;align-items:center;gap:12px;">
        <button class="btn btn-primary btn-sm" onclick="saveCommunityPerms()">Speichern</button>
        <span id="community-perm-msg" style="font-size:0.82rem;color:#16a34a;display:none;">Gespeichert ✓</span>
      </div>
    </div>
```

- [ ] **Step 3: JS — `communityPerms` Variable und `loadCommunityPerms()` hinzufügen**

Im Script-Block (nach `let featuresData = [];`, ca. Zeile 383) einfügen:

```javascript
let communityPerms = { standard: 'read', premium: 'edit', strategisch: 'edit' };
```

Nach `renderFeatures()` (ca. Zeile 502) die folgende Funktion einfügen:

```javascript
async function loadCommunityPerms() {
  const { data } = await sb.from('portal_permissions')
    .select('standard, premium, strategisch')
    .eq('perm_id', 'community')
    .maybeSingle();
  if (data) {
    communityPerms = {
      standard:    data.standard    || 'read',
      premium:     data.premium     || 'edit',
      strategisch: data.strategisch || 'edit',
    };
  }
  renderCommunityPerms();
}

function renderCommunityPerms() {
  const TIERS = [
    { key: 'standard',    label: 'Standard' },
    { key: 'premium',     label: 'Premium' },
    { key: 'strategisch', label: 'Strategisch' },
  ];
  const container = document.getElementById('community-perm-rows');
  container.innerHTML = TIERS.map(tier => `
    <div class="perm-row">
      <span class="perm-tier-label">${tier.label}</span>
      <select class="perm-select" id="perm-community-${tier.key}">
        <option value="read" ${communityPerms[tier.key] === 'read' ? 'selected' : ''}>Lesen (read)</option>
        <option value="edit" ${communityPerms[tier.key] === 'edit' ? 'selected' : ''}>Schreiben (edit)</option>
      </select>
      <span class="perm-hint">${tier.key === 'standard' ? 'Standard: Lesen + Forum-Antworten, kein Erstellen' : 'Standard: Artikel erstellen, Forum-Threads, Schwarzes Brett'}</span>
    </div>`).join('');
}

async function saveCommunityPerms() {
  const payload = {
    standard:    document.getElementById('perm-community-standard').value,
    premium:     document.getElementById('perm-community-premium').value,
    strategisch: document.getElementById('perm-community-strategisch').value,
  };
  const { error } = await sb.from('portal_permissions')
    .upsert({ perm_id: 'community', ...payload }, { onConflict: 'perm_id' });
  const msgEl = document.getElementById('community-perm-msg');
  if (error) {
    msgEl.textContent = 'Fehler: ' + error.message;
    msgEl.style.color = '#ef4444';
  } else {
    communityPerms = payload;
    msgEl.textContent = 'Gespeichert ✓';
    msgEl.style.color = '#16a34a';
  }
  msgEl.style.display = '';
  setTimeout(() => { msgEl.style.display = 'none'; }, 2500);
}
```

- [ ] **Step 4: `loadCommunityPerms()` in `init()` aufrufen**

In der `init()`-Funktion (ca. Zeile 355–376) nach `loadTiers(); loadFeatures();` einfügen:

```javascript
  loadCommunityPerms();
```

- [ ] **Step 5: Commit**

```bash
git add admin/alliance-config.html
git commit -m "feat: Community-Berechtigungsblock in Alliance-Config

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Self-Review

### Spec-Abdeckung

| Spec-Anforderung | Task |
|---|---|
| `knowledge_articles`: links, updated_at, updated_by, min_tier, tags | Task 1 |
| `forum_threads`: pinned | Task 1 |
| `perm.js` community kunde → hidden | Task 2 |
| Wiki-Layout (zwei Spalten: Sidebar + Liste) | Task 3 |
| Feste WIKI_CATEGORIES | Task 3 |
| autoLink() | Task 3 |
| Tier-Filter (min_tier) | Task 3 |
| Artikelkarte mit Tags, Links-Block, autoLink, Footer | Task 3 |
| canWriteWiki/canWriteForum/canWriteBoard/canPin() | Task 3 |
| Artikel-Editor: Kategorie-Select mit WIKI_CATEGORIES | Task 4 |
| Artikel-Editor: Tags-Feld | Task 4 |
| Artikel-Editor: Links (Label+URL dynamisch) | Task 4 |
| Artikel-Editor: min_tier-Select | Task 4 |
| saveArticle speichert alle neuen Felder | Task 4 |
| Forum: autoLink in Posts | Task 5 |
| Forum: "+ Neuer Beitrag" ausgeblendet für Standard | Task 5 |
| Forum: Pin-Button (Admin + Strategisch) | Task 5 |
| Forum: gepinnte Threads oben mit Badge | Task 5 |
| Schwarzes Brett: "+ Eintrag" ausgeblendet für Standard | Task 5 |
| alliance-config: Community-Block mit read/edit per Tier | Task 6 |

### Interface-Konsistenz

- `WIKI_CATEGORIES` definiert in Task 3, verwendet in Task 4 ✓
- `canWriteWiki()` / `canPin()` definiert in Task 3, verwendet in Tasks 3 + 5 ✓
- `autoLink()` definiert in Task 3, verwendet in Task 3 (renderArticles) + Task 5 (loadThread) ✓
- `allArticles` mit neuen Feldern aus Task 3, vorausgesetzt in Task 4 (openArticleModal) ✓
- `pinned`-Spalte aus Task 1 SQL, genutzt in Task 5 (showThreads, loadThread) ✓
- Task 1 (SQL) muss **vor dem ersten Produktionseinsatz** der anderen Tasks ausgeführt sein — bis dahin degradieren die neuen Felder auf `null`/`[]`, was in den Render-Funktionen jeweils geprüft wird ✓

### Placeholder-Scan

Keine TBDs, keine Lücken gefunden.
