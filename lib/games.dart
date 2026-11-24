import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'data.dart';
import 'theme.dart';

/// The four mini games. Each one adds points to the shared total score
/// through [onAddPoints], exactly like the HTML version.

class _PairCard {
  _PairCard(this.term);
  final String term;
  bool flipped = false;
  bool matched = false;
}

class ProofPairsGame extends StatefulWidget {
  const ProofPairsGame({super.key, required this.onAddPoints});
  final void Function(int points) onAddPoints;

  @override
  State<ProofPairsGame> createState() => _ProofPairsGameState();
}

class _ProofPairsGameState extends State<ProofPairsGame> {
  late List<_PairCard> _deck;
  final List<_PairCard> _open = <_PairCard>[];
  int _found = 0;
  int _moves = 0;
  bool _lock = false;
  String _msg = '';

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    final List<String> deck = List<String>.from(pairsTerms)..addAll(pairsTerms);
    deck.shuffle(Random());
    _deck = deck.map(_PairCard.new).toList();
    _open.clear();
    _found = 0;
    _moves = 0;
    _lock = false;
    _msg = '';
  }

  void _flip(_PairCard card) {
    if (_lock || card.flipped || card.matched) return;
    setState(() {
      card.flipped = true;
      _open.add(card);
    });
    if (_open.length == 2) {
      _moves += 1;
      if (_open[0].term == _open[1].term) {
        final List<_PairCard> pair = List<_PairCard>.from(_open);
        setState(() {
          for (final _PairCard c in pair) {
            c.matched = true;
          }
          _found += 1;
          _open.clear();
          _msg = 'Nice, a pair! +50 points.';
          if (_found == 8) {
            _msg =
                'All pairs found in $_moves moves. You earned 400 points from this game.';
          }
        });
        widget.onAddPoints(50);
      } else {
        final List<_PairCard> pair = List<_PairCard>.from(_open);
        _open.clear();
        _lock = true;
        Future<void>.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          setState(() {
            for (final _PairCard c in pair) {
              c.flipped = false;
            }
            _lock = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Pairs found: $_found / 8',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 16),
            Text('Moves: $_moves',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _deck.length,
          itemBuilder: (BuildContext context, int i) {
            final _PairCard card = _deck[i];
            final Color bg = card.matched
                ? AppColors.goodBg
                : card.flipped
                    ? Colors.white
                    : AppColors.navy;
            final Color fg = card.matched
                ? AppColors.good
                : card.flipped
                    ? AppColors.navy
                    : Colors.white;
            return SizedBox(
              height: 64,
              child: ElevatedButton(
                onPressed: () => _flip(card),
                style: ElevatedButton.styleFrom(
                  backgroundColor: bg,
                  foregroundColor: fg,
                  elevation: 0,
                  padding: const EdgeInsets.all(6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: card.flipped || card.matched
                          ? AppColors.teal
                          : AppColors.line,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  card.flipped || card.matched ? card.term : '?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        Text(_msg, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => setState(_newGame),
          style: AppButtons.outline,
          child: const Text('Shuffle and play again'),
        ),
      ],
    );
  }
}

class ProofRushGame extends StatefulWidget {
  const ProofRushGame({super.key, required this.onAddPoints});
  final void Function(int points) onAddPoints;

  @override
  State<ProofRushGame> createState() => _ProofRushGameState();
}

class _ProofRushGameState extends State<ProofRushGame> {
  int _hits = 0;
  int _pts = 0;
  int _timeLeft = 60;
  String _target = '';
  List<String> _choices = <String>[];
  bool _over = false;
  bool _started = false;
  Timer? _timer;
  String _msg = '';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    setState(() {
      _hits = 0;
      _pts = 0;
      _timeLeft = 60;
      _over = false;
      _started = true;
      _msg = '';
    });
    _newRound();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) return;
      setState(() {
        _timeLeft -= 1;
        if (_timeLeft <= 0) {
          _timer?.cancel();
          _over = true;
          _msg =
              'Time! You hit $_hits targets and earned $_pts points in this game.';
        }
      });
    });
  }

  void _newRound() {
    final Random rnd = Random();
    _target = rushWords[rnd.nextInt(rushWords.length)];
    final List<String> others = List<String>.from(rushWords)..remove(_target);
    others.shuffle(rnd);
    final List<String> picks = <String>[_target, ...others.take(5)];
    picks.shuffle(rnd);
    setState(() {
      _choices = picks;
    });
  }

  void _tap(String word) {
    if (_over || !_started) return;
    if (word == _target) {
      setState(() {
        _hits += 1;
        _pts += 50;
        _msg = '';
      });
      widget.onAddPoints(50);
      _newRound();
    } else {
      setState(() {
        _pts = _pts - 10 < 0 ? 0 : _pts - 10;
        _msg = 'Wrong one, minus 10. Look for $_target.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Time left: $_timeLeft s',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 16),
            Text('Hits: $_hits',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 16),
            Text('Game points: $_pts',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 16),
        if (!_started)
          ElevatedButton(
            onPressed: _start,
            style: AppButtons.navy,
            child: const Text('Start 60 second rush'),
          )
        else ...[
          RichText(
            text: TextSpan(
              style: const TextStyle(color: AppColors.muted, fontSize: 15),
              children: [
                const TextSpan(text: 'Tap: '),
                TextSpan(
                  text: _target,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.6,
            ),
            itemCount: _choices.length,
            itemBuilder: (BuildContext context, int i) {
              return OutlinedButton(
                onPressed: _over ? null : () => _tap(_choices[i]),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  side: const BorderSide(color: AppColors.line, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _choices[i],
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.ink,
                  ),
                ),
              );
            },
          ),
        ],
        const SizedBox(height: 14),
        Text(_msg, style: const TextStyle(fontWeight: FontWeight.w700)),
        if (_over) ...[
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _start,
            style: AppButtons.outline,
            child: const Text('Play again'),
          ),
        ],
      ],
    );
  }
}

class ZkScrambleGame extends StatefulWidget {
  const ZkScrambleGame({super.key, required this.onAddPoints});
  final void Function(int points) onAddPoints;

  @override
  State<ZkScrambleGame> createState() => _ZkScrambleGameState();
}

class _ZkScrambleGameState extends State<ZkScrambleGame> {
  late List<ScrambleWord> _order;
  int _idx = 0;
  int _solved = 0;
  String _scrambled = '';
  String _msg = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _order = List<ScrambleWord>.from(scrambleWords)..shuffle(Random());
    _scrambled = _scramble(_order[_idx].word);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _scramble(String word) {
    final List<String> letters = word.split('');
    String out = word;
    int guard = 0;
    while (out == word && guard < 10) {
      letters.shuffle(Random());
      out = letters.join();
      guard += 1;
    }
    return out;
  }

  void _check() {
    final String guess = _controller.text.trim().toUpperCase();
    if (guess == _order[_idx].word) {
      setState(() {
        _solved += 1;
        _msg = 'Correct! +60 points.';
        _idx += 1;
        _controller.clear();
        if (_idx < _order.length) {
          _scrambled = _scramble(_order[_idx].word);
        }
      });
      widget.onAddPoints(60);
    } else {
      setState(() {
        _msg = 'Not that one. Try again.';
      });
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    }
  }

  void _skip() {
    setState(() {
      _idx += 1;
      _controller.clear();
      if (_idx < _order.length) {
        _scrambled = _scramble(_order[_idx].word);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_idx >= _order.length) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Done! You unscrambled $_solved of ${_order.length} words.',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text('You earned ${_solved * 60} points from this game.',
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      );
    }
    final ScrambleWord item = _order[_idx];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Word ${_idx + 1} of ${_order.length}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 16),
            Text('Solved: $_solved',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 12),
        Text('Hint: ${item.hint}',
            style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE7F4F4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _scrambled,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: 6,
              color: AppColors.navy,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Type the word',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (_) => _check(),
              ),
            ),
            const SizedBox(width: 10),
            // On a narrow phone the three controls do not fit on one
            // line, so the buttons drop below the field instead of
            // overflowing off the right edge.
            if (MediaQuery.sizeOf(context).width < 560)
              const SizedBox.shrink()
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: _check,
                    style: AppButtons.navy,
                    child: const Text('Check'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: _skip,
                    style: AppButtons.outline,
                    child: const Text('Skip'),
                  ),
                ],
              ),
          ],
        ),
        if (MediaQuery.sizeOf(context).width < 560) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _check,
                  style: AppButtons.navy,
                  child: const Text('Check'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _skip,
                  style: AppButtons.outline,
                  child: const Text('Skip'),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 14),
        Text(_msg, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class FermahSaysGame extends StatefulWidget {
  const FermahSaysGame({super.key, required this.onAddPoints});
  final void Function(int points) onAddPoints;

  @override
  State<FermahSaysGame> createState() => _FermahSaysGameState();
}

class _FermahSaysGameState extends State<FermahSaysGame> {
  static const List<String> _labels = ['KERNEL', 'PROOF', 'MINT', 'ZK'];
  static const List<Color> _colors = [
    AppColors.teal,
    AppColors.purple,
    AppColors.navy2,
    AppColors.sky,
  ];

  final List<int> _sequence = <int>[];
  int _userIdx = 0;
  int _round = 0;
  int _lit = -1;
  bool _accepting = false;
  bool _playing = false;
  String _status = 'Press Start';
  String _msg = '';

  Future<void> _playSequence() async {
    setState(() {
      _accepting = false;
      _playing = true;
      _status = 'Watch';
    });
    for (final int pad in _sequence) {
      if (!mounted) return;
      setState(() => _lit = pad);
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      setState(() => _lit = -1);
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
    if (!mounted) return;
    setState(() {
      _playing = false;
      _accepting = true;
      _userIdx = 0;
      _status = 'Your turn';
    });
  }

  void _nextRound() {
    setState(() {
      _round += 1;
      _sequence.add(Random().nextInt(4));
    });
    Future<void>.delayed(const Duration(milliseconds: 500), _playSequence);
  }

  void _start() {
    setState(() {
      _sequence.clear();
      _round = 0;
      _msg = '';
    });
    _nextRound();
  }

  void _tap(int i) {
    if (!_accepting || _playing) return;
    setState(() => _lit = i);
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _lit = -1);
    });
    if (i == _sequence[_userIdx]) {
      _userIdx += 1;
      if (_userIdx == _sequence.length) {
        setState(() {
          _accepting = false;
          _msg = 'Round $_round clear! +50 points.';
        });
        widget.onAddPoints(50);
        Future<void>.delayed(const Duration(milliseconds: 700), _nextRound);
      }
    } else {
      setState(() {
        _accepting = false;
        _status = 'Game over';
        _msg =
            'Wrong pad. You cleared ${_round - 1} rounds. Press Start to play again.';
        _sequence.clear();
        _round = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 4,
          children: [
            Text('Round: $_round',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            Text('Status: $_status',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 16),
        // The pads are 420 wide at most, but on a narrow phone they
        // shrink to fit instead of overflowing off the right edge.
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 4,
              itemBuilder: (BuildContext context, int i) {
                return SizedBox(
                  height: 120,
                  child: ElevatedButton(
                    onPressed: () => _tap(i),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colors[i],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (_lit == i) return _colors[i];
                          return _colors[i].withValues(alpha: 0.85);
                        },
                      ),
                    ),
                    child: AnimatedScale(
                      scale: _lit == i ? 1.04 : 1.0,
                      duration: reduceMotion(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 150),
                      child: Text(
                        _labels[i],
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _start,
          style: AppButtons.navy,
          child: const Text('Start'),
        ),
        const SizedBox(height: 14),
        Text(_msg, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
