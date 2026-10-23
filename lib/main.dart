import 'package:flutter/material.dart';
import 'screens.dart';
import 'theme.dart';

void main() => runApp(const BharatDexApp());

class BharatDexApp extends StatelessWidget {
  const BharatDexApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'BharatDex',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const SplashScreen(),
      );
}
