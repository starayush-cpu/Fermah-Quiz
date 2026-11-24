import 'package:flutter/material.dart';

/// Fermah brand colours, shared across the app.
class AppColors {
  static const Color navy = Color(0xFF051624);
  static const Color navy2 = Color(0xFF0A2A3F);
  static const Color teal = Color(0xFF0FA3A3);
  // Dark enough for teal text on the pale teal pill to clear 4.5:1.
  static const Color tealDark = Color(0xFF0A6E6E);
  static const Color purple = Color(0xFF9553BE);
  static const Color purpleDark = Color(0xFF7A3FA3);
  static const Color purpleSoft = Color(0xFFF0E6F7);
  // The coloured base edge of the 3D cards.
  static const Color purpleEdge = Color(0xFFD9BEE8);
  static const Color tealSoft = Color(0xFFE7F4F4);
  static const Color tealEdge = Color(0xFFBFE3E3);
  static const Color sky = Color(0xFF4AA8D8);
  static const Color bg = Color(0xFFF0F4F8);
  static const Color ink = Color(0xFF10222F);
  static const Color muted = Color(0xFF465E6B);
  static const Color line = Color(0xFFD8E2E8);
  static const Color good = Color(0xFF1E7D4D);
  static const Color goodBg = Color(0xFFDDF3E5);
  static const Color bad = Color(0xFFB3261E);
  static const Color badBg = Color(0xFFFBE3E1);
  // Dark enough for white text on it to clear 4.5:1 (the old gold did not).
  static const Color gold = Color(0xFF8A6100);
  static const Color silver = Color(0xFF5A6B76);
  static const Color bronze = Color(0xFF8C5A2B);
  static const Color noteBg = Color(0xFFFFF4D6);
  static const Color noteBorder = Color(0xFFE8C86A);
  static const Color noteText = Color(0xFF6B4E00);
}

class AppButtons {
  static ButtonStyle get primary => ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.navy,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        elevation: 2,
        shadowColor: AppColors.navy.withValues(alpha: 0.30),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  static ButtonStyle get navy => ElevatedButton.styleFrom(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        elevation: 2,
        shadowColor: AppColors.navy.withValues(alpha: 0.30),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  static ButtonStyle get purple => ElevatedButton.styleFrom(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        elevation: 2,
        shadowColor: AppColors.purple.withValues(alpha: 0.35),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  static ButtonStyle get outline => OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.navy,
        side: const BorderSide(color: AppColors.line),
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
}

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.teal,
      secondary: AppColors.purple,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    // Visible keyboard focus and hover states (Vercel guidelines: never
    // remove the focus outline without a replacement).
    focusColor: AppColors.teal.withValues(alpha: 0.20),
    hoverColor: AppColors.teal.withValues(alpha: 0.08),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.ink, fontSize: 15, height: 1.55),
      bodyLarge: TextStyle(color: AppColors.ink, fontSize: 16, height: 1.55),
      titleLarge: TextStyle(
        color: AppColors.ink,
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: TextStyle(
        color: AppColors.ink,
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

/// True when the user prefers reduced motion (on web this mirrors the
/// browser's prefers-reduced-motion setting). Animations check this and
/// jump straight to their end state instead of playing.
bool reduceMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context);

/// A professional 3D tile card: a white face sitting on a coloured base
/// edge, with layered shadows so it reads as a physical tile, not a flat
/// box. An optional gradient strip runs across the top. Interactive
/// cards (with [onTap]) lift on hover and press down on tap; static
/// panels (no [onTap]) keep the same depth without the motion.
class ProCard extends StatefulWidget {
  const ProCard({
    super.key,
    required this.child,
    this.onTap,
    this.edge = AppColors.purpleEdge,
    this.accent,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final VoidCallback? onTap;

  /// The coloured base edge visible at the bottom of the tile.
  final Color edge;

  /// Gradient colours for the strip across the top, if any.
  final List<Color>? accent;
  final EdgeInsets padding;

  @override
  State<ProCard> createState() => _ProCardState();
}

class _ProCardState extends State<ProCard> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool interactive = widget.onTap != null;
    final double lift =
        !interactive ? 0 : (_pressed ? 1 : (_hover ? -4 : 0));
    // The accent strip is a positioned overlay, not a layout child, so
    // the content below keeps the height constraints the card was given.
    // That matters for grid cards, whose content uses Spacer and needs a
    // finite height; an intermediate Column would pass it an unbounded
    // height and break the layout.
    final Widget inner = Stack(
      children: [
        Padding(
          padding: widget.padding,
          child: widget.child,
        ),
        if (widget.accent != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 6,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: widget.accent!),
              ),
            ),
          ),
      ],
    );
    return MouseRegion(
      onEnter: interactive ? (_) => setState(() => _hover = true) : null,
      onExit: interactive ? (_) => setState(() => _hover = false) : null,
      child: AnimatedContainer(
        duration: reduceMotion(context)
            ? Duration.zero
            : const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, lift, 0),
        decoration: BoxDecoration(
          color: widget.edge,
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.07),
              blurRadius: 24,
              offset: Offset(0, _hover ? 16 : 10),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: interactive
                ? Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onTap,
                      onHighlightChanged: (bool value) =>
                          setState(() => _pressed = value),
                      borderRadius: BorderRadius.circular(18),
                      child: inner,
                    ),
                  )
                : inner,
          ),
        ),
      ),
    );
  }
}
