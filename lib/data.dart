import 'dart:ui' show Offset;
import 'package:flutter/material.dart';

const languages = ['English', 'हिन्दी', 'ಕನ್ನಡ', 'മലയാളം', 'தமிழ்', 'తెలుగు', 'मराठी', 'বাংলা'];
const ttsCodes = {
  'English': 'en-IN', 'हिन्दी': 'hi-IN', 'ಕನ್ನಡ': 'kn-IN', 'മലയാളം': 'ml-IN',
  'தமிழ்': 'ta-IN', 'తెలుగు': 'te-IN', 'मराठी': 'mr-IN', 'বাংলা': 'bn-IN',
};

/// x, y are positions (0..1) on the stylised India map.
class Place {
  final String id, name, city, state, type, cat, best, fact;
  final double x, y;
  final Map<String, String> story;
  const Place(this.id, this.name, this.city, this.state, this.type, this.cat, this.x, this.y, this.best, this.fact, this.story);
}

const places = <Place>[
  Place('taj', 'Taj Mahal', 'Agra', 'Uttar Pradesh', 'monument', '', .50, .30, 'Oct to Mar, at sunrise',
      'The minarets lean slightly outward so they would fall away from the tomb in an earthquake.',
      {'English': 'Built by Emperor Shah Jahan between 1632 and 1653 in memory of Mumtaz Mahal, this white marble mausoleum is celebrated for its perfect symmetry and delicate inlay work.',
       'हिन्दी': 'सम्राट शाहजहाँ ने 1632 से 1653 के बीच मुमताज़ महल की याद में यह सफ़ेद संगमरमर का मकबरा बनवाया। यह अपनी सममिति और नक़्क़ाशी के लिए प्रसिद्ध है।'}),
  Place('hawa', 'Hawa Mahal', 'Jaipur', 'Rajasthan', 'monument', '', .40, .32, 'Oct to Mar, morning',
      'The palace is only one room deep.',
      {'English': 'Built in 1799, the Palace of Winds has 953 small windows that let royal women watch street life unseen while cool air flowed through.'}),
  Place('hampi', 'Hampi', 'Hampi', 'Karnataka', 'monument', '', .46, .70, 'Oct to Feb',
      'The Stone Chariot at Vittala Temple is carved from granite.',
      {'English': 'Capital of the Vijayanagara Empire, Hampi\'s boulder-strewn landscape holds temples, bazaars and royal enclosures dating mostly to the 14th to 16th centuries.',
       'हिन्दी': 'हम्पी विजयनगर साम्राज्य की राजधानी था। चट्टानों से भरे इस परिदृश्य में 14वीं से 16वीं सदी के मंदिर, बाज़ार और शाही परिसर हैं।'}),
  Place('gateway', 'Gateway of India', 'Mumbai', 'Maharashtra', 'monument', '', .31, .55, 'Nov to Feb, evening',
      'It was built to commemorate the 1911 visit of King George V.',
      {'English': 'Completed in 1924 on Mumbai\'s waterfront, this basalt arch blends Indo-Saracenic styles and became an iconic arrival point for visitors.'}),
  Place('meenakshi', 'Meenakshi Temple', 'Madurai', 'Tamil Nadu', 'monument', '', .50, .88, 'Oct to Mar',
      'The Hall of a Thousand Pillars is a showpiece of Dravidian carving.',
      {'English': 'A living temple with 14 towering gopurams covered in colourful sculptures, dedicated to goddess Meenakshi and Lord Sundareswarar.'}),
  Place('panambur', 'Panambur Beach', 'Mangalore', 'Karnataka', 'beach', '', .41, .725, 'Nov to Feb',
      'It lies close to the port at New Mangalore.',
      {'English': 'A lively Mangalore beach known for golden sand, sunset views, water sports and camel rides.',
       'हिन्दी': 'मंगलोर का यह जीवंत समुद्र तट सुनहरी रेत, सूर्यास्त के नज़ारों, वॉटर स्पोर्ट्स और ऊँट की सवारी के लिए जाना जाता है।'}),
  Place('tanni', 'Tannirbhavi Beach', 'Mangalore', 'Karnataka', 'gem', '', .412, .735, 'Nov to Feb, sunset',
      'Backwaters meet the sea here.',
      {'English': 'A quieter shoreline near Mangalore, edged by palm groves, ideal for calm sunset walks away from the crowds.'}),
  Place('mangaladevi', 'Mangaladevi Temple', 'Mangalore', 'Karnataka', 'monument', '', .408, .72, 'During Navaratri',
      'The city\'s name is traditionally linked to this goddess.',
      {'English': 'An ancient temple dedicated to goddess Mangaladevi, from whom Mangalore is believed to take its name.'}),
  Place('pilikula', 'Pilikula Heritage Village', 'Mangalore', 'Karnataka', 'gem', '', .418, .72, 'Oct to Mar',
      'Its Guthu Mane shows a traditional Tuluva family home.',
      {'English': 'A heritage village and nature park that recreates Tulu Nadu life with traditional homes, crafts and farm tools.'}),
  Place('yaksha', 'Yakshagana', 'Mangalore & Udupi', 'Karnataka', 'culture', 'Dance', .414, .728, 'Nov to May, village shows',
      'Performances traditionally run from dusk until dawn.',
      {'English': 'A night-long folk theatre of coastal Karnataka that blends dance, music, dialogue and dazzling costumes to retell stories from the epics.',
       'हिन्दी': 'यह तटीय कर्नाटक का रातभर चलने वाला लोक-रंगमंच है, जिसमें नृत्य, संगीत, संवाद और भव्य वेशभूषा के साथ महाकाव्यों की कथाएँ सुनाई जाती हैं।'}),
  Place('kambala', 'Kambala', 'Coastal Karnataka', 'Karnataka', 'culture', 'Festival', .405, .73, 'Nov to Mar',
      'Racers run behind a pair of buffaloes through slush.',
      {'English': 'A traditional buffalo race held in muddy paddy fields, celebrating the harvest and local farming life.'}),
  Place('neerdosa', 'Neer Dosa & Kori Rotti', 'Mangalore', 'Karnataka', 'culture', 'Food', .416, .732, 'Any day, local eateries',
      'Neer means water in Tulu and Kannada.',
      {'English': 'Mangalorean favourites: lacy rice crepes (neer dosa) and crisp rice wafers served with spicy chicken curry (kori rotti).'}),
  Place('kathakali', 'Kathakali', 'Kochi', 'Kerala', 'culture', 'Dance', .48, .845, 'Oct to Mar',
      'Training includes special exercises for the eyes.',
      {'English': 'A classical dance-drama of Kerala known for elaborate face paint, towering headgear and expressive eye and hand gestures.'}),
  Place('patta', 'Pattachitra', 'Raghurajpur', 'Odisha', 'culture', 'Craft', .72, .50, 'Oct to Mar',
      'Artists often prepare colours from stones and plants.',
      {'English': 'A centuries-old scroll painting tradition of Odisha, with fine lines and natural colours depicting Jagannath and mythological tales.'}),
  Place('madhubani', 'Madhubani Painting', 'Madhubani', 'Bihar', 'culture', 'Art', .68, .35, 'Oct to Mar',
      'Artists use fingers, twigs and matchsticks as brushes.',
      {'English': 'A folk art from Bihar\'s Mithila region with bold patterns, nature motifs and deities, traditionally painted by women on freshly plastered walls.'}),
  Place('varanasi', 'Kashi Vishwanath & Ghats', 'Varanasi', 'Uttar Pradesh', 'spiritual', '', .65, .34, 'Oct to Mar',
      'The evening Ganga Aarti is performed on the ghats every day.',
      {'English': 'Experience spiritual peace along Dashashwamedh Ghat during the evening Ganga Aarti and explore the labyrinth of ancient alleys.'}),
  Place('alleppey', 'Alleppey Backwaters', 'Alleppey', 'Kerala', 'nature', '', .485, .85, 'Sep to Mar',
      'Kerala houseboats evolved from old rice barges.',
      {'English': 'A serene network of backwaters, lagoons and canals where traditional houseboats glide past palm groves.'}),
  Place('amer', 'Amer Fort', 'Jaipur', 'Rajasthan', 'fort', '', .402, .325, 'Nov to Mar',
      'Its Sheesh Mahal is lined with tiny mirrors.',
      {'English': 'A hilltop fortress of yellow and pink sandstone and marble, famous for the Sheesh Mahal and grand royal courtyards.'}),
];

