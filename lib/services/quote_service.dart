import 'dart:math';

class QuoteService {
  static final List<String> ilimliQuotes = [
    "Bugün kendin için harika bir şey yaptın.",
    "Her küçük adım, büyük bir değişimin habercisidir.",
    "Hata yapman sorun değil, öğrenmen önemli.",
    "Kendine zaman tanı, çiçekler bile hemen açmaz.",
    "Zihnin senin bahçen, ona sevgiyle bak.",
    "Dinlenmek de disiplinin bir parçasıdır.",
    "Gülümse, bugün dünden daha tecrübelisin.",
    "Seninle gurur duyuyorum.",
    "Yolculuğun tadını çıkar, varış noktası zaten gelecek.",
    "İçindeki ışığın sönmesine izin verme.",
    // ... (200'e tamamlanacak şekilde listeler genişletilebilir)
    "Her gün yeni bir başlangıçtır.",
    "Kendine nazik davranmayı unutma.",
    "Bugün yaptığın her şey gelecekteki sana bir hediyedir.",
    "Zorluklar seni kırmak için değil, güçlendirmek içindir.",
    "Başarı, her gün tekrarlanan küçük çabaların toplamıdır."
  ];

  static final List<String> dominantQuotes = [
    "Disiplin motivasyonun bittiği yerde başlar. Kalk!",
    "Acı geçicidir, pişmanlık kalıcı.",
    "Bahanelerin seni sadece yerinde saydırır.",
    "Zayıflık bir seçimdir, güç ise bir alışkanlık.",
    "Bugün terlemezsen yarın gözyaşı dökersin.",
    "Düşmanların senin pes etmeni bekliyor, onları hayal kırıklığına uğrat.",
    "Ayna sana ne diyor? Gerçeği gör ve harekete geç.",
    "Konfor alanı, hayallerin öldüğü yerdir.",
    "Yorulunca değil, işin bitince dur.",
    "Aslan olmak istiyorsan, aslan gibi çalış.",
    // ... (200'e tamamlanacak şekilde listeler genişletilebilir)
    "Pes etmek senin lugatında olmamalı.",
    "Gerçek savaşçılar bahane üretmez, çözüm üretir.",
    "Bugün o adımı atmadığın her saniye kayıptasın.",
    "Zor geliyorsa doğru yoldasın demektir.",
    "Kendi imparatorluğunu kurmak için önce kendine hükmet."
  ];

  static final List<String> sunTzuQuotes = [
    "Mükemmeliyet, her savaşta savaşmak değil, düşmanı savaşmadan yenmektir.",
    "Beni anladığın kadar kendini de anlarsan, yüz savaşın yüzünü de kazanırsın.",
    "Strateji olmadan taktik, zaferden önceki gürültüdür.",
    "Zayıf görün ki düşmanın küstahlaşsın, güçlü görün ki düşmanın korksun.",
    "Hızlı akan suların kayaları sürüklemesi momentumdur.",
    "Fırsatlar, yakalandıkça çoğalırlar.",
    "Kargaşanın ortasında fırsat da yatar.",
    "Yenilmezlik savunmada, zafer ise saldırıda gizlidir.",
    "Bilge bir savaşçı, savaşmadan kazanmanın yolunu bulur.",
    "En büyük zafer, kendinle yaptığın savaştır."
  ];

  static String getRandomQuote(String coachType, int daysCount) {
    final random = Random();
    if (daysCount <= 7) {
      return sunTzuQuotes[random.nextInt(sunTzuQuotes.length)];
    }
    if (coachType == 'Ilımlı') {
      return ilimliQuotes[random.nextInt(ilimliQuotes.length)];
    } else {
      return dominantQuotes[random.nextInt(dominantQuotes.length)];
    }
  }
}
