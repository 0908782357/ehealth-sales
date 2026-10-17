/* ===== Admin Portal Mobile Nav ===== */
(function () {
  function initMobileNav() {
    const topbar = document.querySelector('.topbar');
    const topbarRight = document.querySelector('.topbar-right');
    const sidebar = document.querySelector('.sidebar');
    if (!topbar || !sidebar) return;

    // Hamburger-Button in Topbar einfügen
    const btn = document.createElement('button');
    btn.className = 'topbar-hamburger';
    btn.setAttribute('aria-label', 'Navigation öffnen');
    btn.innerHTML = '<span></span><span></span><span></span>';
    topbarRight ? topbar.insertBefore(btn, topbarRight) : topbar.appendChild(btn);

    // Overlay-Div hinter Sidebar
    const overlay = document.createElement('div');
    overlay.className = 'sidebar-overlay';
    document.body.appendChild(overlay);

    function open() {
      btn.classList.add('open');
      sidebar.classList.add('open');
      overlay.classList.add('open');
      document.body.style.overflow = 'hidden';
    }
    function close() {
      btn.classList.remove('open');
      sidebar.classList.remove('open');
      overlay.classList.remove('open');
      document.body.style.overflow = '';
    }

    btn.addEventListener('click', () => sidebar.classList.contains('open') ? close() : open());
    overlay.addEventListener('click', close);

    // Nav-Links schließen die Sidebar auf Mobile
    sidebar.querySelectorAll('a.nav-link').forEach(link => {
      link.addEventListener('click', () => {
        if (window.innerWidth <= 768) close();
      });
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initMobileNav);
  } else {
    initMobileNav();
  }
})();
