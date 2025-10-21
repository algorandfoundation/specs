(function ensureActiveSidebarLink() {
    function normalizePath(pathname) {
        if (!pathname || pathname === '/') {
            return '/';
        }
        if (pathname.endsWith('/')) {
            pathname = pathname.slice(0, -1);
        }
        if (!pathname.endsWith('.html')) {
            pathname += '.html';
        }
        return pathname;
    }

    function applyActiveFallback() {
        if (document.querySelector('#sidebar a.active')) {
            return;
        }

        const currentPath = normalizePath(window.location.pathname);
        const sidebarLinks = Array.from(document.querySelectorAll('#sidebar a'))
            .filter(link => !link.classList.contains('toggle') && link.hasAttribute('href'));

        let match = null;
        const origin = window.location.origin + '/';

        for (const link of sidebarLinks) {
            const linkPath = normalizePath(new URL(link.getAttribute('href'), origin).pathname);
            if (linkPath === currentPath) {
                match = link;
                break;
            }
        }

        if (!match && currentPath === '/') {
            match = sidebarLinks[0];
        }

        if (match) {
            match.classList.add('active');
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', applyActiveFallback);
    } else {
        applyActiveFallback();
    }
})();