import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TitleModel {
  final String name;
  final int minXP;
  final Color color;
  final IconData icon;
  TitleModel({required this.name, required this.minXP, required this.color, required this.icon});
}

class HabitModel {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isCustom;
  HabitModel({required this.title, required this.subtitle, required this.icon, required this.color, this.isCustom = false});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'iconCode': icon.codePoint,
      'colorValue': color.value,
    };
  }

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      title: map['title'],
      subtitle: map['subtitle'],
      icon: IconData(map['iconCode'], fontFamily: 'MaterialIcons'),
      color: Color(map['colorValue']),
      isCustom: true,
    );
  }
}

class StorageService {
  static final List<TitleModel> allTitles = [
    TitleModel(name: 'Arayışçı', minXP: 0, color: Colors.grey, icon: Icons.auto_awesome),
    TitleModel(name: 'Toz ve Gölge', minXP: 200, color: Colors.brown, icon: Icons.visibility_off),
    TitleModel(name: 'Şafak Yolcusu', minXP: 500, color: Colors.blueGrey, icon: Icons.wb_twilight),
    TitleModel(name: 'Demir İrade', minXP: 1200, color: Colors.blueAccent, icon: Icons.shield),
    TitleModel(name: 'Gümüş Muhafız', minXP: 2500, color: Colors.cyanAccent, icon: Icons.security),
    TitleModel(name: 'Işığın Savaşçısı', minXP: 5000, color: Colors.amberAccent, icon: Icons.flare),
    TitleModel(name: 'İksir Ustası', minXP: 10000, color: Colors.purpleAccent, icon: Icons.workspace_premium),
    TitleModel(name: 'Kadim Bilge', minXP: 25000, color: Colors.deepPurpleAccent, icon: Icons.menu_book),
    TitleModel(name: 'Ölümsüz Disiplin', minXP: 50000, color: Colors.redAccent, icon: Icons.all_inclusive),
  ];