class Badge {
  final String name;
  final IconData icon;
  final List<String> ids;
  const Badge(this.name, this.icon, this.ids);
}

const badges = [
  Badge('Coastal Karnataka', Icons.beach_access, ['panambur', 'tanni', 'mangaladevi', 'pilikula', 'yaksha', 'kambala', 'neerdosa']),
  Badge('Heritage Circuit', Icons.account_balance, ['taj', 'hawa', 'hampi', 'gateway', 'meenakshi', 'amer']),
  Badge('Culture Keeper', Icons.theater_comedy, ['yaksha', 'kambala', 'neerdosa', 'kathakali', 'patta', 'madhubani']),
];

Color typeColor(String t) => switch (t) {
      'monument' || 'fort' => C0.maroon,
      'beach' || 'nature' => C0.teal,
      'culture' || 'spiritual' => C0.saffron,
      _ => C0.gold,
    };

IconData typeIcon(String t) => switch (t) {
      'monument' => Icons.account_balance,
      'fort' => Icons.fort,
      'beach' => Icons.beach_access,
      'nature' => Icons.landscape,
      'spiritual' => Icons.temple_hindu,
      'culture' => Icons.theater_comedy,
      _ => Icons.diamond_outlined,
    };

String typeLabel(String t) => switch (t) {
      'monument' => 'Monument',
      'fort' => 'Fort',
      'beach' => 'Beach',
      'nature' => 'Nature',
      'spiritual' => 'Spiritual',
      'culture' => 'Culture',
      _ => 'Hidden gem',
    };

