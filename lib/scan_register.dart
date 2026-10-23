import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'data.dart';
import 'home.dart';
import 'geo.dart' show geoOf;
import 'screens.dart' show tab, mapCenter, open, PlaceDetail;
import 'theme.dart' show C, CultureCard, serif;

const _sampleIds = ['hampi', 'tajmahal', 'varanasi'];
HomeLoc _sample(int i) => homeLocs.firstWhere((l) => l.id == _sampleIds[i]);

// ───────────── Scan tab ─────────────
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanState();
}

class _ScanState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  late final AnimationController pulse = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  @override
  void dispose() { pulse.dispose(); super.dispose(); }

  Future<void> openScanner() async {
    final idx = await Navigator.push<int>(context, MaterialPageRoute(fullscreenDialog: true, builder: (_) => const ScannerPage()));
    if (idx == null || !mounted) return;
    final loc = _sample(idx); // demo match; Gemini identification replaces this later
    final pid = placeIdFor(loc.id);
    final isNew = !app.collected.contains(pid);
    app.collect(pid);
    showLocSheet(context, loc, banner: isNew ? 'Added to your register' : 'Already in your register');
  }

  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFF230006),
        width: double.infinity,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          GestureDetector(
            onTap: openScanner,
            child: AnimatedBuilder(
              animation: pulse,
              builder: (_, __) => Transform.scale(
                scale: 1 + .02 * pulse.value,
                child: Container(
                  width: 260, height: 260,
                  decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: kG400.withOpacity(.2 + .25 * pulse.value), blurRadius: 14 + 12 * pulse.value)]),
                  child: const CustomPaint(painter: _ScanMandala()),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text('Point your camera at a monument or artwork', textAlign: TextAlign.center, style: hBody(14, c: kG400.withOpacity(.9))),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: openScanner,
            child: Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [Color(0xFFD97706), kG500, Color(0xFFFDE047)]),
                border: Border.all(color: Colors.white.withOpacity(.4), width: 2),
                boxShadow: [BoxShadow(color: kG400.withOpacity(.5), blurRadius: 24)],
              ),
              child: const Icon(Icons.qr_code_scanner, color: Color(0xFF3D000A), size: 28),
            ),
          ),
          const SizedBox(height: 8),
          Text('Scan', style: hBody(12, c: kG400, w: FontWeight.w700)),
        ]),
      );
}

class _ScanMandala extends CustomPainter {
  const _ScanMandala();
  @override
  void paint(Canvas c, Size s) {
    c.scale(s.width / 300);
    const ctr = Offset(150, 150);
    Paint fill(Color col) => Paint()..color = col;
    Paint line(Color col, double w) => Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = w;
    c.drawCircle(ctr, 140, fill(kM800));
    c.drawCircle(ctr, 140, line(kG500, 3));
    c.drawCircle(ctr, 128, line(kG500, 1.5));
    for (var i = 0; i < 20; i++) {
      final a = i * 2 * math.pi / 20 - math.pi / 2;
      c.drawCircle(ctr + Offset(math.cos(a), math.sin(a)) * 132, 7, fill(i.isEven ? kG400 : const Color(0xFFE65100)));
    }
    c.drawCircle(ctr, 102, fill(const Color(0xFF520311)));
    c.drawCircle(ctr, 102, line(kG500, 2));
    for (var i = 0; i < 8; i++) {
      c.save();
      c.translate(ctr.dx, ctr.dy);
      c.rotate(i * math.pi / 4);
      c.drawRect(const Rect.fromLTWH(-8, -90, 16, 16), fill(kG400));
      c.restore();
    }
    c.drawCircle(ctr, 68, line(kG500, 2));
    c.drawCircle(ctr, 54, fill(kM800));
    c.drawCircle(ctr, 54, line(kG500, 1.5));
    c.drawCircle(ctr, 26, fill(kG400));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ───────────── Camera scanner page ─────────────
class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & s, const Radius.circular(24)));
    final p = Paint()..color = kG400.withOpacity(.8)..style = PaintingStyle.stroke..strokeWidth = 2;
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) { c.drawPath(m.extractPath(d, d + 8), p); d += 14; }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});
  @override
  State<ScannerPage> createState() => _ScannerState();
}

