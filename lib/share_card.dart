import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'data.dart';
import 'finn.dart';
import 'theme.dart';
import 'web_helpers.dart';

/// Share card maker: name, profile picture upload, a polished card drawn
/// as a widget, PNG download through RepaintBoundary, copyable gFermah
/// caption, and Web Share where the browser supports it.
class ShareCardSection extends StatefulWidget {
  const ShareCardSection({super.key, required this.totalScore});

  final int totalScore;

  @override
  State<ShareCardSection> createState() => _ShareCardSectionState();
}

class _ShareCardSectionState extends State<ShareCardSection> {
  final GlobalKey _cardKey = GlobalKey();
  final TextEditingController _nameController = TextEditingController();
  Uint8List? _pfpBytes;
  String _msg = '';

  String get _name => _nameController.text.trim().isEmpty
      ? 'Your name'
      : _nameController.text.trim();

  String _caption() {
    final String name = _nameController.text.trim().isEmpty
        ? 'A Fermafia member'
        : _nameController.text.trim();
    return 'gFermah! $name scored ${widget.totalScore} points on the Fermah Quiz Hub and earned the rank ${rankTitle(widget.totalScore)}. Think you can beat me? Learn more about Fermah at fermah.xyz and follow @fermah_xyz.';
  }

  Future<void> _pickPfp() async {
    if (!kIsWeb) {
      setState(() => _msg = 'Photo upload works in the web version.');
      return;
    }
    final Uint8List? bytes = await pickImageBytesWeb();
    if (bytes == null) return;
    setState(() {
      _pfpBytes = bytes;
      _msg = '';
    });
  }

  Future<void> _downloadPng() async {
    try {
      final RenderRepaintBoundary? boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final ui.Image image = await boundary.toImage(pixelRatio: 2);
      final ByteData? data =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return;
      final Uint8List bytes = data.buffer.asUint8List();
      downloadBytesWeb(bytes, 'fermah-quiz-card.png');
      setState(
        () =>
            _msg = 'Card downloaded. Post it on X or Discord with the caption.',
      );
    } catch (_) {
      setState(
          () => _msg = 'Download did not work here. Try again in a moment.');
    }
  }

  Future<void> _copyCaption() async {
    final String text = _caption();
    try {
      await copyTextWeb(text);
      setState(() => _msg = 'Caption copied.');
    } catch (_) {
      setState(
        () => _msg =
            'Copy did not work automatically, select the caption and copy it yourself.',
      );
    }
  }

  Future<void> _webShare() async {
    try {
      final RenderRepaintBoundary? boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      Uint8List? bytes;
      if (boundary != null) {
        final ui.Image image = await boundary.toImage(pixelRatio: 2);
        final ByteData? data =
            await image.toByteData(format: ui.ImageByteFormat.png);
        bytes = data?.buffer.asUint8List();
      }
      final bool shared = await shareWeb(_caption(), bytes);
      setState(
        () => _msg = shared
            ? 'Shared.'
            : 'Sharing is not supported in this browser. Download the PNG instead.',
      );
    } catch (_) {
      setState(
          () => _msg = 'Sharing did not work here. Download the PNG instead.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = constraints.maxWidth > 700;
        final Widget form = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Your name',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              maxLength: 20,
              decoration: const InputDecoration(
                hintText: 'Your name',
                border: OutlineInputBorder(),
                counterText: '',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            const Text('Your profile picture',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: _pickPfp,
              icon: const Icon(Icons.upload),
              label: Text(
                  _pfpBytes == null ? 'Choose a picture' : 'Change picture'),
              style: AppButtons.outline,
            ),
            const SizedBox(height: 12),
            const Text('Your caption',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.line, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _caption(),
                style: const TextStyle(fontSize: 15),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: _downloadPng,
                  style: AppButtons.primary,
                  child: const Text('Download card PNG'),
                ),
                OutlinedButton(
                  onPressed: _copyCaption,
                  style: AppButtons.outline,
                  child: const Text('Copy caption'),
                ),
                if (kIsWeb)
                  ElevatedButton(
                    onPressed: _webShare,
                    style: AppButtons.purple,
                    child: const Text('Share'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(_msg, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        );
        final Widget preview = Column(
          children: [
            RepaintBoundary(
              key: _cardKey,
              child: _ShareCardWidget(
                name: _name,
                pfpBytes: _pfpBytes,
                score: widget.totalScore,
                rank: rankTitle(widget.totalScore),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your card preview. It updates as you type your name or add a picture.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 14),
            ),
          ],
        );
        return ProCard(
          edge: AppColors.tealEdge,
          padding: const EdgeInsets.all(24),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: form),
                    const SizedBox(width: 24),
                    Expanded(child: preview),
                  ],
                )
              : Column(
                  children: [form, const SizedBox(height: 24), preview],
                ),
        );
      },
    );
  }
}

/// The card itself, drawn as a widget so RepaintBoundary can capture it.
class _ShareCardWidget extends StatelessWidget {
  const _ShareCardWidget({
    required this.name,
    required this.pfpBytes,
    required this.score,
    required this.rank,
  });

  final String name;
  final Uint8List? pfpBytes;
  final int score;
  final String rank;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1080 / 1350,
      child: Container(
        decoration: const BoxDecoration(color: AppColors.navy),
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 480,
            height: 600,
            child: Column(
              children: [
                Container(height: 8, color: AppColors.teal),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.teal,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'F',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FERMAH QUIZ HUB',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'gFermah',
                              style: TextStyle(
                                color: Color(0xFF9FD8D8),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.teal, width: 4),
                    color: AppColors.purple,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: pfpBytes != null
                      ? Image.memory(pfpBytes!, fit: BoxFit.cover)
                      : Center(
                          child: Text(
                            name.isEmpty ? '?' : name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'scored',
                  style: TextStyle(color: Color(0xFF9FD8D8), fontSize: 15),
                ),
                Text(
                  '$score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'POINTS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.purple,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Rank: $rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                const Finn(width: 140, height: 108),
                const SizedBox(height: 8),
                const Text(
                  'fermah.xyz  |  @fermah_xyz',
                  style: TextStyle(color: Color(0xFF8FA9B5), fontSize: 12),
                ),
                const SizedBox(height: 12),
                Container(height: 8, color: AppColors.purple),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
