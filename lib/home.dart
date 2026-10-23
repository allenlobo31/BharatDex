import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'geo.dart' show geoOf;
import 'screens.dart' show tab, mapCenter;

const kM800 = Color(0xFF7A0C1E);
const kM900 = Color(0xFF520311);
const kG400 = Color(0xFFF3C649);
const kG500 = Color(0xFFD4AF37);
const kG600 = Color(0xFFB8860B);
const kCream100 = Color(0xFFFAF3E0);
const kCream200 = Color(0xFFF3E5C8);
const kBg = Color(0xFFFAF6EE);
const kInk = Color(0xFF2D2727);
const kGrey = Color(0xFF737373);

TextStyle hHead(double s, {Color c = kM800, FontWeight w = FontWeight.w700}) =>
    GoogleFonts.cinzel(fontSize: s, fontWeight: w, color: c, letterSpacing: .6);
TextStyle hBody(double s, {Color c = kInk, FontWeight w = FontWeight.w500, double? h}) =>
    GoogleFonts.plusJakartaSans(fontSize: s, fontWeight: w, color: c, height: h);

class Traveler {
  final String name, place, image;
  const Traveler(this.name, this.place, this.image);
}

const travelers = [
  Traveler('Ananya Sharma', 'Agra, India', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=800&q=80'),
  Traveler('Rohan Verma', 'Alleppey, Kerala', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=800&q=80'),
  Traveler('Kavya Nair', 'Varanasi Ghats', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80'),
  Traveler('Arjun Kapoor', 'Hampi Ruins', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=80'),
];

class HomeLoc {
  final String id, title, category, label, location, rating, reviews, bestTime, image, shortDesc, fullDesc, entryFee, timings;
  final List<String> highlights;
  final double x, y; // position on the Locate Gems map
  const HomeLoc(this.id, this.title, this.category, this.label, this.location, this.rating, this.reviews, this.bestTime,
      this.image, this.shortDesc, this.fullDesc, this.highlights, this.entryFee, this.timings, this.x, this.y);
}

const homeLocs = [
  HomeLoc('hampi', 'Hampi Ruins & Monoliths', 'heritage', 'HERITAGE', 'Karnataka, South India', '4.9', '3.4k', 'October - February',
      'https://images.unsplash.com/photo-1600100397608-f010e423b971?auto=format&fit=crop&w=800&q=80',
      'UNESCO World Heritage site filled with boulder-strewn hills and ancient Vijayanagara Empire ruins.',
      'Hampi is a captivating UNESCO World Heritage Site located in Karnataka. Once the prosperous capital of the Vijayanagara Empire, it boasts majestic stone temples, royal pavilions, monolith statues, and iconic chariot structures.',
      ['Stone Chariot at Vittala Temple', 'Virupaksha Temple', 'Sunset at Matanga Hill', 'Coracle Ride across Tungabhadra'],
      'INR 40 (Indians) / INR 600 (Foreigners)', '6:00 AM - 6:00 PM', .46, .70),
  HomeLoc('tajmahal', 'Taj Mahal Monument', 'heritage', 'HERITAGE', 'Agra, Uttar Pradesh', '4.9', '12.8k', 'October - March',
      'https://images.unsplash.com/photo-1564507592333-c60657eea523?auto=format&fit=crop&w=800&q=80',
      'Iconic white marble mausoleum symbolizing timeless architectural excellence and romance.',
      'Built by Mughal Emperor Shah Jahan, the Taj Mahal is an ivory-white marble mausoleum on the south bank of the Yamuna River, internationally recognized as a wonder of the modern world.',
      ['Marble Inlay Craftsmanship', 'Charbagh Mughal Gardens', 'Yamuna River Sunset View', 'Mehtab Bagh Viewpoint'],
      'INR 50 (Indians) / INR 1100 (Foreigners)', 'Sunrise to Sunset (Closed Fridays)', .50, .30),
  HomeLoc('varanasi', 'Kashi Vishwanath & Ghats', 'spiritual', 'SPIRITUAL', 'Varanasi, Uttar Pradesh', '4.9', '8.1k', 'October - March',
      'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?auto=format&fit=crop&w=800&q=80',
      'The spiritual heart of India, world-renowned for sacred river rituals and ancient heritage.',
      'Varanasi is one of the world\'s oldest continually inhabited cities. Experience spiritual peace along Dashashwamedh Ghat during the evening Ganga Aarti and explore historical labyrinth alleys.',
      ['Evening Ganga Aarti Ritual', 'Early Morning Boat Cruise', 'Kashi Vishwanath Corridor', 'Sarnath Stupas'],
      'Free Ghat Access', 'Open 24 Hours', .65, .34),
  HomeLoc('kerala', 'Alleppey Backwaters', 'nature', 'NATURE', 'Alleppey, Kerala', '4.8', '4.5k', 'September - March',
      'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?auto=format&fit=crop&w=800&q=80',
      'Tranquil palm-fringed lagoons, traditional houseboats, and serene emerald waterways.',
      'Alleppey is famous for its intricate network of serene backwaters, lagoons, and canals. Cruising in a traditional Kerala houseboat provides a peaceful glimpse into lush rural palm groves.',
      ['Overnight Houseboat Stay', 'Vembanad Lake Sunset', 'Traditional Kerala Cuisine', 'Canoe Village Tours'],
      'Varies by boat tour', '6:00 AM - 7:00 PM', .48, .85),
  HomeLoc('jaipur', 'Amer Fort & Palaces', 'heritage', 'HERITAGE', 'Jaipur, Rajasthan', '4.8', '5.2k', 'November - March',
      'https://images.unsplash.com/photo-1477587458883-47145ed94245?auto=format&fit=crop&w=800&q=80',
      'Grand hilltop fortress combining Rajput architecture with panoramic lake vistas.',
      'Amer Fort is a breathtaking fortress built with yellow and pink sandstone and marble. Famous for its Sheesh Mahal (Mirror Palace) and grand royal courtyards.',
      ['Sheesh Mahal Mirror Architecture', 'Royal Courtyards', 'Light & Sound Show', 'Maota Lake View'],
      'INR 100 (Indians) / INR 500 (Foreigners)', '8:00 AM - 5:30 PM', .40, .32),
];

const _cats = {'all': 'All Locations', 'heritage': 'Heritage Forts', 'spiritual': 'Spiritual Sites', 'nature': 'Nature & Hills', 'gem': 'Hidden Gems'};

Widget hImg(String url) => Image.network(
      url, fit: BoxFit.cover, width: double.infinity, height: double.infinity,
      errorBuilder: (_, __, ___) => Container(color: const Color(0xFF3A1A1F), child: const Icon(Icons.landscape, color: Colors.white54, size: 48)),
      loadingBuilder: (_, child, p) => p == null ? child : Container(color: const Color(0xFFE9DEC8)),
    );

Widget hPin(String text, {double size = 11}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(color: Colors.white.withOpacity(.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(.25))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.location_on, color: kG400, size: 12),
        const SizedBox(width: 6),
        Text(text, style: hBody(size + 1, c: Colors.white.withOpacity(.9))),
      ]),
    );

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  int front = 0;
  Timer? timer;
  String cat = 'all', query = '';
  final saved = <String>{};

  @override
  void initState() { super.initState(); startTimer(); }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 3), (_) => next());
  }

  void next() { if (mounted) setState(() => front = (front + 1) % travelers.length); }
  void prev() { if (mounted) setState(() => front = (front - 1 + travelers.length) % travelers.length); }

  int pos(int i) => (i - front) % travelers.length;

  // ── 3D coverflow ──
  Widget deck() => SizedBox(
        height: 380,
        child: LayoutBuilder(builder: (_, b) {
          final w = b.maxWidth * .72;
          int z(int p) => p == 0 ? 30 : (p == 2 ? 10 : 20);
          final order = List.generate(travelers.length, (i) => i)..sort((a, c) => z(pos(a)).compareTo(z(pos(c))));
          return Stack(alignment: Alignment.center, children: [for (final i in order) deckCard(i, w)]);
        }),
      );

  Widget deckCard(int i, double w) {
    final p = pos(i);
    // dx (fraction of card width), scale, rotateY degrees, opacity, darkness
    const cfg = [[0.0, 1.0, 0.0, 1.0, 0.0], [.42, .82, -18.0, .65, .4], [.65, .68, -25.0, .3, .6], [-.42, .82, 18.0, .65, .4]];
    final c = cfg[p];
    final t = travelers[i];
    final m = Matrix4.identity()
      ..setEntry(3, 2, .001)
      ..translate(c[0] * w, 0.0)
      ..rotateY(c[2] * math.pi / 180)
      ..scale(c[1]);
    const dur = Duration(milliseconds: 500);
    return IgnorePointer(
      key: ValueKey(i),
      ignoring: p == 2,
      child: GestureDetector(
        onTap: () { p == 1 ? next() : (p == 3 ? prev() : null); startTimer(); },
        child: AnimatedOpacity(
          opacity: c[3], duration: dur,
          child: AnimatedContainer(
            duration: dur, curve: Curves.easeOutCubic,
            width: w, height: 350, transform: m, transformAlignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: p == 0 ? kG500.withOpacity(.6) : Colors.white.withOpacity(.2)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.4), blurRadius: 30, offset: const Offset(0, 16))],
            ),
            child: Stack(fit: StackFit.expand, children: [
              hImg(t.image),
              const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xE6000000), Color(0x33000000), Colors.transparent]))),
              AnimatedContainer(duration: dur, color: Colors.black.withOpacity(c[4])),
              Positioned(
                left: 16, right: 16, bottom: 20,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(t.name, textAlign: TextAlign.center, style: hHead(20, c: Colors.white)),
                  const SizedBox(height: 8),
                  hPin(t.place),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget circleBtn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: () { onTap(); startTimer(); },
        customBorder: const CircleBorder(),
        child: Container(
          width: 30, height: 30,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: kG500.withOpacity(.3))),
          child: Icon(icon, size: 14, color: kM800),
        ),
      );

  // ── location cards ──
  List<HomeLoc> get filtered => homeLocs.where((l) {
        final q = query.toLowerCase();
        return (cat == 'all' || l.category == cat) && (l.title.toLowerCase().contains(q) || l.location.toLowerCase().contains(q));
      }).toList();

  Widget locCard(HomeLoc l) => GestureDetector(
        onTap: () => showLocSheet(context, l),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF78350F).withOpacity(.1)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Column(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 192,
                child: Stack(fit: StackFit.expand, children: [
                  hImg(l.image),
                  const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xD9000000), Color(0x33000000), Colors.transparent]))),
                  Positioned(
                    top: 12, left: 12, right: 12,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: kM800.withOpacity(.9), borderRadius: BorderRadius.circular(20), border: Border.all(color: kG500.withOpacity(.3))),
                        child: Text(l.label, style: hBody(10, c: kG400, w: FontWeight.w800)),
                      ),
                      InkWell(
                        onTap: () => setState(() => saved.contains(l.id) ? saved.remove(l.id) : saved.add(l.id)),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(.85), shape: BoxShape.circle),
                          child: Icon(saved.contains(l.id) ? Icons.bookmark : Icons.bookmark_border, size: 16, color: saved.contains(l.id) ? kM800 : const Color(0xFF404040)),
                        ),
                      ),
                    ]),
                  ),
                  Positioned(
                    left: 12, right: 12, bottom: 12,
                    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                          Row(children: [
                            const Icon(Icons.location_on, color: kG400, size: 12),
                            const SizedBox(width: 6),
                            Flexible(child: Text(l.location, style: hBody(11, c: kCream200.withOpacity(.9)))),
                          ]),
                          const SizedBox(height: 2),
                          Text(l.title.toUpperCase(), style: hHead(15, c: Colors.white)),
                        ]),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(.6), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(.2))),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.star, color: kG400, size: 13),
                          const SizedBox(width: 4),
                          Text(l.rating, style: hBody(12, c: Colors.white, w: FontWeight.w800)),
                        ]),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(children: [
                Expanded(child: Text(l.shortDesc, maxLines: 1, overflow: TextOverflow.ellipsis, style: hBody(12, c: const Color(0xFF525252), h: 1.5))),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(color: kCream100, borderRadius: BorderRadius.circular(12), border: Border.all(color: kG500.withOpacity(.4))),
                  child: Text('Know More', style: hBody(12, c: kM800, w: FontWeight.w800)),
                ),
              ]),
            ),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final list = filtered;
    return Container(
      color: kBg,
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), children: [
        // Namaste header
        Column(children: [
          Text('Namaste', style: hHead(36)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 64, height: 1.5, color: kG500),
            const SizedBox(width: 12),
            Transform.rotate(angle: math.pi / 4, child: Container(width: 10, height: 10, color: kG500)),
            const SizedBox(width: 12),
            Container(width: 64, height: 1.5, color: kG500),
          ]),
        ]),
        const SizedBox(height: 24),
        // Traveler Moments
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Traveler Moments', style: hHead(16)),
              Text('Stories captured by explorers', style: hBody(11, c: kGrey)),
            ]),
          ),
          circleBtn(Icons.chevron_left, prev),
          const SizedBox(width: 6),
          circleBtn(Icons.chevron_right, next),
        ]),
        Listener(onPointerDown: (_) => timer?.cancel(), onPointerUp: (_) => startTimer(), child: deck()),
        const SizedBox(height: 16),
        // Know more section
        Text('KNOW MORE ABOUT LOCATION YOU WANT', style: hHead(20)),
        const SizedBox(height: 4),
        Text('Discover heritage, history, and cultural highlights', style: hBody(12, c: kGrey)),
        const SizedBox(height: 16),
        TextField(
          onChanged: (v) => setState(() => query = v),
          style: hBody(12),
          decoration: InputDecoration(
            hintText: 'Search locations, forts, temples...',
            hintStyle: hBody(12, c: const Color(0xFFA3A3A3)),
            prefixIcon: Icon(Icons.search, size: 20, color: kG600.withOpacity(.7)),
            filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: kG500.withOpacity(.3))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: kM800)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final e in _cats.entries)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => setState(() => cat = e.key),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: cat == e.key ? kM800 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cat == e.key ? kM800 : const Color(0xFFE5E5E5)),
                    ),
                    child: Text(e.value, style: hBody(12, c: cat == e.key ? kG400 : const Color(0xFF404040), w: FontWeight.w700)),
                  ),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 16),
        if (list.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kG500.withOpacity(.3))),
            child: Column(children: [
              const Icon(Icons.explore, size: 32, color: kG500),
              const SizedBox(height: 8),
              Text('No matching locations found', style: hBody(12, c: const Color(0xFF404040), w: FontWeight.w700)),
              Text('Try adjusting your filter or search keywords', style: hBody(11, c: const Color(0xFFA3A3A3))),
            ]),
          ),
        for (final l in list) Padding(padding: const EdgeInsets.only(bottom: 16), child: locCard(l)),
      ]),
    );
  }
}

