import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';
import 'theme.dart';

/// Quiz player: 20 seconds per question, 100 points plus a time bonus of
/// up to 100 more, 10 points per streak step, explainer after each answer.
class QuizPlayer extends StatefulWidget {
  const QuizPlayer({
    super.key,
    required this.quiz,
    required this.totalScore,
    required this.onAddPoints,
    required this.onGoToLeaderboard,
    required this.onGoToShare,
  });

  final Quiz quiz;
  final int totalScore;
  final void Function(int points) onAddPoints;
  final VoidCallback onGoToLeaderboard;
  final VoidCallback onGoToShare;

  @override
  State<QuizPlayer> createState() => _QuizPlayerState();
}

class _QuizPlayerState extends State<QuizPlayer> {
  static const int _questionSeconds = 20;

  int _index = 0;
  int _score = 0;
  int _correct = 0;
  int _streak = 0;
  int _timeLeft = _questionSeconds;
  int? _picked;
  int _lastGained = 0;
  bool _answered = false;
  bool _finished = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = _questionSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) return;
      setState(() {
        _timeLeft -= 1;
        if (_timeLeft <= 0) {
          _answer(-1);
        }
      });
    });
  }

  void _answer(int choice) {
    if (_answered) return;
    _answered = true;
    _timer?.cancel();
    final QuizQuestion item = widget.quiz.questions[_index];
    final int correct = item.answer;
    int gained = 0;
    if (choice == correct) {
      _streak += 1;
      _correct += 1;
      gained = 100 + _timeLeft * 5 + (_streak - 1) * 10;
      _score += gained;
      _lastGained = gained;
      widget.onAddPoints(gained);
    } else {
      _streak = 0;
    }
    setState(() {
      _picked = choice;
    });
  }

  void _next() {
    if (_index + 1 >= widget.quiz.questions.length) {
      _finish();
    } else {
      setState(() {
        _index += 1;
        _picked = null;
        _answered = false;
      });
      _startTimer();
    }
  }

  Future<void> _finish() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = 'fq-best-${widget.quiz.id}';
    final int prevBest = prefs.getInt(key) ?? 0;
    if (_score > prevBest) {
      await prefs.setInt(key, _score);
    }
    if (mounted) {
      setState(() {
        _finished = true;
      });
    }
  }

  void _restart() {
    setState(() {
      _index = 0;
      _score = 0;
      _correct = 0;
      _streak = 0;
      _picked = null;
      _answered = false;
      _finished = false;
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return _resultsCard(context);
    }
    final QuizQuestion item = widget.quiz.questions[_index];
    final bool low = _timeLeft <= 5;
    const List<String> keys = ['A', 'B', 'C', 'D'];
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.quiz.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  'Question ${_index + 1} of ${widget.quiz.questions.length}  |  Score $_score',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: _timeLeft / _questionSeconds,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFE2EBF0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        low ? AppColors.bad : AppColors.teal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 44,
                  child: Text(
                    '${_timeLeft}s',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              item.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            ...List<Widget>.generate(item.options.length, (int i) {
              final bool isCorrect = _answered && i == item.answer;
              final bool isWrong =
                  _answered && _picked == i && _picked != item.answer;
              final Color border = isCorrect
                  ? AppColors.good
                  : isWrong
                      ? AppColors.bad
                      : AppColors.line;
              final Color? bg = isCorrect
                  ? AppColors.goodBg
                  : isWrong
                      ? AppColors.badBg
                      : null;
              final Color keyBg = isCorrect
                  ? AppColors.good
                  : isWrong
                      ? AppColors.bad
                      : const Color(0xFFE7F4F4);
              final Color keyFg =
                  (isCorrect || isWrong) ? Colors.white : AppColors.tealDark;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _answered ? null : () => _answer(i),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: bg,
                      side: BorderSide(color: border, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      alignment: Alignment.centerLeft,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: keyBg,
                          child: Text(
                            keys[i],
                            style: TextStyle(
                              color: keyFg,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.options[i],
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (_answered) ...[
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F4F4),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  border: const Border(
                    left: BorderSide(color: AppColors.teal, width: 4),
                  ),
                ),
                child: Text(
                  _picked == item.answer
                      ? 'Correct! +$_lastGained points. ${item.explainer}'
                      : _picked == -1
                          ? 'Time ran out. The right answer was: ${item.options[item.answer]}. ${item.explainer}'
                          : 'Not quite. The right answer was: ${item.options[item.answer]}. ${item.explainer}',
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Text(
                  'Streak: $_streak  |  Quiz score: $_score',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.purpleDark,
                  ),
                ),
                if (_answered)
                  ElevatedButton(
                    onPressed: _next,
                    style: AppButtons.outline,
                    child: Text(
                      _index + 1 >= widget.quiz.questions.length
                          ? 'See my results'
                          : 'Next question',
                    ),
                  ),
                OutlinedButton(
                  onPressed: () {
                    _timer?.cancel();
                    _finish();
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.navy),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Quit quiz'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultsCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '${widget.quiz.title} complete',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '$_score pts',
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            Text(
              'You answered $_correct of ${widget.quiz.questions.length} correctly.',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Your rank: ${rankTitle(widget.totalScore)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your total is now ${widget.totalScore} points. Save it on the leaderboard and make your share card below.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: widget.onGoToLeaderboard,
                  style: AppButtons.navy,
                  child: const Text('Go to leaderboard'),
                ),
                ElevatedButton(
                  onPressed: widget.onGoToShare,
                  style: AppButtons.purple,
                  child: const Text('Make my share card'),
                ),
                OutlinedButton(
                  onPressed: _restart,
                  style: AppButtons.outline,
                  child: const Text('Play again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