class _ScannerState extends State<ScannerPage> with SingleTickerProviderStateMixin {
  CameraController? cam;
  bool live = false;
  int sample = 0;
  late final AnimationController laser = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true);

  @override
  void initState() { super.initState(); initCam(); }

  Future<void> initCam() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) return;
      final back = cams.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cams.first);
      final ctl = CameraController(back, ResolutionPreset.medium, enableAudio: false);
      await ctl.initialize();
      if (!mounted) { await ctl.dispose(); return; }
      setState(() { cam = ctl; live = true; });
    } catch (_) {/* no camera or permission denied: the sample viewfinder stays */}
  }

  @override
  void dispose() { laser.dispose(); cam?.dispose(); super.dispose(); }

  Future<void> capture() async {
    try { if (live) await cam!.takePicture(); } catch (_) {}
    if (mounted) Navigator.pop(context, sample);
  }

  Widget corner(bool top, bool left) => Positioned(
        top: top ? 8 : null, bottom: top ? null : 8, left: left ? 8 : null, right: left ? null : 8,
        child: Container(
          width: 16, height: 16,
          decoration: BoxDecoration(border: Border(
            top: top ? const BorderSide(color: kG400, width: 2) : BorderSide.none,
            bottom: top ? BorderSide.none : const BorderSide(color: kG400, width: 2),
            left: left ? const BorderSide(color: kG400, width: 2) : BorderSide.none,
            right: left ? BorderSide.none : const BorderSide(color: kG400, width: 2),
          )),
        ),
      );

  Widget viewfinder() {
    if (live && cam != null && cam!.value.isInitialized) {
      final ps = cam!.value.previewSize!;
      return SizedBox.expand(child: FittedBox(fit: BoxFit.cover, child: SizedBox(width: ps.height, height: ps.width, child: CameraPreview(cam!))));
    }
    return Stack(fit: StackFit.expand, children: [hImg(_sample(sample).image), Container(color: Colors.black.withOpacity(.3))]);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: Column(children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                FadeTransition(opacity: laser, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
                const SizedBox(width: 8),
                Text('BHARATDEX LENS ACTIVE', style: hBody(12, c: kG400, w: FontWeight.w800)),
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  customBorder: const CircleBorder(),
                  child: Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.white.withOpacity(.2), shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 16)),
                ),
              ]),
            ),
          ),
          Expanded(
            child: ClipRect(
              child: Stack(fit: StackFit.expand, children: [
                viewfinder(),
                IgnorePointer(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.black.withOpacity(.4), width: 32)))),
                Center(
                  child: SizedBox(
                    width: 256, height: 256,
                    child: Stack(children: [
                      Positioned.fill(child: CustomPaint(painter: _DashPainter())),
                      corner(true, true), corner(true, false), corner(false, true), corner(false, false),
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: laser,
                          builder: (_, __) => Align(
                            alignment: Alignment(0, -1 + 2 * laser.value),
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Colors.transparent, kG400, Colors.transparent]),
                                boxShadow: [BoxShadow(color: kG400.withOpacity(.8), blurRadius: 15)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
                Positioned(
                  bottom: 24, left: 0, right: 0,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(.7), borderRadius: BorderRadius.circular(20), border: Border.all(color: kG500.withOpacity(.3))),
                      child: Text('Align monument inside target area', style: hBody(12, c: kG400)),
                    ),
                    const SizedBox(height: 6),
                    Text('Demo match: ${_sample(sample).title}', style: hBody(11, c: Colors.white70)),
                  ]),
                ),
              ]),
            ),
          ),
          Container(
            decoration: const BoxDecoration(color: Colors.black, border: Border(top: BorderSide(color: Color(0xFF262626)))),
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              top: false,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _footBtn(Icons.autorenew, 'Switch Sample', () => setState(() => sample = (sample + 1) % _sampleIds.length)),
                GestureDetector(
                  onTap: capture,
                  child: Container(
                    width: 72, height: 72, padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)),
                    child: Container(decoration: const BoxDecoration(color: Color(0xFFFBBF24), shape: BoxShape.circle), child: const Icon(Icons.photo_camera, color: Color(0xFF3D000A), size: 24)),
                  ),
                ),
                _footBtn(Icons.arrow_back, 'Back', () => Navigator.pop(context)),
              ]),
            ),
          ),
        ]),
      );

  Widget _footBtn(IconData i, String t, VoidCallback f) => InkWell(
        onTap: f,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(i, color: Colors.white70, size: 18),
            const SizedBox(height: 4),
            Text(t, style: hBody(12, c: Colors.white70)),
          ]),
        ),
      );
}

