import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/pusula_screen.dart';
import 'screens/main_app_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // 1. Flutter motorunu başlat (En kritik satır)
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Tarih formatlamayı başlat (Türkçe için)
  await initializeDateFormatting('tr_TR', null);
  
  // 3. Hafızayı başlat ve veriyi oku
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  
  // Buradaki anahtar kelime 'onboarding_completed' - PusulaScreen'de ne yazdıysak o olmalı.
  // Eğer daha önce kaydedilmişse true dönecek, yoksa false.
  bool isCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(IksirApp(startScreen: isCompleted ? const MainAppScreen() : const PusulaScreen()));
}

class IksirApp extends StatelessWidget {
  final Widget startScreen;
  const IksirApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'İksir',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF040D1F),
      ),
      // İşte burada hafızadan gelen sonuca göre kapıyı açıyoruz
      home: startScreen,
    );
  }
}