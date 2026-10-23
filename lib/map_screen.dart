import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show Distance, LatLng, LengthUnit;

import 'data.dart';
import 'geo.dart';
import 'screens.dart' show PlaceDetail, mapCenter, open;
import 'theme.dart';

const _radiusKm = 120.0;
final _indiaBounds = LatLngBounds(const LatLng(6.0, 67.5), const LatLng(37.5, 98.0));

/// Locate Gems: fully offline map. State borders come from the bundled
/// assets/geo/india_states.geojson, so no tile server or internet is needed.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapState();
}

class _MapState extends State<MapScreen> {
  static const filters = {'All': null, 'Monuments': 'monument', 'Beaches': 'beach', 'Culture': 'culture', 'Hidden gems': 'gem'};

  final _ctl = MapController();
  String filter = 'All';
  String? selectedId;
  List<Polygon> _states = const [];
  bool _ready = false;
  LatLng? _tapped; // last point set by a tap on this screen (so we don't re-centre on it)

  @override
  void initState() {
    super.initState();
    _loadStates();
    mapCenter.addListener(_onExternalFocus);
  }

  @override
  void dispose() {
    mapCenter.removeListener(_onExternalFocus);
    _ctl.dispose();
    super.dispose();
  }

  /// Another screen (Home, Culture, Scan result) asked the map to focus a place.
  void _onExternalFocus() {
    if (!_ready || mapCenter.value == _tapped) return;
    _ctl.move(mapCenter.value, 7);
  }

  Future<void> _loadStates() async {
    try {
      final data = json.decode(await rootBundle.loadString('assets/geo/india_states.geojson')) as Map<String, dynamic>;
      final polys = <Polygon>[];
      for (final f in data['features'] as List) {
        final g = f['geometry'] as Map<String, dynamic>;
        final rings = g['type'] == 'Polygon' ? [g['coordinates']] : g['coordinates'] as List;
        for (final poly in rings) {
          final outer = (poly as List).first as List;
          polys.add(Polygon(
            points: [for (final p in outer) LatLng((p[1] as num).toDouble(), (p[0] as num).toDouble())],
            color: C.lightGold.withValues(alpha: .35),
            borderColor: C.gold,
            borderStrokeWidth: 1.2,
          ));
        }
      }
      if (mounted) setState(() => _states = polys);
    } catch (e) {
      debugPrint('Could not load india_states.geojson: $e');
    }
  }

  List<Place> _near(LatLng c, String? type) {
    const dist = Distance();
    double d(Place p) => dist.as(LengthUnit.Kilometer, c, geoOf(p.id));
    final l = places.where((p) => d(p) <= _radiusKm && matchType(p.type, type)).toList();
    l.sort((a, b) => d(a).compareTo(d(b)));
    return l;
  }

  void _select(LatLng p, {String? id}) {
    _tapped = p;
    selectedId = id;
    mapCenter.value = p;
  }

  void _reset() {
    _tapped = kDefaultFocus;
    selectedId = null;
    mapCenter.value = kDefaultFocus;
    _ctl.fitCamera(CameraFit.bounds(bounds: _indiaBounds, padding: const EdgeInsets.all(8)));
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: Listenable.merge([app, mapCenter]),
        builder: (_, __) {
          final type = filters[filter];
          final shown = places.where((p) => matchType(p.type, type)).toList();
          final center = mapCenter.value;
          final near = _near(center, type);
          return Column(children: [
            const Padding(padding: EdgeInsets.only(top: 12), child: SectionTitle('Locate Gems')),
            SizedBox(
              height: 44,
              child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), children: [
                for (final f in filters.keys)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f), selected: filter == f, onSelected: (_) => setState(() => filter = f),
                      selectedColor: C.maroon, backgroundColor: Colors.white, showCheckmark: true, checkmarkColor: Colors.white,
                      labelStyle: TextStyle(color: filter == f ? Colors.white : C.maroon, fontWeight: FontWeight.w700),
                      side: const BorderSide(color: C.gold),
                    ),
                  ),
              ]),
            ),
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: C.gold, width: 1.5)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(children: [
                    FlutterMap(
                      mapController: _ctl,
                      options: MapOptions(
                        backgroundColor: C.cream,
                        // Whole of India by default; zoom to the place if another tab asked for one.
                        initialCameraFit: center == kDefaultFocus ? CameraFit.bounds(bounds: _indiaBounds, padding: const EdgeInsets.all(8)) : null,
                        initialCenter: center,
                        initialZoom: 7,
                        minZoom: 3.5,
                        maxZoom: 10,
                        cameraConstraint: CameraConstraint.contain(bounds: LatLngBounds(const LatLng(2, 62), const LatLng(41, 103))),
                        interactionOptions: InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                        onMapReady: () => _ready = true,
                        onTap: (_, p) => setState(() => _select(p)),
                      ),
                      children: [
                        PolygonLayer(polygons: _states),
                        CircleLayer(circles: [
                          CircleMarker(
                            point: center, radius: _radiusKm * 1000, useRadiusInMeter: true,
                            color: C.teal.withValues(alpha: .22), borderColor: C.teal, borderStrokeWidth: 2,
                          ),
                        ]),
                        MarkerLayer(markers: [
                          for (final p in shown)
                            Marker(
                              point: geoOf(p.id),
                              width: 34, height: 34,
                              child: GestureDetector(
                                onTap: () => setState(() => _select(geoOf(p.id), id: p.id)),
                                child: _Pin(color: typeColor(p.type), icon: typeIcon(p.type), selected: p.id == selectedId),
                              ),
                            ),
                          Marker(
                            point: center, width: 14, height: 14,
                            child: const DecoratedBox(decoration: BoxDecoration(color: C.ink, shape: BoxShape.circle)),
                          ),
                        ]),
                      ],
                    ),
                    Positioned(
                      top: 8, right: 8,
                      child: Material(
                        color: Colors.white.withValues(alpha: .92),
                        shape: const CircleBorder(side: BorderSide(color: C.gold)),
                        child: IconButton(tooltip: 'Reset view', iconSize: 18, color: C.maroon, icon: const Icon(Icons.zoom_out_map), onPressed: () => setState(_reset)),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text('Tap anywhere on the map to see what is nearby', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic))),
            Expanded(
              flex: 4,
              child: near.isEmpty
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No places in range. Tap closer to Agra, Jaipur, Mumbai, Mangalore, Kochi or Madurai.', textAlign: TextAlign.center)))
                  : ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 12), children: [
                      for (final p in near)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: CultureCard(
                            accent: typeColor(p.type),
                            onTap: () => open(context, PlaceDetail(p)),
                            child: Row(children: [
                              Icon(typeIcon(p.type), color: typeColor(p.type)),
                              const SizedBox(width: 10),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(p.name, style: serif(15)),
                                Text('${typeLabel(p.type)}  |  ${p.city}', style: const TextStyle(fontSize: 12)),
                              ])),
                              IconButton(
                                tooltip: 'Add to trip',
                                onPressed: () => app.toggleTrip(p.id),
                                icon: Icon(app.trip.contains(p.id) ? Icons.check_circle : Icons.add_circle_outline, color: C.teal),
                              ),
                            ]),
                          ),
                        ),
                    ]),
            ),
          ]);
        },
      );
}

class _Pin extends StatelessWidget {
  final Color color;
  final IconData icon;
  final bool selected;
  const _Pin({required this.color, required this.icon, required this.selected});
  @override
  Widget build(BuildContext context) => AnimatedScale(
        scale: selected ? 1.3 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            color: color, shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .3), blurRadius: 5, offset: const Offset(0, 2))],
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      );
}