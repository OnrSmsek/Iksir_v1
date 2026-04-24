import 'package:flutter/material.dart';
import 'article_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Article {
  final String title;
  final String category;
  final Color color;
  final IconData icon;
  final String content;

  Article({required this.title, required this.category, required this.color, required this.icon, required this.content});
}

class AtlasScreen extends StatefulWidget {
  const AtlasScreen({super.key});

  @override
  State<AtlasScreen> createState() => _AtlasScreenState();
}

class _AtlasScreenState extends State<AtlasScreen> {
  List<Article> _displayArticles = [];
  bool _isLoading = true;

  static final Map<String, List<Article>> thematicPools = {
    'YAŞAM': [
      Article(
        title: 'Hayatın Ritmi',
        category: 'YAŞAM',
        color: Colors.blueAccent,
        icon: Icons.eco,
        content: "Hayat bir varış noktası değil, bir yolculuktur. Her gün uyandığında, sadece hayatta olduğun için minnettar kalmak, zihnini bolluk bilincine açar. Modern dünyanın hızı bazen bizi asıl değerli olan anlardan koparabilir. Ancak yavaşlamayı bildiğinde, doğanın ve kendi varlığının ritmini duymaya başlarsın.",
      ),
      Article(
        title: 'Anı Yaşama Sanatı',
        category: 'YAŞAM',
        color: Colors.blueAccent,
        icon: Icons.auto_awesome,
        content: "Geçmişin pişmanlıkları ve geleceğin kaygıları arasında sıkışıp kalmak, bugünün hediyesini kaybetmektir. Gerçek huzur, sadece şu anın içinde gizlidir. Her yaptığın işi veya attığın adımı tam bir farkındalıkla yapmaya başladığında, hayatın ne kadar zengin olduğunu fark edersin.",
      ),
    ],
    'ZİHİN': [
      Article(
        title: 'Zihin Bir Bahçedir',
        category: 'ZİHİN',
        color: Colors.purpleAccent,
        icon: Icons.psychology,
        content: "Zihnine ektiğin her düşünce bir tohumdur. Eğer onu şüphe ve korkuyla beslersen, yabani otlar her yanını sarar. Ancak disiplin, inanç ve olumlama ile beslersen, orası bir cennet bahçesine dönüşür. Güçlü bir zihin, dış dünyadaki hiçbir fırtınadan sarsılmaz.",
      ),
      Article(
        title: 'Odaklanmanın Gücü',
        category: 'ZİHİN',
        color: Colors.purpleAccent,
        icon: Icons.center_focus_strong,
        content: "Dikkatini tek bir noktaya topladığında, imkansız görünen engelleri bile aşabilirsin. Dağınık bir zihin enerjini tüketirken, odaklanmış bir zihin lazer gibi keskindir. Zihnini susturmayı öğrenen, dünyayı yönetir.",
      ),
    ],
    'BEDEN': [
      Article(
        title: 'Hareket Hayattır',
        category: 'BEDEN',
        color: Colors.orangeAccent,
        icon: Icons.fitness_center,
        content: "Vücudun senin tek gerçek evindir. Ona ne kadar iyi bakarsan, zihnin de o kadar berrak olur. Hareket etmek, sadece fiziksel bir aktivite değil, aynı zamanda ruhun tazelenmesidir. Fiziksel dayanıklılığın arttıkça, hayatın zorluklarına karşı da daha dirençli hale gelirsin.",
      ),
      Article(
        title: 'Beslenme Bilinci',
        category: 'BEDEN',
        color: Colors.orangeAccent,
        icon: Icons.restaurant,
        content: "Yediklerin sadece karnını doyurmaz, aynı zamanda hücrelerini ve enerjini inşa eder. Canlı ve doğal gıdalarla beslenmek, yaşam enerjini yükseltir. Kendi bedenine saygı duyan, yaşamın kendisine de saygı duyar.",
      ),
    ],
    'SÜREÇ': [
      Article(
        title: 'Küçük Adımlar, Büyük Zaferler',
        category: 'SÜREÇ',
        color: Colors.greenAccent,
        icon: Icons.auto_graph,
        content: "Büyük değişimler, her gün atılan küçük ve istikrarlı adımlarla gerçekleşir. Hedefine giden yolda karşılaştığın zorluklar seni yıldırmasın, onlar seni güçlendiren antrenmanlardır. Sürece güven.",
      ),
      Article(
        title: 'Disiplin ve Rutin',
        category: 'SÜREÇ',
        color: Colors.greenAccent,
        icon: Icons.repeat,
        content: "Disiplin, canının istemediği anlarda bile yapman gerekeni yapma gücüdür. Rutinlerin senin güvenli limanındır; onlar sayesinde karar yorgunluğundan kurtulur ve enerjini asıl önemli olana harcarsın. Zinciri kırma.",
      ),
    ],
    'KİMLİK': [
      Article(
        title: 'Yeni Bir Sen İnşa Etmek',
        category: 'KİMLİK',
        color: Colors.amberAccent,
        icon: Icons.fingerprint,
        content: "Geçmişin kim olduğun değil, sadece nereden geldiğindir. Her an, yeni bir seçim yaparak kimliğini yeniden tanımlayabilirsin. Bugün bir kazanan gibi davranırsan, yavaş yavaş bir kazanan olursun.",
      ),
      Article(
        title: 'Özsaygı ve Duruş',
        category: 'KİMLİK',
        color: Colors.amberAccent,
        icon: Icons.verified_user,
        content: "Gerçek özsaygı, kimse bakmadığında bile kendine verdiğin sözleri tutmandır. Kendi değerini dış onaylara bağlamadığında, sarsılmaz bir karaktere kavuşursun. Kendi standartlarını belirle ve onlardan asla ödün verme.",
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _setupThematicArticles();
  }

  Future<void> _setupThematicArticles() async {
    final prefs = await SharedPreferences.getInstance();
    int now = DateTime.now().millisecondsSinceEpoch;
    int intervalIndex = (now ~/ (15 * 60 * 1000));

    List<Article> selected = [];
    thematicPools.forEach((category, pool) {
      int index = intervalIndex % pool.length;
      selected.add(pool[index]);
    });

    if (mounted) {
      setState(() {
        _displayArticles = selected;
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
          title: const Text('ATLAS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 16)),
          centerTitle: true,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(24.0),
          itemCount: _displayArticles.length,
          itemBuilder: (context, index) {
            final article = _displayArticles[index];
            return _buildThematicCard(context, article);
          },
        ),
      ),
    );
  }

  Widget _buildThematicCard(BuildContext context, Article article) {
    return GestureDetector(
      onTap: () {
        List<Article> categoryPool = thematicPools[article.category]!;
        int initialIndexInPool = categoryPool.indexOf(article);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(
              articles: categoryPool,
              initialIndex: initialIndexInPool,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [article.color.withOpacity(0.1), article.color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: article.color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: article.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(article.icon, color: article.color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.category,
                    style: TextStyle(color: article.color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.title,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.content.length > 45 ? article.content.substring(0, 45) + '...' : article.content,
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: article.color.withOpacity(0.3), size: 16),
          ],
        ),
      ),
    );
  }
}