  static final List<HabitModel> habitPool = [
    HabitModel(title: 'Kitap Okuma', subtitle: 'Günde en az 20 sayfa.', icon: Icons.menu_book, color: Colors.blue),
    HabitModel(title: 'Meditasyon', subtitle: '10 dakika zihin temizliği.', icon: Icons.self_improvement, color: Colors.purple),
    HabitModel(title: 'Erken Kalkış', subtitle: 'Güne güneşle başla.', icon: Icons.wb_sunny, color: Colors.orange),
    HabitModel(title: 'Egzersiz', subtitle: 'En az 30 dakika hareket.', icon: Icons.fitness_center, color: Colors.red),
    HabitModel(title: 'Su Tüketimi', subtitle: 'En az 2 litre su.', icon: Icons.water_drop, color: Colors.cyan),
    HabitModel(title: 'Günlük Yazma', subtitle: 'Düşüncelerini kağıda dök.', icon: Icons.edit_note, color: Colors.teal),
    HabitModel(title: 'Yeni Dil Öğrenme', subtitle: '15 dakika pratik.', icon: Icons.language, color: Colors.indigo),
    HabitModel(title: 'Soğuk Duş', subtitle: 'İradeyi çelikleştir.', icon: Icons.ac_unit, color: Colors.lightBlue),
    HabitModel(title: 'Şükran Günlüğü', subtitle: '3 şey için teşekkür et.', icon: Icons.favorite, color: Colors.pink),
    HabitModel(title: 'Planlama', subtitle: 'Ertesi günü planla.', icon: Icons.event_note, color: Colors.blueGrey),
    HabitModel(title: 'Derin Odaklanma', subtitle: '1 saat kesintisiz çalışma.', icon: Icons.center_focus_strong, color: Colors.deepOrange),
    HabitModel(title: 'Sağlıklı Beslenme', subtitle: 'İşlenmiş gıdadan uzak dur.', icon: Icons.restaurant, color: Colors.green),
    HabitModel(title: 'Podcast Dinleme', subtitle: 'Gelişim odaklı içerik.', icon: Icons.podcasts, color: Colors.brown),
    HabitModel(title: 'Yürüyüş', subtitle: 'Doğa ile iç içe 20 dk.', icon: Icons.directions_walk, color: Colors.lightGreen),
    HabitModel(title: 'Girişimcilik Araştırma', subtitle: 'Yeni fikirler tara.', icon: Icons.lightbulb, color: Colors.amber),
    HabitModel(title: 'Finansal Takip', subtitle: 'Harcamalarını kaydet.', icon: Icons.savings, color: Colors.greenAccent),
    HabitModel(title: 'Sosyal Medya Detoksu', subtitle: 'Ekran süresini azalt.', icon: Icons.phonelink_erase, color: Colors.blueGrey),
    HabitModel(title: 'Enstrüman Pratiği', subtitle: 'Müzikle ruhunu besle.', icon: Icons.music_note, color: Colors.purpleAccent),
    HabitModel(title: 'Hızlı Okuma Egzersizi', subtitle: 'Göz kaslarını eğit.', icon: Icons.speed, color: Colors.blueAccent),
    HabitModel(title: 'Satranç/Strateji Oyun', subtitle: 'Zihnini keskinleştir.', icon: Icons.extension, color: Colors.deepPurple),
    HabitModel(title: 'Duruş Egzersizi', subtitle: 'Dik durmayı alışkanlık edin.', icon: Icons.accessibility_new, color: Colors.cyan),
    HabitModel(title: 'Hayır Deme Pratiği', subtitle: 'Sınırlarını koru.', icon: Icons.block, color: Colors.redAccent),
    HabitModel(title: 'Nefes Egzersizi', subtitle: 'Kutulu nefes tekniği.', icon: Icons.air, color: Colors.blueGrey),
    HabitModel(title: 'Yardım Etme', subtitle: 'Karşılıksız bir iyilik yap.', icon: Icons.volunteer_activism, color: Colors.pinkAccent),
    HabitModel(title: 'TED Konuşması İzleme', subtitle: 'Yeni bir vizyon edin.', icon: Icons.play_circle_fill, color: Colors.red),
    HabitModel(title: 'Bağışıklık Güçlendirme', subtitle: 'Vitamin ve takviye.', icon: Icons.health_and_safety, color: Colors.green),
    HabitModel(title: 'Görselleştirme', subtitle: 'Hedeflerine ulaştığını hayal et.', icon: Icons.visibility, color: Colors.amberAccent),
    HabitModel(title: 'Kodlama/Teknik Gelişim', subtitle: '1 algoritma çöz.', icon: Icons.code, color: Colors.blueGrey),
    HabitModel(title: 'Evi Düzenleme', subtitle: 'Yaşam alanını sadeleştir.', icon: Icons.home, color: Colors.brown),
    HabitModel(title: 'Hobi Gelişimi', subtitle: 'Sevdiğin şeye vakit ayır.', icon: Icons.palette, color: Colors.orangeAccent),
    HabitModel(title: 'Ağ Kurma (Networking)', subtitle: 'Bir profesyonelle tanış.', icon: Icons.groups, color: Colors.indigoAccent),
    HabitModel(title: 'Eleştirel Düşünme', subtitle: 'Bir konuyu derinlemesine analiz et.', icon: Icons.psychology_alt, color: Colors.blueGrey),
    HabitModel(title: 'Topluluk Önünde Konuşma', subtitle: 'Ayna karşısında pratik.', icon: Icons.record_voice_over, color: Colors.deepPurple),
    HabitModel(title: 'Zaman Yönetimi (Pomodoro)', subtitle: '4 seans tamamla.', icon: Icons.timer, color: Colors.redAccent),
    HabitModel(title: 'Uyku Hijyeni', subtitle: 'Aynı saatte uyu.', icon: Icons.bedtime, color: Colors.indigo),
    HabitModel(title: 'Olumlu Olumlamalar', subtitle: 'Kendine güvenini tazele.', icon: Icons.record_voice_over_outlined, color: Colors.amber),
    HabitModel(title: 'Stres Yönetimi', subtitle: 'Kaygıyı yönetmeyi öğren.', icon: Icons.spa, color: Colors.tealAccent),
    HabitModel(title: 'Hafıza Teknikleri', subtitle: 'Mnemonic çalış.', icon: Icons.memory, color: Colors.blue),
    HabitModel(title: 'Diksiyon Çalışması', subtitle: 'Anlaşılır konuş.', icon: Icons.mic, color: Colors.cyanAccent),
    HabitModel(title: 'Yaratıcı Yazarlık', subtitle: 'Bir hikaye kurgula.', icon: Icons.history_edu, color: Colors.brown),
    HabitModel(title: 'Matematik Egzersizi', subtitle: 'Zihinden hesap yap.', icon: Icons.calculate, color: Colors.blueGrey),
    HabitModel(title: 'Sanat Tarihi/Kültür', subtitle: 'Bir eser incele.', icon: Icons.museum, color: Colors.orange),
    HabitModel(title: 'Yemek Yapma', subtitle: 'Yeni bir tarif dene.', icon: Icons.soup_kitchen, color: Colors.orangeAccent),
    HabitModel(title: 'Bahçe İşleri/Bitki Bakımı', subtitle: 'Toprakla temas et.', icon: Icons.grass, color: Colors.green),
    HabitModel(title: 'Hızlı Yazma (Typing)', subtitle: 'WPM skorunu artır.', icon: Icons.keyboard, color: Colors.grey),
    HabitModel(title: 'Vurgulu Dinleme', subtitle: 'Birisini gerçekten dinle.', icon: Icons.hearing, color: Colors.blue),
    HabitModel(title: 'Münazara Pratiği', subtitle: 'Zıt görüşleri savun.', icon: Icons.gavel, color: Colors.red),
    HabitModel(title: 'Minimalizm', subtitle: 'Bugün bir eşyanı bağışla.', icon: Icons.remove_circle_outline, color: Colors.white),
    HabitModel(title: 'Astronomi/Uzay Araştırma', subtitle: 'Gökyüzünü tanı.', icon: Icons.rocket_launch, color: Colors.indigo),
    HabitModel(title: 'Satış/Pazarlama Pratiği', subtitle: 'İkna kabiliyetini artır.', icon: Icons.sell, color: Colors.amber),
    HabitModel(title: 'Felsefi Okuma', subtitle: 'Stoacılık/Varoluşçuluk.', icon: Icons.auto_stories, color: Colors.deepPurple),
    HabitModel(title: 'Göz Detoksu', subtitle: 'Uzaklara odaklan.', icon: Icons.remove_red_eye, color: Colors.teal),
  ];

