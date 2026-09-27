// Alliance Portal — Seitenberechtigungen
// <script src="perm.js"> vor dem Seiten-Script einbinden.
//
// API:
//   initPerms(sb)                            → lädt Berechtigungen von Supabase (einmal pro Session)
//   getPagePerm(role, tier, permId)          → 'hidden'|'read'|'edit'
//   permAtLeast(role, tier, permId, minLvl)  → boolean
//   enforcePage(role, tier, permId)          → redirect bei 'hidden', gibt Perm zurück
//   applyNavPerms(role, tier)                → versteckt [data-perm]-Links ohne Zugriff
(function () {
  var CTX_KEY  = '_perm_ctx';
  var DATA_KEY = '_perm_data';  // sessionStorage: von Supabase geladene Berechtigungen
  var LEVELS   = { hidden: 0, read: 1, edit: 2 };

  // Fallback-Defaults (solange DB noch nicht geladen) — muss mit PERM_DEFS in users.html synchron bleiben
  var DEFS = [
    { id: 'dashboard',     kFixed:'read',   sFixed:'read',   prFixed:'read',   stFixed:'read'   },
    { id: 'profil',        kFixed:'edit',   sFixed:'edit',   prFixed:'edit',   stFixed:'edit'   },
    { id: 'events',        kDef:'read',     sDef:'read',     prDef:'read',     stDef:'edit'     },
    { id: 'shop',          kDef:'read',     sDef:'read',     prDef:'read',     stDef:'edit'     },
    { id: 'produkte',      kFixed:'hidden', sFixed:'hidden', prDef:'read',     stDef:'edit'     },
    { id: 'community',     kDef:'read',     sDef:'read',     prDef:'edit',     stDef:'edit'     },
    { id: 'tickets',       kDef:'edit',     sDef:'edit',     prDef:'edit',     stDef:'edit'     },
    { id: 'anfragen',      kFixed:'hidden', sDef:'read',     prDef:'edit',     stDef:'edit'     },
    { id: 'support',       kFixed:'hidden', sFixed:'hidden', prFixed:'hidden', stFixed:'hidden' },
    { id: 'tirechner',     kFixed:'hidden', sDef:'read',     prDef:'read',     stDef:'edit'     },
    { id: 'produktfinder', kFixed:'hidden', sDef:'read',     prDef:'edit',     stDef:'edit'     },
    { id: 'kunden_mgmt',   kFixed:'hidden', sFixed:'hidden', prFixed:'hidden', stFixed:'hidden' },
    { id: 'verwaltung',    kFixed:'hidden', sFixed:'hidden', prFixed:'hidden', stFixed:'hidden' },
  ];

  // Gibt gecachte DB-Berechtigungen zurück (oder {} falls noch nicht geladen)
  function getStored() {
    try { return JSON.parse(sessionStorage.getItem(DATA_KEY) || '{}'); } catch { return {}; }
  }

  // Lädt Berechtigungen einmalig von Supabase und cached in sessionStorage
  window.initPerms = async function (sb) {
    if (sessionStorage.getItem(DATA_KEY) !== null) return; // bereits gecached
    try {
      var result = await sb.from('portal_permissions')
        .select('perm_id, kunde, standard, premium, strategisch');
      var data = result.data;
      if (!data || data.length === 0) {
        sessionStorage.setItem(DATA_KEY, '{}');
        return;
      }
      var stored = {};
      data.forEach(function (row) {
        stored[row.perm_id] = {
          kunde:        row.kunde,
          standard:     row.standard,
          premium:      row.premium,
          strategisch:  row.strategisch,
        };
      });
      sessionStorage.setItem(DATA_KEY, JSON.stringify(stored));
    } catch (e) {
      sessionStorage.setItem(DATA_KEY, '{}'); // Fehlerfall: leeres Objekt → Fallback auf DEFS
    }
  };

  window.getPagePerm = function (role, tier, permId) {
    if (role === 'admin') return 'edit';
    var def = DEFS.find(function (p) { return p.id === permId; });
    if (!def) return 'read';
    var stored = getStored();
    var fixedKey, defKey, roleKey;
    if (role === 'kunde') {
      fixedKey = 'kFixed'; defKey = 'kDef'; roleKey = 'kunde';
    } else {
      var t = tier || 'standard';
      if      (t === 'strategisch') { fixedKey = 'stFixed'; defKey = 'stDef'; roleKey = 'strategisch'; }
      else if (t === 'premium')     { fixedKey = 'prFixed'; defKey = 'prDef'; roleKey = 'premium'; }
      else                          { fixedKey = 'sFixed';  defKey = 'sDef';  roleKey = 'standard'; }
    }
    if (def[fixedKey] !== undefined) return def[fixedKey];
    var v = stored[permId] && stored[permId][roleKey];
    return v !== undefined ? v : (def[defKey] || 'hidden');
  };

  window.permAtLeast = function (role, tier, permId, minLevel) {
    return LEVELS[window.getPagePerm(role, tier, permId)] >= LEVELS[minLevel];
  };

  // Versteckt alle [data-perm]-Nav-Links ohne Zugriff
  window.applyNavPerms = function (role, tier) {
    document.querySelectorAll('[data-perm]').forEach(function (el) {
      var p = el.getAttribute('data-perm');
      if (window.getPagePerm(role, tier, p) === 'hidden') {
        el.style.display = 'none';
        var parent = el.parentElement;
        if (parent && parent.classList.contains('nav-subgroup')) {
          var visible = parent.querySelectorAll('a[data-perm]:not([style*="none"]), a.nav-link:not([data-perm]):not([style*="none"])');
          if (visible.length === 0) parent.style.display = 'none';
        }
      }
    });
  };

  // Leitet bei 'hidden' um; speichert Kontext für auto-apply
  window.enforcePage = function (role, tier, permId) {
    var perm = window.getPagePerm(role, tier, permId);
    if (perm === 'hidden') { window.location.href = 'dashboard.html'; return perm; }
    try { sessionStorage.setItem(CTX_KEY, JSON.stringify({ role: role, tier: tier || null })); } catch (e) {}
    window.applyNavPerms(role, tier);
    return perm;
  };

  // Auto-apply wenn BEIDE Contexts gecached sind (für Seiten ohne explizites initPerms/enforcePage)
  document.addEventListener('DOMContentLoaded', function () {
    try {
      var ctx = JSON.parse(sessionStorage.getItem(CTX_KEY) || 'null');
      if (ctx && ctx.role && sessionStorage.getItem(DATA_KEY) !== null) {
        window.applyNavPerms(ctx.role, ctx.tier);
      }
    } catch (e) {}
  });
})();
