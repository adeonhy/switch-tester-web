const cacheFiles = [
  '/switch-tester-web/dist/index.html'
]

self.addEventListener('install', function(e) {
 e.waitUntil(
   caches.open('switch-tester').then(function(cache) {
     return cache.addAll(cacheFiles);
   })
 );
});
