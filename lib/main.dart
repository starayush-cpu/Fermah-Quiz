import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';
import 'finn.dart';
import 'games.dart';
import 'leaderboard.dart';
import 'quiz_page.dart';
import 'rolling_number.dart';
import 'share_card.dart';
import 'theme.dart';
import 'web_helpers.dart';

void main() {
  runApp(const FermahQuizHubApp());
}

class FermahQuizHubApp extends StatelessWidget {
  const FermahQuizHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fermah Quiz Hub',
      theme: appTheme(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _totalScore = 0;
  Quiz? _activeQuiz;
  String? _activeGame;
  Map<String, int> _bestScores = <String, int>{};

  final GlobalKey _quizzesKey = GlobalKey();
  final GlobalKey _gamesKey = GlobalKey();
  final GlobalKey _leaderboardKey = GlobalKey();
  final GlobalKey _shareKey = GlobalKey();
  final GlobalKey _learnKey = GlobalKey();
  // The quiz and game players render below their card grids, so scrolling
  // to the section top leaves the player out of view. These keys let the
  // open actions scroll straight to the player itself instead.
  final GlobalKey _quizPlayerKey = GlobalKey();
  final GlobalKey _gamePlayerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, int> best = <String, int>{};
    for (final Quiz quiz in quizzes) {
      best[quiz.id] = prefs.getInt('fq-best-${quiz.id}') ?? 0;
    }
    if (!mounted) return;
    setState(() {
      _totalScore = prefs.getInt('fq-total') ?? 0;
      _bestScores = best;
    });
  }

  Future<void> _addPoints(int points) async {
    final int next = _totalScore + points;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fq-total', next);
    if (!mounted) return;
    setState(() => _totalScore = next);
  }

