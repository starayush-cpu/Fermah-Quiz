import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'theme.dart';

class BoardEntry {
  const BoardEntry({required this.name, required this.score});
  final String name;
  final int score;

  factory BoardEntry.fromJson(Map<String, dynamic> json) {
    return BoardEntry(
      name: json['name'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Shared leaderboard, saved in the Vercel KV database through
/// /api/leaderboard. When the API is not configured (or not reachable, for
/// example in a local preview), the board shows a clear note instead of
/// crashing.
class LeaderboardSection extends StatefulWidget {
  const LeaderboardSection({
    super.key,
    required this.totalScore,
  });

  final int totalScore;

  @override
  State<LeaderboardSection> createState() => _LeaderboardSectionState();
}

class _LeaderboardSectionState extends State<LeaderboardSection> {
  final TextEditingController _nameController = TextEditingController();
  List<BoardEntry> _entries = <BoardEntry>[];
  bool _configured = false;
  bool _loading = true;
  String _msg = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final http.Response res = await http
          .get(Uri.parse('/api/leaderboard'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) throw Exception('bad response');
      final Map<String, dynamic> data =
          jsonDecode(res.body) as Map<String, dynamic>;
      final List<dynamic> scores =
          data['scores'] as List<dynamic>? ?? <dynamic>[];
      setState(() {
        _configured = data['configured'] == true;
        _entries = scores
            .map((dynamic e) => BoardEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _configured = false;
        _entries = <BoardEntry>[];
        _loading = false;
      });
    }
  }

  Future<void> _submit() async {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _msg = 'Type your name first.');
      return;
    }
    if (widget.totalScore <= 0) {
      setState(() => _msg = 'Earn some points first, then save your score.');
      return;
    }
    if (!_configured) {
      setState(
        () => _msg =
            'The leaderboard is not active yet. Link the Vercel KV store to save scores.',
      );
      return;
    }
    setState(() => _msg = 'Saving your score.');
    try {
      final http.Response res = await http
          .post(
            Uri.parse('/api/leaderboard'),
            headers: <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode(<String, dynamic>{
              'name': name,
              'score': widget.totalScore,
            }),
          )
          .timeout(const Duration(seconds: 10));
      final Map<String, dynamic> data =
          jsonDecode(res.body) as Map<String, dynamic>;
      if (data['ok'] == true) {
        setState(
          () => _msg =
              'Saved! You ranked #${data['rank'] ?? '?'} with ${widget.totalScore} points.',
        );
        await _load();
      } else {
        setState(() =>
            _msg = 'Could not save: ${data['error'] ?? 'unknown error'}.');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() =>
          _msg = 'Could not reach the leaderboard. Try again in a moment.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
            if (!_configured)
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.noteBg,
                  border: Border.all(color: AppColors.noteBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Leaderboard not active yet. The board activates once the Vercel KV store is linked to this project. Scores you save now will not be stored until then.',
                  style: TextStyle(color: AppColors.noteText, fontSize: 15),
                ),
              ),
            if (_loading)
              // The text is Expanded so it wraps inside the Row instead
              // of taking its full intrinsic width and overflowing.
              const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  SizedBox(width: 12),
                  Expanded(child: Text('Loading the leaderboard.')),
                ],
              )
            else if (_entries.isEmpty)
              Text(
                _configured
                    ? 'No scores yet. Be the first to save yours.'
                    : 'No scores yet. The board activates once the Vercel KV store is linked.',
              )
            else
              Table(
                columnWidths: const <int, TableColumnWidth>{
                  0: FixedColumnWidth(56),
                  1: FlexColumnWidth(),
                  2: FixedColumnWidth(90),
                },
                children: [
                  const TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.line),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text('RANK',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted,
                            )),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text('NAME',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted,
                            )),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text('SCORE',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted,
                            )),
                      ),
                    ],
                  ),
                  ...List<TableRow>.generate(_entries.length, (int i) {
                    final BoardEntry e = _entries[i];
                    final Color? badge = i == 0
                        ? AppColors.gold
                        : (i == 1 ? AppColors.silver : (i == 2 ? AppColors.bronze : null));
                    return TableRow(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.line),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: badge != null
                              ? Container(
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: badge,
                                  ),
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                )
                              : Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  ),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(e.name),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            '${e.score}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _nameController,
                    maxLength: 20,
                    decoration: const InputDecoration(
                      hintText: 'Your name (up to 20 characters)',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _submit,
                  style: AppButtons.navy,
                  child: const Text('Save my score'),
                ),
                OutlinedButton(
                  onPressed: _load,
                  style: AppButtons.outline,
                  child: const Text('Refresh board'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(_msg, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
    );
  }
}
