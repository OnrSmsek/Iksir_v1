import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/ai_coach_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_screen.dart';
import 'ai_chat_screen.dart';

class ZeroScreen extends StatefulWidget {
  const ZeroScreen({super.key});
  @override
  State<ZeroScreen> createState() => _ZeroScreenState();
}

class _ZeroScreenState extends State<ZeroScreen> {
  String _userName = 'Savaşçı';
  int _daysCount = 0;
  String _aiCoachNote = "Analiz ediliyor...";
  List<HabitModel> _displayHabits = [];
  Map<String, bool> _habitStatus = {};
  bool _isAiLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  void _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedName = prefs.getString('user_name');
    String coachType = prefs.getString('selected_coach') ?? 'Dominant';
    int xp = await StorageService.getXP();
    int level = StorageService.getLevel(xp);
    String title = StorageService.getCurrentTitle(xp).name;
    
    String? startDateStr = prefs.getString('start_date');
    if (startDateStr != null) {
      DateTime startDate = DateTime.parse(startDateStr);
      _daysCount = DateTime.now().difference(startDate).inDays + 1;
    } else {
      _daysCount = 1;
    }

    List<String> selectedTitles = await StorageService.getSelectedHabits();
    List<HabitModel> fromPool = StorageService.habitPool.where((h) => selectedTitles.contains(h.title)).toList();
    List<HabitModel> customHabits = await StorageService.getCustomHabits();
    List<HabitModel> all = [...fromPool, ...customHabits];

    if (all.isEmpty) {
      all = StorageService.habitPool.take(5).toList();
    }

    Map<String, bool> status = {};
    List<String> completed = [];
    List<String> pending = [];

    for (var h in all) {
      bool isDone = await StorageService.getData(h.title);
      status[h.title] = isDone;
      if (isDone) completed.add(h.title); else pending.add(h.title);
    }

    if (mounted) {
      setState(() {
        if (savedName != null) _userName = savedName;
        _displayHabits = all;
        _habitStatus = status;
      });
    }

    String aiResponse = await AICoachService.getCoachResponse(
      userName: _userName,
      coachType: coachType,
      level: level,
      title: title,
      completedHabits: completed,
      pendingHabits: pending,
    );