  void _scrollTo(GlobalKey key) {
    final BuildContext? ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: reduceMotion(context)
            ? Duration.zero
            : const Duration(milliseconds: 400),
        alignment: 0,
      );
    }
  }

  void _startQuiz(Quiz quiz) {
    setState(() {
      _activeQuiz = quiz;
      _activeGame = null;
    });
    // The player builds below the grid in the same frame; scroll to it
    // once it exists so the user lands on the first question, not the grid.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollTo(_quizPlayerKey);
    });
  }

  void _openGame(String id) {
    setState(() {
      _activeGame = id;
      _activeQuiz = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollTo(_gamePlayerKey);
    });
  }

  /// A responsive grid of equal-height cards built with Wrap, not GridView.
  /// GridView inside the page scroll view did not pass taps to its buttons
  /// in headless Chrome, so the grids use plain Wrap layout instead.
  /// When [cardHeight] is null the cards size to their content instead of
  /// sharing one fixed height (used for the text-only learn cards).
  Widget _cardGrid({double? cardHeight, required List<Widget> cards}) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final int cols = width >= 1024 ? 3 : (width >= 640 ? 2 : 1);
        final double cardWidth = (width - 16.0 * (cols - 1)) / cols;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: <Widget>[
            for (final Widget card in cards)
              SizedBox(width: cardWidth, height: cardHeight, child: card),
          ],
        );
      },
    );
  }

  Widget _quizCard(Quiz quiz) {
    final int best = _bestScores[quiz.id] ?? 0;
    // Tapping anywhere on the card starts the quiz. The card itself is
    // the tap target: in headless Chrome the inner button alone did not
    // reliably receive taps, while the card-level tap always does. The
    // visible Start button is still a real button, with semantics and
    // keyboard focus, so the card is not a div with an onClick.
    return ProCard(
      onTap: () => _startQuiz(quiz),
      accent: const <Color>[AppColors.purple, AppColors.teal],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: [
              _pill(quiz.tag, AppColors.tealDark, AppColors.tealSoft),
              _pill(
                '${quiz.questions.length} questions',
                AppColors.navy,
                const Color(0xFFE2EBF0),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.purpleSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _quizIcon(quiz.id),
                  color: AppColors.purpleDark,
                  size: 24,
                  semanticLabel: quiz.title,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(quiz.title,
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(quiz.desc,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted)),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.emoji_events,
                  size: 15, color: AppColors.gold, semanticLabel: 'Trophy'),
              const SizedBox(width: 4),
              Text('Your best: $best pts',
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _startQuiz(quiz),
              style: AppButtons.navy,
              child: const Text('Start quiz'),
            ),
          ),
        ],
      ),
    );
  }

  /// One drawn icon per quiz, in a single consistent style.
  IconData _quizIcon(String id) {
    switch (id) {
      case 'basics':
        return Icons.school;
      case 'zk':
        return Icons.shield;
      case 'systems':
        return Icons.hub;
      case 'kernel':
        return Icons.settings;
      case 'blitz':
        return Icons.bolt;
      case 'community':
        return Icons.groups;
      default:
        return Icons.quiz;
    }
  }

  Widget _gameCard(String id, String title, String desc) {
    return ProCard(
      onTap: () => _openGame(id),
      edge: AppColors.tealEdge,
      accent: const <Color>[AppColors.teal, AppColors.sky],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.tealSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _gameIcon(id),
                  color: AppColors.tealDark,
                  size: 24,
                  semanticLabel: title,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(desc,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted)),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _openGame(id),
              style: AppButtons.navy,
              child: const Text('Play'),
            ),
          ),
        ],
      ),
    );
  }

  /// One drawn icon per mini game, in a single consistent style.
  IconData _gameIcon(String id) {
    switch (id) {
      case 'pairs':
        return Icons.grid_view;
      case 'rush':
        return Icons.timer;
      case 'scramble':
        return Icons.shuffle;
      case 'says':
        return Icons.touch_app;
      default:
        return Icons.videogame_asset;
    }
  }

  Widget _learnCard(LearnCard card) {
    return ProCard(
      edge: AppColors.purpleSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.tealSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _learnIcon(card.title),
                  color: AppColors.tealDark,
                  size: 22,
                  semanticLabel: card.title,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(card.title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(card.text, style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }

  /// One drawn icon per Learn card, in a single consistent style. The
  /// mapping lives here so the card data stays untouched.
  IconData _learnIcon(String title) {
    switch (title) {
      case 'Seekers':
        return Icons.search;
      case 'Matchmaker':
        return Icons.swap_horiz;
      case 'Operators':
        return Icons.memory;
      case 'Kernel':
        return Icons.settings;
      case 'ULTRAMINT':
        return Icons.token;
      case 'Froben':
        return Icons.storefront;
      case 'Fermah Pay':
        return Icons.payments;
      default:
        return Icons.lightbulb;
    }
  }

  Widget _sectionHead({
    required String kicker,
    required String title,
    required String text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  colors: <Color>[AppColors.purple, AppColors.teal],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              kicker.toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: AppColors.purpleDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 28,
              ),
        ),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _scoreChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.purple, AppColors.purpleDark],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events,
              size: 20, color: Colors.white, semanticLabel: 'Trophy'),
          const SizedBox(width: 6),
          RollingNumber(
            value: _totalScore,
            suffix: ' pts',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            rankTitle(_totalScore),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width > 768;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        toolbarHeight: 64,
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[AppColors.teal, AppColors.sky],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    wide ? 'Fermah Quiz Hub' : 'Fermah',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  if (wide)
                    const Text(
                      'Quizzes and games for the Fermafia',
                      style: TextStyle(fontSize: 12, color: Color(0xFF9FD8D8)),
                    ),
                ],
              ),
            ),
            if (wide) _scoreChip(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _hero(wide),
            _navRow(),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 44),
                      _quizzesSection(),
                      const SizedBox(height: 36),
                      _gamesSection(),
                      const SizedBox(height: 36),
                      _leaderboardSection(),
                      const SizedBox(height: 36),
                      _shareSection(),
                      const SizedBox(height: 36),
                      _learnSection(),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _hero(bool wide) {
    final Widget text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.teal,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'gFermah',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.6,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Prove you know Fermah.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Six quizzes, four mini games and one shared leaderboard, all built by a community member for the Fermafia. Learn how zero knowledge proofs, Kernel and ULTRAMINT work, earn points, and share your score card.',
          style:
              TextStyle(color: Color(0xFFC7D8E0), fontSize: 17, height: 1.55),
        ),
        const SizedBox(height: 20),
        if (!wide) ...[
          _scoreChip(),
          const SizedBox(height: 20),
        ],
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () => _scrollTo(_quizzesKey),
              style: AppButtons.primary,
              child: const Text('Start a quiz'),
            ),
            OutlinedButton(
              onPressed: () => _scrollTo(_leaderboardKey),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('See the leaderboard'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.16),
        ),
        const SizedBox(height: 16),
        const Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            _HeroStat(big: '45', label: 'quiz questions'),
            _HeroStat(big: '6', label: 'quizzes'),
            _HeroStat(big: '4', label: 'mini games'),
            _HeroStat(big: '285K', label: 'markets settled'),
          ],
        ),
      ],
    );
    final Widget mascot = Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.navy2, Color(0xFF0D3549)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        children: [
          Finn(width: 320, height: 248),
          SizedBox(height: 4),
          Text(
            'Meet Finn, your quiz host. Say gFermah and play on.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF9FB6C2), fontSize: 14),
          ),
        ],
      ),
    );
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.navy,
            Color(0xFF0A2438),
            Color(0xFF171238),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -30,
            child: _glow(240, AppColors.purple),
          ),
          Positioned(
            bottom: -90,
            left: -40,
            child: _glow(280, AppColors.teal),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 7, child: text),
                          const SizedBox(width: 32),
                          Expanded(flex: 5, child: mascot),
                        ],
                      )
                    : Column(
                        children: [mascot, const SizedBox(height: 20), text],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A soft radial glow for the hero background. It fades to nothing at
  /// its edge and never intercepts taps.
  Widget _glow(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              color.withValues(alpha: 0.22),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navRow() {
    final List<(String, GlobalKey)> links = [
      ('Quizzes', _quizzesKey),
      ('Games', _gamesKey),
      ('Leaderboard', _leaderboardKey),
      ('Share Card', _shareKey),
      ('Learn Fermah', _learnKey),
    ];
    return Container(
      color: AppColors.navy,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Center(
        child: Wrap(
          spacing: 4,
          children: links
              .map(
                (link) => TextButton(
                  onPressed: () => _scrollTo(link.$2),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 48),
                  ),
                  child: Text(
                    link.$1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _quizzesSection() {
    return Column(
      key: _quizzesKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHead(
          kicker: 'Quizzes',
          title: 'Pick a quiz, beat the clock',
          text:
              'Every question gives you 30 seconds. A correct answer earns 100 points plus a time bonus of up to 100 more. Streaks add 10 points per question in a row. Read the explainer after each answer, that is where the learning lives.',
        ),
        _cardGrid(
          cardHeight: 320,
          cards: <Widget>[
            for (final Quiz quiz in quizzes) _quizCard(quiz),
          ],
        ),
        if (_activeQuiz != null) ...[
          const SizedBox(height: 16),
          KeyedSubtree(
            key: _quizPlayerKey,
            child: QuizPlayer(
              key: ValueKey<String>(_activeQuiz!.id),
              quiz: _activeQuiz!,
              totalScore: _totalScore,
              onAddPoints: _addPoints,
              onGoToLeaderboard: () => _scrollTo(_leaderboardKey),
              onGoToShare: () => _scrollTo(_shareKey),
              // Reload the saved best scores when a quiz ends, so the
              // card above shows the new best straight away.
              onQuizFinished: _loadScores,
            ),
          ),
        ],
      ],
    );
  }

  Widget _gamesSection() {
    const List<(String, String, String)> games = [
      (
        'pairs',
        'Proof Pairs',
        'Flip the cards and match the Fermah terms. Each pair is worth 50 points.',
      ),
      (
        'rush',
        'Proof Rush',
        '60 seconds. Tap the matching word as fast as you can. Each hit is worth 50 points.',
      ),
      (
        'scramble',
        'ZK Scramble',
        'Unscramble the Fermah words. Each word is worth 60 points.',
      ),
      (
        'says',
        'Fermah Says',
        'Watch the sequence, then repeat it. Each round you clear is worth 50 points.',
      ),
    ];
    return Column(
      key: _gamesKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHead(
          kicker: 'Mini games',
          title: 'Little games, real points',
          text:
              'Every game adds points to your total score, and your total is what goes on the leaderboard. Play them in any order, as many times as you like.',
        ),
        _cardGrid(
          cardHeight: 300,
          cards: <Widget>[
            for (final (String id, String title, String desc) in games)
              _gameCard(id, title, desc),
          ],
        ),
        if (_activeGame != null) ...[
          const SizedBox(height: 16),
          KeyedSubtree(
            key: _gamePlayerKey,
            child: ProCard(
              edge: AppColors.tealEdge,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          games.firstWhere((g) => g.$1 == _activeGame!).$2,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _activeGame = null),
                        child: const Text('Close game'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_activeGame == 'pairs')
                    ProofPairsGame(onAddPoints: _addPoints)
                  else if (_activeGame == 'rush')
                    ProofRushGame(onAddPoints: _addPoints)
                  else if (_activeGame == 'scramble')
                    ZkScrambleGame(onAddPoints: _addPoints)
                  else
                    FermahSaysGame(onAddPoints: _addPoints),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _leaderboardSection() {
    return Column(
      key: _leaderboardKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHead(
          kicker: 'Leaderboard',
          title: 'Top Fermafia minds',
          text:
              'The same board for every visitor. Scores are saved in the project database, not in your browser, so your rank is real and it stays.',
        ),
        LeaderboardSection(totalScore: _totalScore),
      ],
    );
  }

  Widget _shareSection() {
    return Column(
      key: _shareKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHead(
          kicker: 'Share card',
          title: 'Show off your score',
          text:
              'Earned points? Make your card. Type your name, add your profile picture, download the card as a PNG and post it on X or Discord with the caption.',
        ),
        ShareCardSection(totalScore: _totalScore),
      ],
    );
  }

  Widget _learnSection() {
    return Column(
      key: _learnKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHead(
          kicker: 'Learn Fermah',
          title: 'The cheat sheet',
          text:
              'Fermah is the universal proof generation layer, founded by Dr. Vanishree Rao, PhD in Cryptography from UCLA with 15+ years in ZK. It raised a \$5.2M seed round in September 2024, co-led by a16z Crypto Startup Accelerator (CSX) and Lemniscap, with Bankless Ventures, LongHash Ventures, Sandeep Nailwal and Balaji Srinivasan. The testnet launched on 2 April 2025.',
        ),
        _cardGrid(
          cards: <Widget>[
            for (final LearnCard card in learnCards) _learnCard(card),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _linkButton('fermah.xyz', 'https://fermah.xyz'),
            _linkButton('ultramint.xyz', 'https://ultramint.xyz'),
            _linkButton('@fermah_xyz on X', 'https://x.com/fermah_xyz'),
            _linkButton('Fermah Discord', 'https://discord.gg/fermah'),
          ],
        ),
      ],
    );
  }

  Widget _linkButton(String label, String url) {
    return ElevatedButton(
      onPressed: () => openLinkWeb(url),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  Widget _footer() {
    return Container(
      color: AppColors.navy,
      margin: const EdgeInsets.only(top: 56),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  style: TextStyle(color: Color(0xFFC7D8E0), fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'Fermah Quiz Hub',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' is an unofficial community project, made by a community member for the Fermafia. It is not affiliated with, endorsed by, or sponsored by Fermah.',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Fermah has not confirmed any token. Never trust anyone promising a Fermah token or airdrop. Facts on this page come from fermah.xyz and @fermah_xyz. Your total points are kept in your browser. Leaderboard scores are saved to the live leaderboard, so your rank is real and it stays.',
                style: TextStyle(color: Color(0xFF8FA9B5), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String label, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.big, required this.label});
  final String big;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            big,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF9FB6C2), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
