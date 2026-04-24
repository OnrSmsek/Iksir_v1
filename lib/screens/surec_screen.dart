import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class SurecScreen extends StatefulWidget {
  const SurecScreen({super.key});

  @override
  State<SurecScreen> createState() => _SurecScreenState();
}

class _SurecScreenState extends State<SurecScreen> {
  int _totalBenefit = 0;
  double _efficiencyValue = 0.0;
  int _daysCount = 1;
  int _currentStreak = 0;
  int _bestStreak = 0;
  Map<DateTime, int> _heatMapData = {};
  List<int> _weeklyScores = [0, 0, 0, 0, 0, 0, 0];
  final List<String> _weekDays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    
    int benefit = await StorageService.getTotalBenefit();
    int currentStreak = await StorageService.getCurrentStreak();
    int bestStreak = await StorageService.getBestStreak();
    Map<DateTime, int> heatMapData = await StorageService.getAllScores();
    
    String? startDateStr = prefs.getString('start_date');
    if (startDateStr != null) {
      DateTime startDate = DateTime.parse(startDateStr);
      _daysCount = DateTime.now().difference(startDate).inDays + 1;
    }

    // Seçili aktivite sayısına göre verimlilik (Günde kaç aktivite hedeflenmişse ona bölmeliyiz)
    List<String> selected = await StorageService.getSelectedHabits();
    int targetPerDay = selected.isEmpty ? 5 : selected.length;
    
    double calcEfficiency = (benefit / (_daysCount * targetPerDay));
    if (calcEfficiency > 1.0) calcEfficiency = 1.0;