    if (mounted) {
      setState(() {
        _aiCoachNote = aiResponse;
        _isAiLoading = false;
      });
    }
  }

  void _openAiChat() async {
    final prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('user_name') ?? 'Savaşçı';
    String coach = prefs.getString('selected_coach') ?? 'Dominant';
    int xp = await StorageService.getXP();
    int level = StorageService.getLevel(xp);
    String title = StorageService.getCurrentTitle(xp).name;

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIChatScreen(
          userName: name,
          coachType: coach,
          level: level,
          title: title,
        ),
      ),
    );
  }

  void _openHabitSelection() async {
    List<String> currentPoolSelected = (await StorageService.getSelectedHabits());
    List<HabitModel> currentCustom = await StorageService.getCustomHabits();
    final TextEditingController _customTitleController = TextEditingController();
    IconData _selectedIcon = Icons.star;
    final List<IconData> _iconOptions = [Icons.star, Icons.rocket_launch, Icons.bolt, Icons.psychology, Icons.fitness_center, Icons.menu_book, Icons.water_drop, Icons.wb_sunny, Icons.code, Icons.savings, Icons.favorite, Icons.spa];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A192F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('AKTİVİTELERİNİ YÖNET', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        const Align(alignment: Alignment.centerLeft, child: Text('YENİ ÖZEL HEDEF', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold))),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle), child: Icon(_selectedIcon, color: Colors.amber, size: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _customTitleController,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Hedef başlığı...',
                                  hintStyle: const TextStyle(color: Colors.white24),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.05),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Colors.greenAccent),
                              onPressed: () {
                                if (_customTitleController.text.isNotEmpty) {
                                  setModalState(() {
                                    currentCustom.add(HabitModel(title: _customTitleController.text, subtitle: 'Özel hedefin.', icon: _selectedIcon, color: Colors.amberAccent, isCustom: true));
                                    _customTitleController.clear();
                                    _selectedIcon = Icons.star;
                                  });
                                }
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _iconOptions.length,
                            itemBuilder: (context, i) => GestureDetector(
                              onTap: () => setModalState(() => _selectedIcon = _iconOptions[i]),
                              child: Padding(padding: const EdgeInsets.only(right: 12), child: Icon(_iconOptions[i], color: _selectedIcon == _iconOptions[i] ? Colors.amber : Colors.white24, size: 20)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      children: [
                        ...currentCustom.map((h) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(h.icon, color: h.color),
                          title: Text(h.title, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          trailing: IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20), onPressed: () => setModalState(() => currentCustom.remove(h))),
                        )),
                        const Divider(color: Colors.white10, height: 32),
                        ...StorageService.habitPool.map((h) {
                          final isSelected = currentPoolSelected.contains(h.title);
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(h.title, style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontSize: 14)),
                            secondary: Icon(h.icon, color: isSelected ? h.color : Colors.white10),
                            value: isSelected,
                            activeColor: h.color,
                            onChanged: (val) {
                              setModalState(() { if (val!) currentPoolSelected.add(h.title); else currentPoolSelected.remove(h.title); });
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () async {
                        await StorageService.setSelectedHabits(currentPoolSelected);
                        await StorageService.setCustomHabits(currentCustom);
                        Navigator.pop(context);
                        _loadAllData();
                      },
                      child: const Text('KAYDET', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF040D1F), Color(0xFF0A192F)]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildAiCoachNote(),
                const SizedBox(height: 32),
                _buildStreakCounter(),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('GÜNLÜK AKTİVİTELER', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.tune, color: Colors.white38, size: 20), onPressed: _openHabitSelection),
                  ],
                ),
                const SizedBox(height: 16),
                if (_displayHabits.isEmpty)
                  const Center(child: Text('Aktivite seçilmedi.', style: TextStyle(color: Colors.white24)))
                else
                  ..._displayHabits.map((h) => _buildHabitCard(h)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Merhaba,', style: TextStyle(color: Colors.white70, fontSize: 16)),
        Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      ]),
      CircleAvatar(
        backgroundColor: Colors.white.withOpacity(0.1),
        child: IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
          },
        ),
      ),
    ]);
  }

  Widget _buildAiCoachNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
              const SizedBox(width: 10),
              Text(
                'AI KOÇUN NOTU',
                style: TextStyle(color: Colors.amber.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1),
              ),
              const Spacer(),
              if (_isAiLoading)
                const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber))
              else
                GestureDetector(
                  onTap: _openAiChat,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.withOpacity(0.3))),
                    child: const Text('SOHBET ET', style: TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _aiCoachNote,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCounter() {
    return Center(
      child: Column(
        children: [
          const Text('SÜREÇTE', style: TextStyle(color: Colors.white54, letterSpacing: 4, fontSize: 12)),
          Text('$_daysCount', style: const TextStyle(color: Colors.white, fontSize: 100, fontWeight: FontWeight.w900, height: 1.1)),
          const Text('GÜN', style: TextStyle(color: Colors.white54, letterSpacing: 4, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildHabitCard(HabitModel habit) {
    bool isDone = _habitStatus[habit.title] ?? false;
    return GestureDetector(
      onTap: () async {
        setState(() { _habitStatus[habit.title] = !isDone; });
        await StorageService.saveData(habit.title, !isDone);
        _loadAllData();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDone ? habit.color.withOpacity(0.12) : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDone ? habit.color.withOpacity(0.4) : Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: habit.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(habit.icon, color: habit.color)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(habit.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: isDone ? TextDecoration.lineThrough : null)),
              Text(habit.subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ])),
            Icon(isDone ? Icons.check_circle : Icons.circle_outlined, color: isDone ? habit.color : Colors.white24),
          ],
        ),
      ),
    );
  }
}