// ───────────── Register tab ─────────────
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  Widget lockedTile(BuildContext context, Place p) => InkWell(
        onTap: () => showLockedSheet(context, p),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xB3E5DEC9), borderRadius: BorderRadius.circular(16), border: Border.all(color: kG500.withOpacity(.2))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.lock, color: const Color(0xFF737373).withOpacity(.7), size: 20),
            const SizedBox(height: 8),
            Text('???', style: hBody(12, c: const Color(0xFF737373), w: FontWeight.w800)),
            Text(typeLabel(p.type), style: hBody(10, c: const Color(0xFFA3A3A3))),
          ]),
        ),
      );

  Widget openedTile(BuildContext context, Place p) {
    final loc = homeLocForPlace(p.id);
    return InkWell(
      onTap: () => loc != null ? showLocSheet(context, loc) : open(context, PlaceDetail(p)),
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(fit: StackFit.expand, children: [
          if (loc != null) hImg(loc.image) else Container(color: typeColor(p.type).withOpacity(.9), child: Icon(typeIcon(p.type), color: Colors.white54, size: 40)),
          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.center, colors: [Color(0xE6000000), Colors.transparent]))),
          const Positioned(top: 6, right: 6, child: Icon(Icons.verified, color: kG400, size: 16)),
          Positioned(left: 6, right: 6, bottom: 6, child: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: hBody(11, c: Colors.white, w: FontWeight.w800))),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => Container(
          color: kBg,
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), children: [
            Column(children: [
              Text('Travel Register', style: hHead(30)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 64, height: 1.5, color: kG500),
                const SizedBox(width: 12),
                Transform.rotate(angle: math.pi / 4, child: Container(width: 10, height: 10, color: kG500)),
                const SizedBox(width: 12),
                Container(width: 64, height: 1.5, color: kG500),
              ]),
              const SizedBox(height: 8),
              Text('${app.collected.length} of ${places.length} unlocked', style: hBody(12, c: kGrey)),
            ]),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 3 / 4,
              children: [for (final p in places) app.collected.contains(p.id) ? openedTile(context, p) : lockedTile(context, p)],
            ),
            const SizedBox(height: 24),
            Text('Badges', style: hHead(16)),
            const SizedBox(height: 8),
            for (final b in badges)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CultureCard(
                  accent: C.gold,
                  child: Row(children: [
                    Icon(b.icon, color: app.progress(b) == 1 ? C.saffron : C.maroon, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(b.name, style: serif(15)),
                        const SizedBox(height: 6),
                        ClipRRect(borderRadius: BorderRadius.circular(5), child: LinearProgressIndicator(value: app.progress(b), minHeight: 8, color: C.teal, backgroundColor: C.cream)),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    Text('${b.ids.where(app.collected.contains).length}/${b.ids.length}'),
                  ]),
                ),
              ),
          ]),
        ),
      );
}

// ───────────── Locked card popup ─────────────
Widget _infoRow(String label, Widget value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 92, child: Text(label, style: hBody(11, c: const Color(0xFFA3A3A3), w: FontWeight.w600))),
        Expanded(child: value),
      ]),
    );

Text _q(String t, {double size = 14}) => Text(t, style: hBody(size, c: const Color(0xFF737373), w: FontWeight.w800));

void showLockedSheet(BuildContext context, Place p) {
  final loc = homeLocForPlace(p.id);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: kBg,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32)), side: BorderSide(color: kG500, width: 2)),
    builder: (ctx) => ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * .85),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 48, height: 6, decoration: BoxDecoration(color: const Color(0xFFD4D4D4), borderRadius: BorderRadius.circular(3)))),
          const SizedBox(height: 16),
          // Silhouette
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 224,
              child: Stack(fit: StackFit.expand, children: [
                if (loc != null)
                  ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: ColorFiltered(colorFilter: const ColorFilter.mode(Color(0xEB1A0A0E), BlendMode.srcATop), child: hImg(loc.image)),
                  )
                else
                  Container(color: const Color(0xFF2A0F14), child: Icon(typeIcon(p.type), size: 110, color: Colors.black)),
                Center(child: Text('?', style: hHead(80, c: kG400.withOpacity(.85)))),
                Positioned(
                  top: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: kM800, borderRadius: BorderRadius.circular(20), border: Border.all(color: kG500.withOpacity(.3))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.lock, color: kG400, size: 11),
                      const SizedBox(width: 5),
                      Text('LOCKED', style: hBody(10, c: kG400, w: FontWeight.w800)),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Text('???', style: hHead(26)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kG500.withOpacity(.2))),
            child: Column(children: [
              _infoRow('Name', _q('???')),
              _infoRow('Place', _q('???')),
              _infoRow('State', _q('???')),
              _infoRow('Type', Text(typeLabel(p.type), style: hBody(14, c: kM800, w: FontWeight.w800))),
              _infoRow('Description', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _q('??? ??? ??? ??? ???', size: 13),
                const SizedBox(height: 4),
                _q('??? ??? ??? ???', size: 13),
              ])),
            ]),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: kCream100, borderRadius: BorderRadius.circular(12), border: Border.all(color: kG500.withOpacity(.4))),
            child: Row(children: [
              const Icon(Icons.lock_open, color: kG600, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text('Visit this place and scan it with the camera to unlock its story. Use Locate to find where it is.', style: hBody(12, c: const Color(0xFF525252), h: 1.5))),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  mapCenter.value = geoOf(p.id);
                  tab.value = 3;
                },
                icon: const Icon(Icons.explore, size: 18),
                label: Text('Locate on map', style: hBody(13, c: kG400, w: FontWeight.w800)),
                style: FilledButton.styleFrom(
                  backgroundColor: kM800, foregroundColor: kG400, padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: kG500.withOpacity(.4))),
                ),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: () { Navigator.pop(ctx); tab.value = 1; },
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: Text('Scan', style: hBody(13, c: kM800, w: FontWeight.w800)),
              style: OutlinedButton.styleFrom(
                foregroundColor: kM800, side: const BorderSide(color: kM800, width: 1.5), padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ]),
          const SizedBox(height: 8),
        ]),
      ),
    ),
  );
}