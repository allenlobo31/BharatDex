import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const maroon = Color(0xFF7A1F2B);
  static const saffron = Color(0xFFE8851A);
  static const gold = Color(0xFFC9962B);
  static const teal = Color(0xFF0F6B6B);
  static const cream = Color(0xFFFBF1DC);
  static const ink = Color(0xFF3B1A1A);
  static const lightGold = Color(0xFFF3C46B);
}

ThemeData buildTheme() {
  final base = ThemeData(useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: C.maroon).copyWith(primary: C.maroon, secondary: C.saffron),
    scaffoldBackgroundColor: C.cream,
    textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(bodyColor: C.ink, displayColor: C.ink),
  );
}

TextStyle serif(double size, {Color color = C.maroon}) =>
    GoogleFonts.playfairDisplay(fontSize: size, fontWeight: FontWeight.bold, color: color);

void _diamond(Canvas c, Offset p, double z, Color col) {
  final path = Path()
    ..moveTo(p.dx, p.dy - z)
    ..lineTo(p.dx + z, p.dy)
    ..lineTo(p.dx, p.dy + z)
    ..lineTo(p.dx - z, p.dy)
    ..close();
  c.drawPath(path, Paint()..color = col);
}

class _BandPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    c.drawRect(Offset.zero & s, Paint()..color = C.maroon);
    final n = (s.width / 18).floor();
    for (var i = 0; i < n; i++) {
      _diamond(c, Offset(9 + i * 18.0, s.height / 2), s.height * 0.27, i.isEven ? C.gold : C.saffron);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Maroon strip with alternating gold and saffron diamonds.
class DiamondBand extends StatelessWidget {
  final double h;
  const DiamondBand({super.key, this.h = 22});
  @override
  Widget build(BuildContext context) =>
      SizedBox(height: h, width: double.infinity, child: CustomPaint(painter: _BandPainter()));
}

class MandalaPainter extends CustomPainter {
  final bool dark;
  final double turns;
  const MandalaPainter({this.dark = true, this.turns = 0});

  @override
  void paint(Canvas c, Size s) {
    final ctr = s.center(Offset.zero);
    final r = s.shortestSide / 2;
    c.save();
    c.translate(ctr.dx, ctr.dy);
    c.rotate(turns * 2 * math.pi);
    c.translate(-ctr.dx, -ctr.dy);
    final line = Paint()
      ..color = C.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const radii = [1.0, .78, .56, .34];
    for (var i = 0; i < 4; i++) {
      final fill = i.isEven
          ? (dark ? const Color(0xFF8E2A38) : const Color(0xFFF3DDB0))
          : (dark ? C.maroon : C.cream);
      c.drawCircle(ctr, r * radii[i], Paint()..color = fill);
      c.drawCircle(ctr, r * radii[i], line);
    }
    for (var k = 0; k < 16; k++) {
      final a = k * math.pi / 8;
      c.drawCircle(ctr + Offset(math.cos(a), math.sin(a)) * (r * .89), r * .06,
          Paint()..color = k.isOdd ? C.saffron : C.gold);
    }
    for (var k = 0; k < 8; k++) {
      final a = k * math.pi / 4;
      _diamond(c, ctr + Offset(math.cos(a), math.sin(a)) * (r * .45), r * .09, k.isOdd ? C.saffron : C.gold);
    }
    c.drawCircle(ctr, r * .13, Paint()..color = C.saffron);
    c.drawCircle(ctr, r * .13, line);
    c.restore();
  }

  @override
  bool shouldRepaint(covariant MandalaPainter o) => o.turns != turns || o.dark != dark;
}

class OrnamentDivider extends StatelessWidget {
  const OrnamentDivider({super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 60, height: 1.5, color: C.gold),
          const SizedBox(width: 8),
          Transform.rotate(angle: math.pi / 4, child: Container(width: 8, height: 8, color: C.saffron)),
          const SizedBox(width: 8),
          Container(width: 60, height: 1.5, color: C.gold),
        ]),
      );
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(text, textAlign: TextAlign.center, style: serif(26)),
        const OrnamentDivider(),
      ]);
}

/// White rounded card, gold border, coloured top strip.
class CultureCard extends StatelessWidget {
  final Widget child;
  final Color accent;
  final VoidCallback? onTap;
  const CultureCard({super.key, required this.child, this.accent = C.saffron, this.onTap});
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: C.gold, width: 1.25)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(height: 5, color: accent),
            Padding(padding: const EdgeInsets.all(14), child: child),
          ]),
        ),
      );
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  const PrimaryButton(this.label, this.onTap, {super.key, this.icon});
  @override
  Widget build(BuildContext context) => FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon ?? Icons.arrow_forward, size: 20),
        label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        style: FilledButton.styleFrom(
          backgroundColor: C.saffron,
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
      );
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  const SecondaryButton(this.label, this.onTap, {super.key, this.icon});
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon ?? Icons.arrow_forward, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          foregroundColor: C.maroon,
          side: const BorderSide(color: C.maroon, width: 1.5),
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      );
}

class LanguageChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const LanguageChip(this.label, this.selected, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? C.maroon : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: C.gold, width: 1.25),
          ),
          child: Text(label, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: selected ? Colors.white : C.maroon)),
        ),
      );
}
