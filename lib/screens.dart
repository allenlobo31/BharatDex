import 'package:flutter/material.dart';
import 'data.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'geo.dart';
import 'home.dart';
import 'map_screen.dart';
import 'scan_register.dart';
import 'theme.dart';

final tab = ValueNotifier<int>(0);
/// Point the Locate Gems map is focused on (real lat/lng).
final mapCenter = ValueNotifier<LatLng>(kDefaultFocus);

void open(BuildContext c, Widget w) => Navigator.push(c, MaterialPageRoute(builder: (_) => w));

// ───────────── Splash & language ─────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController ctl = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
  @override
  void dispose() { ctl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.maroon,
        body: SafeArea(
          child: Column(children: [
            const DiamondBand(),
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                AnimatedBuilder(
                  animation: ctl,
                  builder: (_, __) => SizedBox(width: 220, height: 220, child: CustomPaint(painter: MandalaPainter(turns: ctl.value))),
                ),
                const SizedBox(height: 28),
                Text('BharatDex', style: serif(40, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('Scan it. Learn it. Collect it.', style: TextStyle(color: C.lightGold, fontSize: 16)),
                const SizedBox(height: 36),
                PrimaryButton('Begin your journey', () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LanguageScreen()))),
              ]),
            ),
            const DiamondBand(),
          ]),
        ),
      );
}

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(children: [
            const DiamondBand(),
            Expanded(
              child: ListenableBuilder(
                listenable: app,
                builder: (_, __) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(children: [
                    const SectionTitle('Choose your language'),
                    const Text('Every story will be told in this language.', textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.6,
                        children: [for (final l in languages) LanguageChip(l, app.lang == l, () => app.setLang(l))],
                      ),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton('Continue', () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Shell()))),
                  ]),
                ),
              ),
            ),
            const DiamondBand(),
          ]),
        ),
      );
}

// ───────────── Shell with bottom nav ─────────────
class Shell extends StatelessWidget {
  const Shell({super.key});
  static const pages = [HomeScreen(), ScanScreen(), RegisterScreen(), MapScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: tab,
        builder: (_, i, __) => Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(children: [
              const DiamondBand(),
              Expanded(child: IndexedStack(index: i, children: pages)),
            ]),
          ),
          bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
            const DiamondBand(h: 14),
            NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: C.maroon,
                indicatorColor: Colors.transparent,
                iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(color: s.contains(WidgetState.selected) ? C.gold : Colors.white70)),
                labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(fontSize: 12, color: s.contains(WidgetState.selected) ? C.lightGold : Colors.white70)),
              ),
              child: NavigationBar(
                selectedIndex: i,
                onDestinationSelected: (v) => tab.value = v,
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
                  NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
                  NavigationDestination(icon: Icon(Icons.collections_bookmark_outlined), selectedIcon: Icon(Icons.collections_bookmark), label: 'Register'),
                  NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
                  NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
                ],
              ),
            ),
          ]),
        ),
      );
}

// ───────────── Place detail ─────────────
class PlaceDetail extends StatelessWidget {
  final Place p;
  const PlaceDetail(this.p, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(backgroundColor: C.maroon, foregroundColor: Colors.white, title: Text(p.name)),
        body: ListenableBuilder(
          listenable: app,
          builder: (_, __) {
            final near = nearby(Offset(p.x, p.y), exclude: p.id);
            final inTrip = app.trip.contains(p.id);
            return ListView(children: [
              Container(height: 160, color: typeColor(p.type), child: Icon(typeIcon(p.type), size: 72, color: Colors.white70)),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: serif(26)),
                  Text('${p.city}, ${p.state}'),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: [
                    Chip(label: Text(typeLabel(p.type)), backgroundColor: Colors.white),
                    if (p.cat.isNotEmpty) Chip(label: Text(p.cat), backgroundColor: Colors.white),
                  ]),
                  const SizedBox(height: 8),
                  Text(storyFor(p), style: const TextStyle(fontSize: 15, height: 1.5)),
                  if (!hasStoryInLang(p))
                    const Text('Shown in English until AI translation is added.', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 16),
                  CultureCard(accent: C.teal, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Fun fact', style: serif(16)),
                    Text(p.fact),
                  ])),
                  const SizedBox(height: 12),
                  CultureCard(accent: C.maroon, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Best time to visit', style: serif(16)),
                    Text(p.best),
                  ])),
                  const SizedBox(height: 16),
                  Center(child: PrimaryButton(inTrip ? 'Remove from trip' : 'Add to trip', () => app.toggleTrip(p.id), icon: inTrip ? Icons.check : Icons.add)),
                  const SizedBox(height: 20),
                  Text('Nearby gems', style: serif(20)),
                  const SizedBox(height: 8),
                  if (near.isEmpty) const Text('Nothing else nearby yet.'),
                  SizedBox(
                    height: 96,
                    child: ListView(scrollDirection: Axis.horizontal, children: [
                      for (final n in near)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: SizedBox(width: 160, child: CultureCard(accent: typeColor(n.type), onTap: () => open(context, PlaceDetail(n)), child: Text(n.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: serif(14)))),
                        ),
                    ]),
                  ),
                ]),
              ),
            ]);
          },
        ),
      );
}

