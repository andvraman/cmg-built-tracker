/* Cache the prototype so it opens with no connection at all.
   Without this, "offline" just means a blank screen — the page has to be on the
   device before any of the offline behaviour underneath it matters.
   Bump CACHE whenever a file changes, or the old copy is what people get. */
var CACHE = "cmg-voice-v5";   /* bumped: meeting-log prototype */
var FILES = ["./", "./index.html", "./types.html", "./spike.html", "./manifest.webmanifest", "./icon.svg"];

self.addEventListener("install", function(e){
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE).then(function(c){ return c.addAll(FILES); }));
});

self.addEventListener("activate", function(e){
  e.waitUntil(caches.keys().then(function(keys){
    return Promise.all(keys.filter(function(k){ return k!==CACHE; })
                          .map(function(k){ return caches.delete(k); }));
  }).then(function(){ return self.clients.claim(); }));
});

/* Network first so an updated prototype is picked up as soon as there is a
   connection; cache is the fallback, which is the whole point. */
self.addEventListener("fetch", function(e){
  if(e.request.method !== "GET") return;
  e.respondWith(
    fetch(e.request).then(function(res){
      var copy = res.clone();
      caches.open(CACHE).then(function(c){ c.put(e.request, copy); });
      return res;
    }).catch(function(){
      return caches.match(e.request).then(function(hit){
        return hit || caches.match("./index.html");
      });
    })
  );
});
