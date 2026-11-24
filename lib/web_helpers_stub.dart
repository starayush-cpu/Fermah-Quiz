// Stub implementations for non-web platforms (widget tests, VM runs).
// Every function is a no-op so the app can be built and tested off the web.

import 'dart:typed_data';

Future<Uint8List?> pickImageBytesWeb() async => null;

void downloadBytesWeb(Uint8List bytes, String filename) {}

Future<void> copyTextWeb(String text) async {}

Future<bool> shareWeb(String text, Uint8List? bytes) async => false;

void openLinkWeb(String url) {}