bool matchType(String t, String? f) =>
    f == null || t == f || (f == 'monument' && (t == 'fort' || t == 'spiritual')) || (f == 'gem' && t == 'nature');

class C0 {
  static const maroon = Color(0xFF7A1F2B);
  static const saffron = Color(0xFFE8851A);
  static const gold = Color(0xFFC9962B);
  static const teal = Color(0xFF0F6B6B);
}

class AppState extends ChangeNotifier {
  String lang = 'English';
  final Set<String> collected = {};
  final List<String> trip = [];
  int scanIdx = 0;

  void setLang(String l) { lang = l; notifyListeners(); }
  void collect(String id) { collected.add(id); notifyListeners(); }
  void toggleTrip(String id) {
    trip.contains(id) ? trip.remove(id) : trip.add(id);
    notifyListeners();
  }
  void reorder(int o, int n) {
    if (n > o) n--;
    trip.insert(n, trip.removeAt(o));
    notifyListeners();
  }
  double progress(Badge b) => b.ids.where(collected.contains).length / b.ids.length;
}

final app = AppState();

Place byId(String id) => places.firstWhere((p) => p.id == id);

String storyFor(Place p) => p.story[app.lang] ?? p.story['English']!;
bool hasStoryInLang(Place p) => p.story.containsKey(app.lang);

/// Demo scan: returns the next uncollected landmark, then cycles.
Place nextPlace() {
  final un = places.where((p) => p.type != 'culture' && !app.collected.contains(p.id));
  return un.isNotEmpty ? un.first : places[(app.scanIdx++) % places.length];
}

List<Place> nearby(Offset o, {double r = .13, String? type, String? exclude}) {
  double d(Place p) => (Offset(p.x, p.y) - o).distance;
  final l = places.where((p) => p.id != exclude && d(p) <= r && matchType(p.type, type)).toList();
  l.sort((a, b) => d(a).compareTo(d(b)));
  return l;
}