import 'package:latlong2/latlong.dart' show LatLng;

/// Real-world coordinates for each [Place] id in data.dart.
///
/// NOTE: these are approximate (entered from general knowledge, not from a
/// surveyed source). Check any pin that looks off and adjust the numbers here.
const placeGeo = <String, LatLng>{
  'taj': LatLng(27.1751, 78.0421),
  'hawa': LatLng(26.9239, 75.8267),
  'hampi': LatLng(15.3350, 76.4600),
  'gateway': LatLng(18.9220, 72.8347),
  'meenakshi': LatLng(9.9195, 78.1193),
  'panambur': LatLng(12.9390, 74.8090),
  'tanni': LatLng(12.8850, 74.8180),
  'mangaladevi': LatLng(12.8556, 74.8335),
  'pilikula': LatLng(12.9300, 74.8980),
  'yaksha': LatLng(13.3409, 74.7421),
  'kambala': LatLng(13.0680, 74.9970),
  'neerdosa': LatLng(12.9141, 74.8560),
  'kathakali': LatLng(9.9312, 76.2673),
  'patta': LatLng(19.8970, 85.8250),
  'madhubani': LatLng(26.3470, 86.0710),
  'varanasi': LatLng(25.3109, 83.0107),
  'alleppey': LatLng(9.4981, 76.3388),
  'amer': LatLng(26.9855, 75.8513),
};

/// HomeLoc ids (home.dart) that differ from the Place id used above.
const _homeToPlace = {'tajmahal': 'taj', 'kerala': 'alleppey', 'jaipur': 'amer'};

LatLng geoOf(String id) => placeGeo[_homeToPlace[id] ?? id] ?? kDefaultFocus;

/// Default selection (Mangalore).
const kDefaultFocus = LatLng(12.9141, 74.8560);