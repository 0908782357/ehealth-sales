// Zentrales Nav — wird per <nav id="portal-nav"> in jede Seite injiziert.
// Setzt active-Klasse und öffnet die aktive Gruppe automatisch.
// toggleNavGroup wird hier global definiert (nicht mehr pro Seite).
(function () {
  // Fog & Navy theme CSS laden
  (function() {
    var lnk = document.createElement('link');
    lnk.rel = 'stylesheet';
    lnk.href = 'admin.css';
    document.head.appendChild(lnk);
  })();

  var NAV_HTML = [
    '<a class="nav-link" href="dashboard.html">',
    '  <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/></svg>',
    '  Dashboard',
    '</a>',

    '<div class="nav-group" id="nav-group-admin" style="display:none">',
    '  <div class="nav-group-header" onclick="toggleNavGroup(this)">',
    '    <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>',
    '    <span>Administration</span>',
    '    <svg class="nav-chevron" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7"/></svg>',
    '  </div>',
    '  <div class="nav-group-body">',
    '    <a class="nav-link nav-sub" href="users.html">Nutzer</a>',
    '    <a class="nav-link nav-sub" href="orders.html">Bestellungen</a>',
    '    <a class="nav-link nav-sub" href="berufsgruppen.html">Berufsgruppen</a>',
    '    <a class="nav-link nav-sub" href="themengebiete.html">Themengebiete</a>',
    '    <a class="nav-link nav-sub" href="alliance-config.html">Alliance-Stufen</a>',
    '    <a class="nav-link nav-sub" href="rechte.html">Rechte &amp; Rollen</a>',
    '  </div>',
    '</div>',

    '<div class="nav-group" id="nav-group-produkte">',
    '  <div class="nav-group-header" onclick="toggleNavGroup(this)">',
    '    <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/></svg>',
    '    <span>Produkte</span>',
    '    <svg class="nav-chevron" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7"/></svg>',
    '  </div>',
    '  <div class="nav-group-body">',
    '    <a class="nav-link nav-sub" data-perm="produkte" href="products.html">Verwaltung</a>',
    '    <div class="nav-subgroup">',
    '      <div class="nav-subgroup-label">Produktfinder</div>',
    '      <a class="nav-link nav-sub nav-sub2" data-perm="produktfinder" href="partners.html">Kunden</a>',
    '      <a class="nav-link nav-sub nav-sub2" href="finder-config.html">Finder-Konfiguration</a>',
    '    </div>',
    '  </div>',
    '</div>',

    '<a class="nav-link" data-perm="anfragen" href="anfragen.html">',
    '  <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>',
    '  Anfragecenter',
    '</a>',
    '<a class="nav-link" data-perm="kunden_mgmt" href="kunden.html">',
    '  <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/></svg>',
    '  Kunden',
    '</a>',
    '<a class="nav-link" data-perm="events" href="events.html">',
    '  <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.8"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>',
    '  Events',
    '</a>',
    '<a class="nav-link" data-perm="shop" href="shop.html">',
    '  <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/></svg>',
    '  Shop',
    '</a>',
    '<a class="nav-link" data-perm="community" href="knowledge.html">',
    '  <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/></svg>',
    '  Community',
    '</a>',
    '<a class="nav-link" data-perm="regulatorik" href="regulatorik.html">',
    '  <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3"/></svg>',
    '  Regulatorik',
    '</a>',
    '<a class="nav-link" data-perm="tirechner" href="rechner.html">',
    '  <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 11h.01M12 11h.01M15 11h.01M4 19h16a2 2 0 002-2V7a2 2 0 00-2-2H4a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>',
    '  TI-Rechner',
    '</a>',
    '<a class="nav-link" data-perm="ti_lagebild" href="ti-lagebild.html">',
    '  <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/></svg>',
    '  TI Lagebild',
    '</a>',
    '<a class="nav-link" data-perm="infinity_report" href="infinity-report.html">',
    '  <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 3H5a2 2 0 00-2 2v4m6-6h10a2 2 0 012 2v4M9 3v18m0 0h10a2 2 0 002-2V9M9 21H5a2 2 0 01-2-2V9m0 0h18"/></svg>',
    '  Infinity Report',
    '</a>',
    '<a class="nav-link" data-perm="support" href="support.html">',
    '  <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z"/></svg>',
    '  Support',
    '</a>',
    '<a class="nav-link" data-perm="tickets" href="tickets.html">',
    '  <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 17h.01"/></svg>',
    '  Tickets',
    '</a>',

    '<div class="nav-group" id="nav-group-account">',
    '  <div class="nav-group-header" onclick="toggleNavGroup(this)">',
    '    <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>',
    '    <span>Account</span>',
    '    <svg class="nav-chevron" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7"/></svg>',
    '  </div>',
    '  <div class="nav-group-body">',
    '    <a class="nav-link nav-sub" href="profile.html">Mein Konto</a>',
    '  </div>',
    '</div>',

    '<a class="nav-link" href="../index.html">',
    '  <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>',
    '  Zur Website',
    '</a>',
  ].join('\n');

  // toggleNavGroup global — einmalig definiert (nicht mehr pro Seite)
  window.toggleNavGroup = function (h) {
    h.closest('.nav-group').classList.toggle('open');
  };

  document.addEventListener('DOMContentLoaded', function () {
    var root = document.getElementById('portal-nav');
    if (!root) return;
    root.innerHTML = NAV_HTML;

    // Aktive Seite markieren und zugehörige Gruppe öffnen
    var page = location.pathname.split('/').pop() || 'dashboard.html';
    root.querySelectorAll('a.nav-link').forEach(function (a) {
      if (a.getAttribute('href') === page) {
        a.classList.add('active');
        var group = a.closest('.nav-group');
        if (group) group.classList.add('open');
      }
    });

    // Nav-Permissions neu anwenden (perm.js hat bereits DOMContentLoaded gefeuert,
    // aber zu dem Zeitpunkt war das Nav noch nicht injiziert)
    try {
      var ctx = JSON.parse(sessionStorage.getItem('_perm_ctx') || 'null');
      if (ctx && ctx.role && typeof window.applyNavPerms === 'function') {
        window.applyNavPerms(ctx.role, ctx.tier);
      }
    } catch (e) {}
  });
})();
