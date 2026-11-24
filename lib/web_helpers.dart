// Conditional export: the real browser implementation on web, a no-op
// stub on every other platform (so widget tests can run on the VM).
export 'web_helpers_stub.dart'
    if (dart.library.js_interop) 'web_helpers_web.dart';
