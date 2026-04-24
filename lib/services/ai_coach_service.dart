import 'package:google_generative_ai/google_generative_ai.dart';
import 'storage_service.dart';

class AICoachService {
  // ANAHTAR KODDAN KALDIRILDI. 
  // LÜTFEN UYGULAMA İÇİNDEKİ PROFİL SAYFASINDAN ANAHTARINIZI GİRİN.
  static const String _fallbackKey = 'YOUR_GEMINI_API_KEY';

  // Aktif anahtarı getir (Hafıza öncelikli)
  static Future<String?> _getEffectiveKey() async {
    String? storedKey = await StorageService.getApiKey();
    if (storedKey != null && storedKey.isNotEmpty && storedKey != 'YOUR_GEMINI_API_KEY') {
      return storedKey;
    }
    return null;
  }

  static Future<ChatSession?> startChatSession({
    required String userName,
    required String coachType,
    required int level,
    required String title,
  }) async {
    final apiKey = await _getEffectiveKey();
    if (apiKey == null) return null;

    final model = GenerativeModel(
      model: 'gemini-1.5-flash', 
      apiKey: apiKey,
      systemInstruction: Content.system(
        "Sen 'İKSİR' uygulamasının AI Koçusun. İsmim $userName, Level $level, Rütbem $title. "
        "Kişiliğin: $coachType. Benimle bu kimliğe bürünerek konuş. Kısa, etkili ve disiplin odaklı ol."
      ),
    );
    
    return model.startChat(history: [
      Content.model([TextPart("Selam savaşçı. Ben senin $coachType koçunum. Bugün disiplin yolculuğunda sana nasıl rehberlik edebilirim?")])
    ]);
  }

  static Future<String> getCoachResponse({
    required String userName,
    required String coachType,
    required int level,
    required String title,
    required List<String> completedHabits,
    required List<String> pendingHabits,
  }) async {
    final apiKey = await _getEffectiveKey();
    if (apiKey == null) return "AI Koçu aktif etmek için lütfen Profil sayfasından API Anahtarınızı girin.";

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final prompt = "İsmim $userName, Koç Tipim $coachType. Bugün şunları yaptım: ${completedHabits.join(', ')}. "
          "Şunlar kaldı: ${pendingHabits.join(', ')}. Bana koç karakterine uygun, 2 cümleyi geçmeyen bir motivasyon notu yaz.";
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "Disipline devam.";
    } catch (e) {
      return "Bağlantı hatası.";
    }
  }
}
