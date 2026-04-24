import 'package:flutter/material.dart';
import 'main_app_screen.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class PusulaScreen extends StatefulWidget {
  const PusulaScreen({super.key});

  @override
  State<PusulaScreen> createState() => _PusulaScreenState();
}

class _PusulaScreenState extends State<PusulaScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedCoach;
  final TextEditingController _q1Controller = TextEditingController();
  final TextEditingController _q2Controller = TextEditingController();
  final TextEditingController _q3Controller = TextEditingController();
  bool _isStep3Valid = false;
  String? _selectedRoadmap;

  void _nextPage() {
    FocusScope.of(context).unfocus();
    _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  void _validateStep3() {
    setState(() {
      _isStep3Valid = _q1Controller.text.trim().isNotEmpty && _q2Controller.text.trim().isNotEmpty && _q3Controller.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF040D1F), Color(0xFF1A3A6E)]),
        ),
        child: SafeArea(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [_buildStep1Name(), _buildStep2Coach(), _buildStep3Questions(), _buildStep4Roadmap()],
          ),
        ),
      ),
    );
  }

  Widget _buildStep4Roadmap() {
    return _buildPageLayout(
      step: '4 / 4',
      title: 'Yol Haritası',
      description: 'Koçun seni analiz etti. Yolunu seç.',
      child: Column(
        children: [
          _buildOption('Agresif', 'Agresif', _selectedRoadmap, (v) => setState(() => _selectedRoadmap = v)),
          const SizedBox(height: 12),
          _buildOption('Dengeli', 'Dengeli', _selectedRoadmap, (v) => setState(() => _selectedRoadmap = v)),
        ],
      ),
      onPressed: _selectedRoadmap != null ? () async {
        final prefs = await SharedPreferences.getInstance();
        
        // 1. Onboarding tamamlandı
        await prefs.setBool('onboarding_completed', true);
        
        // 2. İsim kaydı
        String name = _nameController.text.trim().isEmpty ? 'Savaşçı' : _nameController.text.trim();
        await prefs.setString('user_name', name);

        // 2.5 Koç Kaydı
        await prefs.setString('selected_coach', _selectedCoach ?? 'Dominant');

        // Soru cevapları ve Yol haritası kaydı
        await prefs.setString('q1_answer', _q1Controller.text.trim());
        await prefs.setString('q2_answer', _q2Controller.text.trim());
        await prefs.setString('q3_answer', _q3Controller.text.trim());
        await prefs.setString('selected_roadmap', _selectedRoadmap!);

        // 3. KRİTİK: Başlangıç tarihini şu anki zaman olarak kaydediyoruz
        await prefs.setString('start_date', DateTime.now().toIso8601String());

        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const MainAppScreen()));
        }
      } : null,
      buttonText: 'Başla.',
    );
  }

  // --- Diğer UI metotları (Kısalık için aynı kalıyor) ---
  Widget _buildPageLayout({required String step, required String title, required String description, required Widget child, VoidCallback? onPressed, String buttonText = 'Devam et'}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 64.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PUSULA', style: TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 2.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Text(description, style: const TextStyle(fontSize: 32, height: 1.2)),
          const SizedBox(height: 64),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ADIM $step', style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                const SizedBox(height: 24),
                child,
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: onPressed != null ? Colors.white : Colors.white10,
                      foregroundColor: onPressed != null ? Colors.black : Colors.white24,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Name() { return _buildPageLayout(step: '1 / 4', title: 'Adın ne?', description: 'Kimse seni kurtarmaya gelmeyecek.\nBugün başla.', child: TextField(controller: _nameController, style: const TextStyle(color: Colors.white), decoration: _inputDeco('İsmini yaz...')), onPressed: _nextPage); }
  Widget _buildStep2Coach() { return _buildPageLayout(step: '2 / 4', title: 'Koçunu seç', description: 'Yolculuğunda kimin sesini duymak istersin?', child: Column(children: [_buildOption('Ilımlı & Destekleyici', 'Ilımlı', _selectedCoach, (v) => setState(() => _selectedCoach = v)), const SizedBox(height: 12), _buildOption('Dominant & Gerçekçi', 'Dominant', _selectedCoach, (v) => setState(() => _selectedCoach = v))]), onPressed: _selectedCoach != null ? _nextPage : null); }
  Widget _buildStep3Questions() { return _buildPageLayout(step: '3 / 4', title: 'Kendinle Yüzleş', description: 'Dürüst ol. Kendine bile yalan söyleme.', child: Column(children: [_buildSmallField('Kimsin?', _q1Controller), const SizedBox(height: 12), _buildSmallField('Kim olmak istiyorsun?', _q2Controller), const SizedBox(height: 12), _buildSmallField('Hedeflerin neler?', _q3Controller)]), onPressed: _isStep3Valid ? _nextPage : null); }
  InputDecoration _inputDeco(String hint) => InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)), filled: true, fillColor: Colors.black.withValues(alpha: 0.2), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none));
  Widget _buildSmallField(String label, TextEditingController controller) { return TextField(controller: controller, onChanged: (_) => _validateStep3(), style: const TextStyle(color: Colors.white, fontSize: 14), decoration: _inputDeco(label)); }
  Widget _buildOption(String title, String val, String? group, Function(String) onSelect) { bool sel = val == group; return GestureDetector(onTap: () => onSelect(val), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: sel ? Colors.white.withValues(alpha: 0.1) : Colors.transparent, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? Colors.white : Colors.white24)), child: Row(children: [Icon(sel ? Icons.check_circle : Icons.circle_outlined, color: Colors.white), const SizedBox(width: 12), Text(title, style: const TextStyle(color: Colors.white))]))); }
}