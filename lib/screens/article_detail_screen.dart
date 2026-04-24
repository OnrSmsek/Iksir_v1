import 'package:flutter/material.dart';
import 'atlas_screen.dart';
import '../services/storage_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final List<Article> articles;
  final int initialIndex;

  const ArticleDetailScreen({
    super.key,
    required this.articles,
    required this.initialIndex,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late int _currentPageIndex;
  late AnimationController _pullController;
  double _pullOffset = 0.0;
  bool _isTriggered = false;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _pullController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  void _onPullCompleted() async {
    // XP Ekle
    await StorageService.addXP(15);
    
    if (_currentPageIndex < widget.articles.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
      setState(() {
        _pullOffset = 0;
        _isTriggered = false;
        _pullController.reset();
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pullController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040D1F),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(), // Manuel kontrol edeceğiz
            itemCount: widget.articles.length,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final article = widget.articles[index];
              return _buildArticleContent(article);
            },
          ),
          
          // Pull to Next Indicator
          if (_pullOffset > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildPullIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildArticleContent(Article article) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          if (notification.metrics.pixels >= notification.metrics.maxScrollExtent) {
            double diff = notification.metrics.pixels - notification.metrics.maxScrollExtent;
            setState(() {
              _pullOffset = diff.clamp(0.0, 160.0);
            });

            if (_pullOffset > 120 && !_isTriggered) {
              _isTriggered = true;
              _pullController.forward().then((value) {
                if (_isTriggered) _onPullCompleted();
              });
            } else if (_pullOffset < 90 && _isTriggered) {
              _isTriggered = false;
              _pullController.reverse();
            }
          } else {
            if (_pullOffset != 0) {
              setState(() => _pullOffset = 0);
              _pullController.reverse();
              _isTriggered = false;
            }
          }
        }
        return false;
      },
      child: Transform.translate(
        offset: Offset(0, -_pullOffset * 0.6),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: const Color(0xFF040D1F),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [article.color.withOpacity(0.3), const Color(0xFF040D1F)],
                    ),
                  ),
                  child: Center(
                    child: Icon(article.icon, size: 80, color: article.color.withOpacity(0.5)),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: article.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        article.category,
                        style: TextStyle(color: article.color, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      article.title,
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 24),
                    Text(
                      article.content,
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 18, height: 1.6),
                    ),
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPullIndicator() {
    final article = widget.articles[_currentPageIndex];
    final bool isLast = _currentPageIndex == widget.articles.length - 1;

    return Opacity(
      opacity: (_pullOffset / 120).clamp(0.0, 1.0),
      child: Container(
        height: _pullOffset,
        decoration: BoxDecoration(
          color: article.color.withOpacity(0.1),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: article.color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _pullController.value,
                  strokeWidth: 4,
                  color: article.color,
                  backgroundColor: Colors.white10,
                  strokeCap: StrokeCap.round,
                ),
                Icon(
                  isLast ? Icons.check : Icons.keyboard_double_arrow_up,
                  color: article.color,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isLast ? "BİTİRMEK İÇİN TUT" : "SIRADAKİ: ${widget.articles[_currentPageIndex + 1].title.toUpperCase()}",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: article.color,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
