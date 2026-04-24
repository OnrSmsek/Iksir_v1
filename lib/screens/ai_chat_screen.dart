import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../services/ai_coach_service.dart';

class AIChatScreen extends StatefulWidget {
  final String userName;
  final String coachType;
  final int level;
  final String title;

  const AIChatScreen({
    super.key,
    required this.userName,
    required this.coachType,
    required this.level,
    required this.title,
  });

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  late ChatSession _chat;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _setupChat();
  }

  Future<void> _setupChat() async {
    final session = await AICoachService.startChatSession(
      userName: widget.userName,
      coachType: widget.coachType,
      level: widget.level,
      title: widget.title,
    );
    
    if (session == null) {
      setState(() {
        _messages.add({
          'role': 'model',
          'text': "AI Koç şu an uykuda. Onu canlandırmak için lütfen Profil sayfasından geçerli bir API Anahtarı girin."
        });
        _isInit = false;
      });
      return;
    }

    _chat = session;
    setState(() {
      _messages.add({
        'role': 'model',
        'text': "Merhaba ${widget.userName}, ben senin ${widget.coachType} koçunum. Bugün disiplin yolculuğunda sana nasıl rehberlik edebilirim?"
      });
      _isInit = false;
    });
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty || _isLoading) return;

    final userText = _controller.text;
    setState(() {
      _messages.add({'role': 'user', 'text': userText});
      _isLoading = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final response = await _chat.sendMessage(Content.text(userText));
      setState(() {
        _messages.add({'role': 'model', 'text': response.text ?? "Anlayamadım savaşçı."});
        _isLoading = false;
      });
    } catch (e) {
      String errorMsg = "Bağlantı hatası.";
      if (e.toString().contains('API_KEY_INVALID')) {
        errorMsg = "Geçersiz API Anahtarı. Lütfen Profil sayfasından anahtarınızı kontrol edin.";
      } else if (e.toString().contains('User location is not supported')) {
        errorMsg = "Bulunduğunuz bölge henüz Gemini API tarafından desteklenmiyor (VPN gerekebilir).";
      } else {
        errorMsg = "Hata: ${e.toString()}";
      }
      
      setState(() {
        _messages.add({'role': 'model', 'text': errorMsg});
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
          title: Column(
            children: [
              const Text('AI MENTOR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(widget.coachType.toUpperCase(), style: const TextStyle(color: Colors.amber, fontSize: 10, letterSpacing: 2)),
            ],
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isInit 
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg['role'] == 'user';
                      return _buildMessageBubble(msg['text']!, isUser);
                    },
                  ),
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Koçun yazıyor...', style: TextStyle(color: Colors.white24, fontSize: 10)),
                  ),
                _buildInputArea(),
              ],
            ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.amber.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
          border: Border.all(color: isUser ? Colors.amber.withOpacity(0.2) : Colors.white.withOpacity(0.05)),
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.amberAccent : Colors.white.withOpacity(0.9), fontSize: 14, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF040D1F),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Mesajını yaz...',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.03),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
