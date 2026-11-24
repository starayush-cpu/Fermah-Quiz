import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Web-only helpers for the share card: file picking, PNG download,
/// clipboard copy and the Web Share API. The app targets Flutter web only,
/// so package:web is fine here.

/// Opens the browser file picker and returns the chosen image bytes.
Future<Uint8List?> pickImageBytesWeb() async {
  final web.HTMLInputElement input = web.HTMLInputElement()
    ..accept = 'image/*'
    ..type = 'file';
  input.click();
  await input.onChange.first;
  final web.FileList? files = input.files;
  if (files == null || files.length == 0) return null;
  final web.File? file = files.item(0);
  if (file == null) return null;
  final web.FileReader reader = web.FileReader();
  final Completer<void> loaded = Completer<void>();
  reader.addEventListener(
    'load',
    (web.Event _) {
      loaded.complete();
    }.toJS,
  );
  reader.readAsDataURL(file);
  await loaded.future;
  final JSAny? result = reader.result;
  if (result == null || !result.isA<JSString>()) return null;
  final String dataUrl = (result as JSString).toDart;
  final String base64Part = dataUrl.split(',').last;
  return base64Decode(base64Part);
}

/// Downloads [bytes] as a file with the given [filename].
void downloadBytesWeb(Uint8List bytes, String filename) {
  final web.Blob blob = web.Blob(
    <JSUint8Array>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'image/png'),
  );
  final String url = web.URL.createObjectURL(blob);
  final web.HTMLAnchorElement anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  anchor.click();
  web.URL.revokeObjectURL(url);
}

/// Copies [text] to the clipboard.
Future<void> copyTextWeb(String text) async {
  final web.Clipboard clipboard = web.window.navigator.clipboard;
  await clipboard.writeText(text).toDart;
}

/// Shares [text], attaching the PNG [bytes] when the browser supports
/// sharing files. Returns true when a share was started, false when the
/// Web Share API is not available here.
Future<bool> shareWeb(String text, Uint8List? bytes) async {
  final web.Navigator navigator = web.window.navigator;
  if (!(navigator as JSObject).has('share')) return false;
  try {
    final web.ShareData data;
    if (bytes != null) {
      final web.Blob blob = web.Blob(
        <JSUint8Array>[bytes.toJS].toJS,
        web.BlobPropertyBag(type: 'image/png'),
      );
      final web.File file = web.File(
        <JSObject>[blob].toJS,
        'fermah-quiz-card.png',
        web.FilePropertyBag(type: 'image/png'),
      );
      final JSArray<web.File> files = JSArray<web.File>.withLength(1);
      files[0] = file;
      final web.ShareData withFiles = web.ShareData(
        text: text,
        title: 'Fermah Quiz Hub',
        files: files,
      );
      final bool canShare = navigator.canShare(withFiles);
      data = canShare
          ? withFiles
          : web.ShareData(text: text, title: 'Fermah Quiz Hub');
    } else {
      data = web.ShareData(text: text, title: 'Fermah Quiz Hub');
    }
    await navigator.share(data).toDart;
    return true;
  } catch (_) {
    return false;
  }
}

/// Opens [url] in a new browser tab.
void openLinkWeb(String url) {
  web.window.open(url, '_blank');
}