    List<int> scores = [];
    DateTime today = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      DateTime date = today.subtract(Duration(days: i));
      int score = await StorageService.getScoreForDate(date);
      scores.add(score);
    }

    if (mounted) {
      setState(() {
        _totalBenefit = benefit;
        _efficiencyValue = calcEfficiency;
        _currentStreak = currentStreak;
        _bestStreak = bestStreak;
        _heatMapData = heatMapData;
        _weeklyScores = scores;
      });
    }
  }

  void _showDailyDetailsSheet(BuildContext context, DateTime date) async {
    Map<String, bool> details = await StorageService.getDetailedDataForDate(date);
    String formattedDate = DateFormat('d MMMM yyyy', 'tr_TR').format(date);
    
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A192F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate,
                style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'GÜNLÜK KARNE',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              if (details.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('Bu güne ait veri bulunamadı.', style: TextStyle(color: Colors.white38)),
                  ),
                )
              else
                ...details.entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: entry.value ? Colors.greenAccent.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          entry.value ? Icons.check_circle : Icons.cancel,
                          color: entry.value ? Colors.greenAccent : Colors.redAccent,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          entry.key,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          entry.value ? '+1 Fayda' : '0 Fayda',
                          style: TextStyle(
                            color: entry.value ? Colors.greenAccent : Colors.white24,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String _getDynamicAdvice() {
    if (_efficiencyValue < 0.3) return "Bugün küçük bir adım atmaya ne dersin? Her şey bir adımla başlar.";
    if (_efficiencyValue < 0.6) return "Güzel gidiyorsun, disiplinini korumaya odaklan!";
    if (_currentStreak > 3) return "$_currentStreak gündür harikasın! Zinciri kırma.";
    return "Mükemmel performans! Kendi sınırlarını zorlamaya devam et.";
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text('SÜREÇ ANALİZİ', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 16)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.bug_report, color: Colors.white24),
              onPressed: () async {
                await StorageService.injectTestData();
                _loadStats();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('30 Günlük Detaylı Test Verisi Gömdü!'))
                  );
                }
              },
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async => _loadStats(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dinamik Tavsiye Bannerı
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.blueAccent.withOpacity(0.1), Colors.cyanAccent.withOpacity(0.05)]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getDynamicAdvice(),
                          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Büyük Verimlilik Göstergesi
                _buildCircularEfficiency(),
                const SizedBox(height: 24),

                // Ana İstatistik Kartları (Yan Yana)
                Row(
                  children: [
                    Expanded(child: _buildMiniStatCard('Toplam Fayda', '$_totalBenefit', Icons.trending_up, Colors.greenAccent)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildMiniStatCard('Gün Sayısı', '$_daysCount', Icons.calendar_today, Colors.orangeAccent)),
                  ],
                ),
                const SizedBox(height: 32),

                // Seri (Streak) Kartları
                Row(
                  children: [
                    _buildStreakCard('Mevcut Seri', '$_currentStreak Gün', Icons.local_fire_department, Colors.orange),
                    const SizedBox(width: 16),
                    _buildStreakCard('En İyi Seri', '$_bestStreak Gün', Icons.emoji_events, Colors.amber),
                  ],
                ),
                const SizedBox(height: 32),

                const Text('HAFTALIK DİSİPLİN SKORU', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 20),
                _buildWeeklyChart(),

                const SizedBox(height: 32),
                const Text('DİSİPLİN ISI HARİTASI', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 16),
                _buildHeatMap(),

                const SizedBox(height: 32),
                const Text('AYLIK TAKVİM', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 16),
                _buildCalendar(),

                const SizedBox(height: 32),
                const Text('KAZANILAN UNVANLAR', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 16),
                _buildBadgeItem('Demir İrade', '7 gün üst üste tüm görevleri tamamladın.', Icons.shield_moon, Colors.blueAccent, _bestStreak >= 7),
                _buildBadgeItem('Şafak Savaşçısı', 'Alışkanlıklarını düzenli takip ediyorsun.', Icons.wb_twilight, Colors.orangeAccent, _totalBenefit >= 10),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularEfficiency() {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: _efficiencyValue,
              strokeWidth: 12,
              backgroundColor: Colors.white10,
              color: Colors.cyanAccent,
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${(_efficiencyValue * 100).toStringAsFixed(0)}%",
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text("GENEL VERİMLİLİK", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 5,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF0A192F),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  'Skor: ${rod.toY.toInt()}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < 7) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(_weekDays[index], style: const TextStyle(color: Colors.white38, fontSize: 10)),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: List.generate(7, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: _weeklyScores[index].toDouble(),
                  gradient: const LinearGradient(
                    colors: [Colors.cyanAccent, Colors.blueAccent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeatMap() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: HeatMap(
        datasets: _heatMapData,
        colorMode: ColorMode.color,
        defaultColor: Colors.white.withOpacity(0.05),
        textColor: Colors.white38,
        showColorTip: false,
        showText: false,
        scrollable: true,
        size: 20,
        colorsets: const {
          1: Color(0xFF1E3A5F),
          2: Color(0xFF2B5A8F),
          3: Color(0xFF3D7ABF),
          4: Color(0xFF4F9BEF),
          5: Colors.cyanAccent,
        },
        onClick: (value) {
          _showDailyDetailsSheet(context, value);
        },
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TableCalendar(
        locale: 'tr_TR',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
        ),
        calendarStyle: CalendarStyle(
          defaultTextStyle: const TextStyle(color: Colors.white70),
          weekendTextStyle: const TextStyle(color: Colors.white38),
          todayDecoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
          selectedDecoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
          markerDecoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
          markersMaxCount: 1,
        ),
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _showDailyDetailsSheet(context, selectedDay);
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
      ),
    );
  }

  Widget _buildMiniStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(String title, String desc, IconData icon, Color color, bool isEarned) {
    return Opacity(
      opacity: isEarned ? 1.0 : 0.3,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: isEarned ? Border.all(color: color.withOpacity(0.3)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isEarned ? color : Colors.white24, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: isEarned ? Colors.white : Colors.white24, fontWeight: FontWeight.bold)),
                  Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
            if (isEarned) Icon(Icons.verified, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
