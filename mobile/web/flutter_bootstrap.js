{{flutter_js}}
{{flutter_build_config}}

// Deliberately no serviceWorkerSettings. Flutter's service worker is deprecated: the build now
// emits a stub that only unregisters itself, so registering it on every page load does nothing
// useful. Render serves the app files with revalidating cache headers, which is all the caching
// this app needs.
_flutter.loader.load();
