// Alliance Portal — Seitenberechtigungen
// <script src="perm.js"> vor dem Seiten-Script einbinden.
//
// API:
//   getPagePerm(role, tier, permId)          → 'hidden'|'read'|'edit'
//   permAtLeast(role, tier, permId, minLvl)  → boolean
//   enforcePage(role, tier, permId)          → redirect bei 'hidden', gibt Perm zurück
//   applyNavPerms(role, tier)                → versteckt [data-perm]-Links ohne Zugriff
(function () {
  var KEY      = 'alliance_role_permissions';
  var CTX_KEY  = '_perm_ctx';
  var LEVELS   = { hidden: 0, read: 1, edit: 2 };

  // Muss mit PERM_DEFS in users.html synchron bleiben
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

  function getStored() {
    try { return JSON.parse(localStorage.getItem(KEY) || '{}'); } catch { return {}; }
  }

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

  // Versteckt alle [data-perm]-Nav-Links, auf die der Nutzer keinen Zugriff hat
  window.applyNavPerms = function (role, tier) {
    document.querySelectorAll('[data-perm]').forEach(function (el) {
      var p = el.getAttribute('data-perm');
      if (window.getPagePerm(role, tier, p) === 'hidden') {
        // Parent-Container mitausblenden wenn er dadurch leer wird
        el.style.display = 'none';
        var parent = el.parentElement;
        if (parent && parent.classList.contains('nav-subgroup')) {
          var visible = parent.querySelectorAll('a[data-perm]:not([style*="none"]), a.nav-link:not([data-perm]):not([style*="none"])');
          if (visible.length === 0) parent.style.display = 'none';
        }
      }
    });
  };

  // Leitet bei 'hidden' zu dashboard um; speichert Kontext für auto-apply
  window.enforcePage = function (role, tier, permId) {
    var perm = window.getPagePerm(role, tier, permId);
    if (perm === 'hidden') { window.location.href = 'dashboard.html'; return perm; }
    // Kontext cachen für andere Seiten (z. B. dashboard)
    try { sessionStorage.setItem(CTX_KEY, JSON.stringify({ role: role, tier: tier || null })); } catch (e) {}
    window.applyNavPerms(role, tier);
    return perm;
  };

  // Auf Seiten ohne explizites enforcePage (z. B. dashboard): gespeicherten Kontext nutzen
  document.addEventListener('DOMContentLoaded', function () {
    try {
      var ctx = JSON.parse(sessionStorage.getItem(CTX_KEY) || 'null');
      if (ctx && ctx.role) window.applyNavPerms(ctx.role, ctx.tier);
    } catch (e) {}
  });
})();
