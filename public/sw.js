// CACHE BUST: Bump this version when changing CSS, JS, layout, or site theme.
// Without a bump, returning visitors see stale cached assets until they clear
// their browser cache. New blog posts and content edits don't need a bump
// (network-first HTML means they get fresh content when online).
const CACHE_NAME = "alexo-v1";
const SHELL = ["/", "/offline.html"];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(SHELL))
  );
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener("fetch", (event) => {
  const { request } = event;
  if (request.method !== "GET") return;

  // Skip cross-origin and manifest requests
  if (!request.url.startsWith(self.location.origin)) return;
  if (request.url.endsWith(".webmanifest")) return;

  // HTML navigations: network first, cache fallback, then offline page
  if (request.headers.get("accept")?.includes("text/html")) {
    event.respondWith(
      fetch(request)
        .then((response) => {
          const clone = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(request, clone));
          return response;
        })
        .catch(() =>
          caches.match(request).then((cached) => cached || caches.match("/offline.html"))
        )
    );
    return;
  }

  // Static assets: cache first, network fallback
  event.respondWith(
    caches.match(request).then((cached) =>
      cached ||
      fetch(request)
        .then((response) => {
          if (!response.ok || response.type === "opaqueredirect") return response;
          const clone = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(request, clone));
          return response;
        })
        .catch(() => new Response("", { status: 408 }))
    )
  );
});
