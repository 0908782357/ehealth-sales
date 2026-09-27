// Alliance Portal — Seitenberechtigungen
// Einbinden mit <script src="perm.js"></script> vor dem Seiten-Script.
// Stellt bereit:
//   getPagePerm(role, tier, permId)  → 'hidden' | 'read' | 'edit'
//   permAtLeast(role, tier, permId, minLevel)  → boolean
//   enforcePage(role, tier, permId)  → redirectet bei 'hidden', gibt Perm zurück
(function () {
  var KEY = 'alliance_role_permissions';
  var LEVELS = { hidden: 0, read: 1, edit: 2 };

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
    var stored_val = stored[permId] && stored[permId][roleKey];
    return stored_val !== undefined ? stored_val : (def[defKey] || 'hidden');
  };

  window.permAtLeast = function (role, tier, permId, minLevel) {
    return LEVELS[window.getPagePerm(role, tier, permId)] >= LEVELS[minLevel];
  };

  // Leitet bei 'hidden' zu dashboard um, gibt sonst 'read' | 'edit' zurück
  window.enforcePage = function (role, tier, permId) {
    var perm = window.getPagePerm(role, tier, permId);
    if (perm === 'hidden') { window.location.href = 'dashboard.html'; }
    return perm;
  };
})();
