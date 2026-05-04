import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_constants.dart';

// ── Slide data ─────────────────────────────────────────────────────────────

class _Slide {
  final String titleNormal;
  final String titleBold;
  final String description;
  final IconData icon;
  final Color bgColor;
  final Color accentColor;

  const _Slide({
    required this.titleNormal,
    required this.titleBold,
    required this.description,
    required this.icon,
    required this.bgColor,
    required this.accentColor,
  });
}

const List<_Slide> _slides = [
  _Slide(
    titleNormal: 'Discover &\n',
    titleBold: 'Save Videos',
    description:
        'Explore thousands of educational videos and save your favourites with a single tap.',
    icon: Icons.play_circle_outline_rounded,
    bgColor: Color(0xFFFFF8EC),
    accentColor: Color(0xFFC9A84C),
  ),
  _Slide(
    titleNormal: 'Organise\n',
    titleBold: 'Your Way',
    description:
        'Create custom albums and playlists to keep your studies tidy and easy to revisit.',
    icon: Icons.folder_open_rounded,
    bgColor: Color(0xFFECF9F4),
    accentColor: Color(0xFF3DA87A),
  ),
  _Slide(
    titleNormal: 'Track &\n',
    titleBold: 'Share Progress',
    description:
        'Monitor your learning journey and share valuable resources with fellow students.',
    icon: Icons.analytics_outlined,
    bgColor: Color(0xFFECF3FC),
    accentColor: Color(0xFF2E6FBF),
  ),
];

// ── Screen ──────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    context.read<AppProvider>().completeOnboarding();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final top = MediaQuery.of(context).padding.top;
    final slide = _slides[_currentPage];

    return Scaffold(
      backgroundColor: slide.bgColor,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: slide.bgColor,
        child: Column(
          children: [
            // ── Top bar: logo + skip
            SizedBox(
              height: top + 64,
              child: Padding(
                padding:
                    EdgeInsets.only(top: top + 8, left: 24, right: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _LogoMark(color: slide.accentColor),
                    const SizedBox(width: 10),
                    Text(
                      'EduHub',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0C0C14),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _finish,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        foregroundColor:
                            const Color(0xFF0C0C14).withOpacity(0.40),
                      ),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Slide pages
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _slides.length,
                onPageChanged: (i) =>
                    setState(() => _currentPage = i),
                itemBuilder: (_, i) =>
                    _SlidePage(slide: _slides[i]),
              ),
            ),

            // ── Bottom controls
            _BottomBar(
              slides: _slides,
              currentPage: _currentPage,
              slide: slide,
              bottomPadding: bottom,
              onNext: _next,
              onBack: _currentPage > 0
                  ? () => _pageCtrl.previousPage(
                        duration: const Duration(milliseconds: 480),
                        curve: Curves.easeInOutCubic,
                      )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Slide page ──────────────────────────────────────────────────────────────

class _SlidePage extends StatelessWidget {
  final _Slide slide;
  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),

          // Split-weight title
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: slide.titleNormal,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 38,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF0C0C14),
                    height: 1.18,
                  ),
                ),
                TextSpan(
                  text: slide.titleBold,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: slide.accentColor,
                    height: 1.18,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Illustration
          Expanded(
            child: Center(
              child: _IllustrationCard(slide: slide),
            ),
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            slide.description,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF0C0C14).withOpacity(0.55),
              height: 1.65,
            ),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ── Illustration card ───────────────────────────────────────────────────────

class _IllustrationCard extends StatelessWidget {
  final _Slide slide;
  const _IllustrationCard({required this.slide});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _IllustrationBg(accent: slide.accentColor),
            ),
          ),
          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: slide.accentColor.withOpacity(0.24),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Icon(
              slide.icon,
              size: 52,
              color: slide.accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Illustration background ─────────────────────────────────────────────────

class _IllustrationBg extends CustomPainter {
  final Color accent;
  const _IllustrationBg({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Soft glow
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.46,
      Paint()
        ..color = accent.withOpacity(0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );

    final ring = Paint()..style = PaintingStyle.stroke;

    ring
      ..strokeWidth = 1.2
      ..color = accent.withOpacity(0.22);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.35, ring);

    ring
      ..strokeWidth = 0.9
      ..color = accent.withOpacity(0.13);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.44, ring);

    ring
      ..strokeWidth = 0.7
      ..color = accent.withOpacity(0.07);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.49, ring);

    // Orbital dots
    final r = size.width * 0.35;
    for (final angle in [
      0.0,
      math.pi / 2,
      math.pi,
      3 * math.pi / 2,
    ]) {
      final ox = cx + r * math.cos(angle);
      final oy = cy + r * math.sin(angle);
      canvas.drawCircle(
          Offset(ox, oy), 5, Paint()..color = accent.withOpacity(0.28));
      canvas.drawCircle(
          Offset(ox, oy), 3, Paint()..color = Colors.white.withOpacity(0.85));
    }

    // Cross-hair lines
    final line = Paint()
      ..color = accent.withOpacity(0.10)
      ..strokeWidth = 0.8;
    canvas.drawLine(
        Offset(cx - size.width * 0.49, cy),
        Offset(cx + size.width * 0.49, cy),
        line);
    canvas.drawLine(
        Offset(cx, cy - size.height * 0.49),
        Offset(cx, cy + size.height * 0.49),
        line);
  }

  @override
  bool shouldRepaint(_IllustrationBg old) => old.accent != accent;
}

// ── Bottom bar ──────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final List<_Slide> slides;
  final int currentPage;
  final _Slide slide;
  final double bottomPadding;
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const _BottomBar({
    required this.slides,
    required this.currentPage,
    required this.slide,
    required this.bottomPadding,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage == slides.length - 1;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding + 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F18),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Dots
          Expanded(
            child: Row(
              children: List.generate(
                slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(right: 6),
                  width: currentPage == i ? 24 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: currentPage == i
                        ? slide.accentColor
                        : Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ),

          // Back
          if (onBack != null) ...[
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.10),
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white.withOpacity(0.55),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Next / Begin
          GestureDetector(
            onTap: onNext,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 50,
              padding: EdgeInsets.symmetric(
                horizontal: isLast ? 30 : 24,
              ),
              decoration: BoxDecoration(
                color: slide.accentColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLast ? 'Begin' : 'Next',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0C0C14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                    color: Color(0xFF0C0C14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logo mark ───────────────────────────────────────────────────────────────

class _LogoMark extends StatelessWidget {
  final Color color;
  const _LogoMark({required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withOpacity(0.35), width: 1.5),
      ),
      child: Icon(
        Icons.school_rounded,
        color: color,
        size: 24,
      ),
    );
  }
}