// ───────────── Culture & Art Explorer ─────────────
class CultureScreen extends StatelessWidget {
  const CultureScreen({super.key});
  static const cats = ['Dance', 'Craft', 'Festival', 'Food', 'Art'];
  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: cats.length,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: C.maroon, foregroundColor: Colors.white, title: const Text('Culture & Art Explorer'),
            bottom: TabBar(isScrollable: true, labelColor: C.lightGold, unselectedLabelColor: Colors.white70, indicatorColor: C.saffron, tabs: [for (final c in cats) Tab(text: c)]),
          ),
          body: TabBarView(children: [
            for (final c in cats)
              ListView(padding: const EdgeInsets.all(16), children: [
                for (final p in places.where((p) => p.cat == c))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CultureCard(
                      accent: C.saffron,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p.name, style: serif(20)),
                        Text('${p.city}, ${p.state}'),
                        const SizedBox(height: 8),
                        Text(p.story['English']!),
                        const SizedBox(height: 12),
                        Wrap(spacing: 10, children: [
                          PrimaryButton('Where to find it', () {
                            mapCenter.value = geoOf(p.id);
                            tab.value = 3;
                            Navigator.pop(context);
                          }, icon: Icons.place),
                          SecondaryButton('Read more', () => open(context, PlaceDetail(p)), icon: Icons.menu_book),
                        ]),
                      ]),
                    ),
                  ),
              ]),
          ]),
        ),
      );
}

// Locate Gems (map) now lives in map_screen.dart (flutter_map, offline).

// ───────────── Trip planner ─────────────
class TripScreen extends StatelessWidget {
  const TripScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(backgroundColor: C.maroon, foregroundColor: Colors.white, title: const Text('Trip Planner')),
        body: ListenableBuilder(
          listenable: app,
          builder: (_, __) {
            if (app.trip.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(width: 120, height: 120, child: CustomPaint(painter: const MandalaPainter(dark: false))),
                    const SizedBox(height: 16),
                    Text('Your trip is empty', style: serif(22)),
                    const SizedBox(height: 8),
                    const Text('Pick a destination on the Locate Gems map and tap the plus icon to add stops.', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    PrimaryButton('Open map', () { tab.value = 3; Navigator.pop(context); }, icon: Icons.map),
                  ]),
                ),
              );
            }
            final days = (app.trip.length / 3).ceil();
            return Column(children: [
              Padding(padding: const EdgeInsets.all(16), child: Text('${app.trip.length} stops  |  about $days day${days > 1 ? 's' : ''}', style: serif(18))),
              const Text('Hold and drag to reorder', style: TextStyle(fontSize: 12)),
              Expanded(
                child: ReorderableListView(
                  padding: const EdgeInsets.all(16),
                  onReorder: app.reorder,
                  children: [
                    for (var i = 0; i < app.trip.length; i++)
                      Padding(
                        key: ValueKey(app.trip[i]),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: CultureCard(
                          accent: typeColor(byId(app.trip[i]).type),
                          child: Row(children: [
                            CircleAvatar(backgroundColor: C.maroon, foregroundColor: Colors.white, child: Text('D${i ~/ 3 + 1}')),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(byId(app.trip[i]).name, style: serif(15)),
                              Text(byId(app.trip[i]).city, style: const TextStyle(fontSize: 12)),
                            ])),
                            IconButton(onPressed: () => app.toggleTrip(app.trip[i]), icon: const Icon(Icons.close, color: C.maroon)),
                          ]),
                        ),
                      ),
                  ],
                ),
              ),
            ]);
          },
        ),
      );
}

// ───────────── Profile ─────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => ListView(padding: const EdgeInsets.all(20), children: [
          const SectionTitle('Profile'),
          CultureCard(accent: C.teal, onTap: () => open(context, const CultureScreen()), child: Row(children: [const Icon(Icons.theater_comedy, color: C.teal), const SizedBox(width: 12), Expanded(child: Text('Culture & Art Explorer', style: serif(16))), const Icon(Icons.chevron_right)])),
          const SizedBox(height: 12),
          CultureCard(accent: C.maroon, onTap: () => open(context, const TripScreen()), child: Row(children: [const Icon(Icons.route, color: C.maroon), const SizedBox(width: 12), Expanded(child: Text('Trip Planner', style: serif(16))), const Icon(Icons.chevron_right)])),
          const SizedBox(height: 12),
          CultureCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Language', style: serif(18)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final l in languages)
                ChoiceChip(
                  label: Text(l), selected: app.lang == l, onSelected: (_) => app.setLang(l),
                  selectedColor: C.maroon, backgroundColor: Colors.white, side: const BorderSide(color: C.gold),
                  labelStyle: TextStyle(color: app.lang == l ? Colors.white : C.maroon, fontWeight: FontWeight.w700),
                ),
            ]),
          ])),
          const SizedBox(height: 12),
          CultureCard(accent: C.teal, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Your journey', style: serif(18)),
            const SizedBox(height: 6),
            Text('${app.collected.length} places collected'),
            Text('${app.trip.length} stops in your trip'),
          ])),
          const SizedBox(height: 12),
          CultureCard(accent: C.maroon, child: Text('Demo build: places and stories are sample data stored in the app. Login, the live database and Gemini scanning connect in the next phase.', style: const TextStyle(fontSize: 13))),
        ]),
      );
}