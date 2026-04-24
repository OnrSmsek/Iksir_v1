import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Savaşçı';
  int _xp = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    int xp = await StorageService.getXP();
    if (mounted) {
      setState(() {
        _name = prefs.getString('user_name') ?? 'Savaşçı';
        _xp = xp;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF040D1F),
        body: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
      );
    }

    final currentTitle = StorageService.getCurrentTitle(_xp);
    final currentLevel = StorageService.getLevel(_xp);
    
    // Sonsuz level için bar hesaplama (her 100 XP bir level)
    final currentLevelXP = currentLevel * 100;
    final nextLevelXP = (currentLevel + 1) * 100;
    final progress = ((_xp - currentLevelXP) / 100).clamp(0.0, 1.0);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF040D1F), Color(0xFF0A192F)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('GELİŞİM VE RÜTBELER', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 16)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildUserHeader(currentTitle, currentLevel, progress, nextLevelXP),
              const SizedBox(height: 40),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('TÜM ÜNVANLAR', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
              const SizedBox(height: 20),
              ...StorageService.allTitles.map((t) => _buildTitleItem(t)),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(TitleModel title, int level, double progress, int nextXP) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [title.color.withOpacity(0.2), Colors.white.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: title.color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: title.color, width: 3),
                  boxShadow: [BoxShadow(color: title.color.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)],
                ),
              ),
              const CircleAvatar(radius: 55, backgroundColor: Colors.white10, child: Icon(Icons.person, size: 60, color: Colors.white)),
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: title.color, borderRadius: BorderRadius.circular(20)),
                  child: Text('LEVEL $level', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(_name, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title.name.toUpperCase(), style: TextStyle(color: title.color, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 3)),
          const SizedBox(height: 32),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TECRÜBE PUANI', style: TextStyle(color: title.color.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold)),
                  Text('$_xp / $nextXP XP', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(title.color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleItem(TitleModel t) {
    bool isEarned = _xp >= t.minXP;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isEarned ? t.color.withOpacity(0.08) : Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isEarned ? t.color.withOpacity(0.2) : Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: isEarned ? t.color.withOpacity(0.1) : Colors.white10, shape: BoxShape.circle),
            child: Icon(t.icon, color: isEarned ? t.color : Colors.white24, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.name, style: TextStyle(color: isEarned ? Colors.white : Colors.white24, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${t.minXP} XP Gerekli', style: const TextStyle(color: Colors.white12, fontSize: 11)),
              ],
            ),
          ),
          if (isEarned) Icon(Icons.verified, color: t.color, size: 18),
        ],
      ),
    );
  }
}
