import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'data.dart';
import 'screens.dart' show tab, SplashScreen;
import 'theme.dart';

// ───────────── Profile ─────────────
/// Images uploaded from the gallery (kept in memory for now; cloud upload comes with the backend).
final uploads = ValueNotifier<List<XFile>>([]);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Placeholder user details; these will come from the backend after login is added.
  static const userName = 'Aarav Sharma';
  static const userEmail = 'aarav.sharma@example.com';
  static const userPhone = '+91 98765 43210';

  String get initials => userName.split(' ').map((w) => w[0]).take(2).join().toUpperCase();

  void logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.cream,
        title: Text('Log Out', style: serif(20)),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: C.maroon),
            onPressed: () {
              Navigator.pop(ctx);
              tab.value = 0;
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SplashScreen()), (r) => false);
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  Widget _stat(String n, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: C.cream, borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            Text(n, style: serif(22)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ]),
        ),
      );

  Widget _contact(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(children: [
          Icon(icon, size: 14, color: C.gold),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87), overflow: TextOverflow.ellipsis)),
        ]),
      );


  Future<void> pickImages(BuildContext context) async {
    try {
      final files = await ImagePicker().pickMultiImage(imageQuality: 85);
      if (files.isEmpty) return;
      uploads.value = [...uploads.value, ...files];
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the gallery')));
      }
    }
  }

  void viewImage(BuildContext context, XFile f) => showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(children: [
            InteractiveViewer(child: Image.file(File(f.path), fit: BoxFit.contain)),
            Positioned(top: 4, right: 4, child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx))),
          ]),
        ),
      );

  Widget uploadsCard(BuildContext context) => CultureCard(
        accent: C.saffron,
        child: ValueListenableBuilder<List<XFile>>(
          valueListenable: uploads,
          builder: (_, list, __) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text('My uploads', style: serif(16))),
              Text('${list.length}', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 6),
            const Text('Photos stay on this device for now. Cloud upload connects with the backend.', style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.4)),
            const SizedBox(height: 12),
            if (list.isNotEmpty)
              GridView.count(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8,
                children: [
                  for (final f in list)
                    Stack(fit: StackFit.expand, children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: GestureDetector(
                          onTap: () => viewImage(context, f),
                          child: Image.file(File(f.path), fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: C.cream, child: const Icon(Icons.broken_image, color: Colors.black38))),
                        ),
                      ),
                      Positioned(
                        top: 4, right: 4,
                        child: GestureDetector(
                          onTap: () => uploads.value = uploads.value.where((x) => x != f).toList(),
                          child: Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, size: 12, color: Colors.white)),
                        ),
                      ),
                    ]),
                ],
              )
            else
              Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 22),
                decoration: BoxDecoration(color: C.cream, borderRadius: BorderRadius.circular(10)),
                child: const Column(children: [
                  Icon(Icons.photo_library_outlined, color: C.gold, size: 28),
                  SizedBox(height: 6),
                  Text('No images yet', style: TextStyle(fontSize: 12, color: Colors.black54)),
                ]),
              ),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: PrimaryButton('Upload images', () => pickImages(context), icon: Icons.upload)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), children: [
          const SectionTitle('Profile'),
          // User card
          CultureCard(
            accent: C.gold,
            child: Row(children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(shape: BoxShape.circle, color: C.maroon, border: Border.all(color: C.gold, width: 2)),
                alignment: Alignment.center,
                child: Text(initials, style: const TextStyle(color: C.cream, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(userName, style: serif(18)),
                  const SizedBox(height: 4),
                  _contact(Icons.email_outlined, userEmail),
                  _contact(Icons.phone_outlined, userPhone),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          // Language
          CultureCard(
            accent: C.saffron,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Language', style: serif(16)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final l in languages)
                  ChoiceChip(
                    label: Text(l), selected: app.lang == l, onSelected: (_) => app.setLang(l),
                    selectedColor: C.maroon, backgroundColor: Colors.transparent, showCheckmark: false,
                    labelStyle: TextStyle(color: app.lang == l ? Colors.white : C.maroon, fontWeight: FontWeight.w600, fontSize: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: C.gold)),
                  ),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          // Journey
          CultureCard(
            accent: C.teal,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Your journey', style: serif(16)),
              const SizedBox(height: 12),
              Row(children: [
                _stat('${app.collected.length}', 'Places collected'),
                const SizedBox(width: 12),
                _stat('${app.trip.length}', 'Stops in trip'),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          uploadsCard(context),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: C.cream, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.gold.withOpacity(.4))),
            child: const Text(
              'Demo build: places and stories are sample data stored in the app. Login, live database, and Gemini scanning connect in the next phase.',
              style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.4),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: C.maroon, foregroundColor: C.cream,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: C.gold)),
              ),
              onPressed: () => logout(context),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ]),
      );
}