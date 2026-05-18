const CACHE = 'timesheet-v123';
const ASSETS = [
  './index.html',
  './manifest.json',
  './logo.svg',
  './icon-192.png',
  './icon-512.png',
  'https://cdn.jsdelivr.net/npm/xlsx-js-style@1.2.0/dist/xlsx.bundle.js'
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(c => {
      // Cache local assets first; allow CDN to fail without breaking install
      return c.addAll(ASSETS.slice(0, 5)).then(() => {
        return c.add(ASSETS[5]).catch(() => {/* CDN may be blocked offline at install time */});
      });
    }).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const req = e.request;
  // Network-first for the HTML shell so users always get the newest UI
  const isHTML = req.mode === 'navigate' ||
                 (req.method === 'GET' && req.headers.get('accept') && req.headers.get('accept').indexOf('text/html') !== -1);
  if (isHTML) {
    e.respondWith(
      fetch(req).then(res => {
        const copy = res.clone();
        caches.open(CACHE).then(c => c.put(req, copy)).catch(()=>{});
        return res;
      }).catch(() => caches.match(req).then(c => c || caches.match('./index.html')))
    );
    return;
  }
  // Cache-first for everything else (icons, manifest, xlsx-js-style CDN bundle)
  e.respondWith(
    caches.match(req).then(cached => {
      if (cached) return cached;
      return fetch(req).then(res => {
        // Opportunistically cache successful CDN responses
        if (res && res.status === 200 && req.url.indexOf('cdn.jsdelivr.net') !== -1) {
          const copy = res.clone();
          caches.open(CACHE).then(c => c.put(req, copy)).catch(()=>{});
        }
        return res;
      });
    })
  );
});