  static Future<void> saveData(String habitTitle, bool isDone) async {
    final prefs = await SharedPreferences.getInstance();
    String dateKey = _getDateKey(DateTime.now());
    Map<String, bool> dailyHabits = await getDetailedDataForDate(DateTime.now());
    dailyHabits[habitTitle] = isDone;
    await prefs.setString('habits_$dateKey', jsonEncode(dailyHabits));

    int currentTotalBenefit = prefs.getInt('total_benefit') ?? 0;
    if (isDone) {
      currentTotalBenefit++;
      await addXP(20);
    } else {
      if (currentTotalBenefit > 0) currentTotalBenefit--;
    }
    await prefs.setInt('total_benefit', currentTotalBenefit);
    int score = dailyHabits.values.where((v) => v).length;
    await prefs.setInt('score_$dateKey', score);
  }

  static String _getDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  static Future<Map<String, bool>> getDetailedDataForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    String dateKey = _getDateKey(date);
    String? jsonStr = prefs.getString('habits_$dateKey');
    if (jsonStr != null) {
      Map<String, dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((key, value) => MapEntry(key, value as bool));
    }
    return {};
  }

  static Future<int> getScoreForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('score_${_getDateKey(date)}') ?? 0;
  }

  static Future<int> getTotalBenefit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('total_benefit') ?? 0;
  }

  static Future<Map<DateTime, int>> getAllScores() async {
    final prefs = await SharedPreferences.getInstance();
    Map<DateTime, int> scores = {};
    String? startDateStr = prefs.getString('start_date');
    if (startDateStr == null) return {};
    DateTime startDate = DateTime.parse(startDateStr);
    DateTime today = DateTime.now();
    for (int i = 0; i <= today.difference(startDate).inDays; i++) {
      DateTime date = startDate.add(Duration(days: i));
      int score = prefs.getInt('score_${_getDateKey(date)}') ?? 0;
      if (score > 0) scores[DateTime(date.year, date.month, date.day)] = score;
    }
    return scores;
  }

  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    DateTime checkDate = DateTime.now();
    int streak = 0;
    while (true) {
      int score = prefs.getInt('score_${_getDateKey(checkDate)}') ?? 0;
      if (score > 0) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        if (streak == 0 && checkDate.year == DateTime.now().year && 
            checkDate.month == DateTime.now().month && checkDate.day == DateTime.now().day) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }
    return streak;
  }

  static Future<int> getBestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    String? startDateStr = prefs.getString('start_date');
    if (startDateStr == null) return 0;
    DateTime startDate = DateTime.parse(startDateStr);
    DateTime today = DateTime.now();
    int bestStreak = 0;
    int currentStreak = 0;
    for (int i = 0; i <= today.difference(startDate).inDays; i++) {
      DateTime date = startDate.add(Duration(days: i));
      int score = prefs.getInt('score_${_getDateKey(date)}') ?? 0;
      if (score > 0) {
        currentStreak++;
        if (currentStreak > bestStreak) bestStreak = currentStreak;
      } else {
        currentStreak = 0;
      }
    }
    return bestStreak;
  }

  static Future<bool> getData(String key) async {
    final Map<String, bool> todayData = await getDetailedDataForDate(DateTime.now());
    return todayData[key] ?? false;
  }

  static Future<int> getXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_xp') ?? 0;
  }

  static Future<void> addXP(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    int currentXP = await getXP();
    await prefs.setInt('user_xp', currentXP + amount);
  }

  static int getLevel(int xp) {
    if (xp < 100) return 1;
    return (xp / 100).floor();
  }

  static TitleModel getCurrentTitle(int xp) {
    return allTitles.lastWhere((t) => xp >= t.minXP, orElse: () => allTitles.first);
  }

  static Future<void> setSelectedHabits(List<String> habits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selected_habits', habits);
  }

  static Future<List<String>> getSelectedHabits() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('selected_habits') ?? [];
  }

  // ÖZEL AKTİVİTELER İÇİN YENİ METODLAR
  static Future<void> setCustomHabits(List<HabitModel> habits) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = habits.map((h) => jsonEncode(h.toMap())).toList();
    await prefs.setStringList('custom_habits', jsonList);
  }

  static Future<List<HabitModel>> getCustomHabits() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = prefs.getStringList('custom_habits') ?? [];
    return jsonList.map((j) => HabitModel.fromMap(jsonDecode(j))).toList();
  }

  // API KEY YÖNETİMİ
  static Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', key);
  }

  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('gemini_api_key');
  }

  static Future<void> injectTestData() async {
    final prefs = await SharedPreferences.getInstance();
    DateTime today = DateTime.now();
    await prefs.setInt('total_benefit', 150);
    await prefs.setInt('user_xp', 1250);
    await prefs.setString('start_date', today.subtract(const Duration(days: 30)).toIso8601String());
  }
}