String placeIdFor(String locId) => const {'tajmahal': 'taj', 'kerala': 'alleppey', 'jaipur': 'amer'}[locId] ?? locId;

HomeLoc? homeLocForPlace(String placeId) {
  for (final l in homeLocs) {
    if (placeIdFor(l.id) == placeId) return l;
  }
  return null;
}

final FlutterTts _tts = FlutterTts();

Widget _addedBanner(HomeLoc l, String text) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 2, 4, 2),
      decoration: BoxDecoration(color: const Color(0x1A0F6B6B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0x550F6B6B))),
      child: Row(children: [
        const Icon(Icons.verified, color: Color(0xFF0F6B6B), size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: hBody(12, c: const Color(0xFF0F6B6B), w: FontWeight.w800))),
        IconButton(
          tooltip: 'Listen',
          icon: const Icon(Icons.volume_up, color: Color(0xFF0F6B6B)),
          onPressed: () async {
            final pid = placeIdFor(l.id);
            final txt = places.any((p) => p.id == pid) ? storyFor(byId(pid)) : l.fullDesc;
            await _tts.setLanguage(ttsCodes[app.lang] ?? 'en-IN');
            await _tts.speak(txt);
          },
        ),
      ]),
    );

// ── detail sheet ──
void showLocSheet(BuildContext context, HomeLoc l, {String? banner}) {
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
          if (banner != null) _addedBanner(l, banner),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 224,
              child: Stack(fit: StackFit.expand, children: [
                hImg(l.image),
                const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xD9000000), Color(0x33000000), Colors.transparent]))),
                Positioned(
                  left: 12, right: 12, bottom: 12,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(color: kM800, borderRadius: BorderRadius.circular(20), border: Border.all(color: kG500.withOpacity(.3))),
                      child: Text(l.label, style: hBody(10, c: kG400, w: FontWeight.w800)),
                    ),
                    const SizedBox(height: 4),
                    Text(l.title.toUpperCase(), style: hHead(20, c: Colors.white)),
                    Row(children: [
                      const Icon(Icons.location_on, color: kG400, size: 13),
                      const SizedBox(width: 4),
                      Text(l.location, style: hBody(12, c: kCream200)),
                    ]),
                  ]),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kG500.withOpacity(.2))),
            child: Row(children: [
              _stat('RATING', '${l.rating} (${l.reviews})', star: true),
              Container(width: 1, height: 36, color: const Color(0xFFF5F5F5)),
              _stat('BEST SEASON', l.bestTime),
              Container(width: 1, height: 36, color: const Color(0xFFF5F5F5)),
              _stat('TIMINGS', l.timings),
            ]),
          ),
          const SizedBox(height: 16),
          Text('About Destination', style: hHead(14)),
          const SizedBox(height: 4),
          Text(l.fullDesc, style: hBody(12, c: const Color(0xFF525252), h: 1.6)),
          const SizedBox(height: 16),
          Text('Key Highlights', style: hHead(14)),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2.7,
            children: [
              for (final h in l.highlights)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: kG500.withOpacity(.2))),
                  child: Row(children: [
                    const Icon(Icons.check, color: kG600, size: 14),
                    const SizedBox(width: 8),
                    Expanded(child: Text(h, style: hBody(12, c: const Color(0xFF262626)))),
                  ]),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFE5E5E5)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Entry Ticket', style: hBody(10, c: const Color(0xFFA3A3A3))),
                Text(l.entryFee, style: hBody(12, c: kM800, w: FontWeight.w800)),
              ]),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                mapCenter.value = geoOf(l.id);
                tab.value = 3;
              },
              icon: const Icon(Icons.explore, size: 16),
              label: Text('Explore Route', style: hBody(12, c: kG400, w: FontWeight.w800)),
              style: FilledButton.styleFrom(
                backgroundColor: kM800, foregroundColor: kG400,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: kG500.withOpacity(.4))),
              ),
            ),
          ]),
          const SizedBox(height: 8),
        ]),
      ),
    ),
  );
}

Widget _stat(String label, String value, {bool star = false}) => Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(children: [
          Text(label, style: hBody(10, c: const Color(0xFFA3A3A3), w: FontWeight.w600)),
          const SizedBox(height: 2),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (star) const Padding(padding: EdgeInsets.only(right: 3), child: Icon(Icons.star, color: kG500, size: 11)),
            Flexible(child: Text(value, textAlign: TextAlign.center, style: hBody(11, c: star ? kM800 : const Color(0xFF262626), w: FontWeight.w800))),
          ]),
        ]),
      ),
    );