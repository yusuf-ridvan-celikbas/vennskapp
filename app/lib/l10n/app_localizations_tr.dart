// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'VennskApp';

  @override
  String get tabShelf => 'Rafım';

  @override
  String get tabDiscover => 'Keşfet';

  @override
  String get tabLoans => 'Ödünçler';

  @override
  String get tabMe => 'Ben';

  @override
  String get shelfEmptyTitle => 'Rafın seni bekliyor';

  @override
  String get shelfEmptyBody =>
      'Sahip olduğun kitapları ekle, komşuların da keşfedebilsin.';

  @override
  String get loansEmptyTitle => 'Henüz ödünç yok';

  @override
  String get meTitle => 'Senin köşen';

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün kaldı',
      one: '1 gün kaldı',
      zero: 'Bugün teslim',
    );
    return '$_temp0';
  }

  @override
  String get welcomeTagline =>
      'Komşularının kitaplıkları, tek bir ortak kütüphane.';

  @override
  String get authEmail => 'E-posta';

  @override
  String get authPassword => 'Şifre';

  @override
  String get authEmailInvalid => 'Lütfen geçerli bir e-posta adresi gir.';

  @override
  String get authPasswordTooShort => 'En az 8 karakter kullan.';

  @override
  String get authAdultCheckbox => '18 yaşında veya daha büyüğüm';

  @override
  String get authAdultRequired => 'VennskApp şimdilik yetişkinler (18+) için.';

  @override
  String get authSignIn => 'Giriş yap';

  @override
  String get authSignUp => 'Hesap oluştur';

  @override
  String get authHaveAccount => 'Zaten hesabın var mı? Giriş yap';

  @override
  String get authNoAccount => 'Yeni misin? Hesap oluştur';

  @override
  String get authCheckEmail =>
      'Az kaldı! Hesabını onaylamak için e-postanı kontrol et.';

  @override
  String authFailed(String message) {
    return 'Giriş yapılamadı: $message';
  }

  @override
  String genericError(String message) {
    return 'Bir şeyler ters gitti: $message';
  }

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get fieldRequired => 'Bu alan zorunlu.';

  @override
  String get onboardingTitle => 'Hoş geldin, komşu!';

  @override
  String get onboardingIntro =>
      'Arkadaşların ve komşuların seni bulabilsin diye biraz kendinden bahset.';

  @override
  String get onboardingDisplayName => 'Adın';

  @override
  String get onboardingUsername => 'Kullanıcı adı';

  @override
  String get onboardingUsernameHelp => '3–20 karakter: a–z, rakam, _';

  @override
  String get onboardingUsernameInvalid =>
      '3–20 karakter kullan: a–z, rakam veya _.';

  @override
  String get onboardingUsernameTaken =>
      'Bu kullanıcı adı alınmış. Başka bir tane dene.';

  @override
  String get onboardingWhereTitle => 'Kitaplığın nerede?';

  @override
  String get onboardingAreaName => 'Semt adı';

  @override
  String get onboardingAreaNameHelp =>
      'Başkalarına gösterilir, ör. \"Kadıköy\" veya \"Grünerløkka\".';

  @override
  String get onboardingVisibilityTitle =>
      'Kitaplarını varsayılan olarak kimler görsün?';

  @override
  String get onboardingFinish => 'Paylaşmaya başla';

  @override
  String get locationUseMine => 'Konumumu kullan';

  @override
  String get locationPrivacyNote =>
      'Haritada evinin yakınına dokun. Adresini değil, yalnızca yaklaşık bir bölgeyi (yaklaşık 1 km) kaydederiz.';

  @override
  String get locationRequired => 'Lütfen haritada bölgeni işaretle.';

  @override
  String get locationDenied =>
      'Konum izni verilmedi. Bunun yerine haritaya dokunabilirsin.';

  @override
  String get locationFailed =>
      'Konumun alınamadı. Bunun yerine haritaya dokunabilirsin.';

  @override
  String get visibilityPrivate => 'Sadece ben';

  @override
  String get visibilityFriends => 'Arkadaşlar';

  @override
  String get visibilityNeighbors => 'Arkadaşlar + mahalle';

  @override
  String get visibilityPublic => 'Herkes';

  @override
  String get visibilityPrivateHelp => 'Sadece sana özel bir katalog.';

  @override
  String get visibilityFriendsHelp => 'Arkadaş olarak eklediğin kişiler.';

  @override
  String get visibilityNeighborsHelp =>
      'Arkadaşların ve yaklaşık 5 km içindeki komşular.';

  @override
  String get visibilityPublicHelp => 'VennskApp\'teki herkes.';

  @override
  String get meAreaSubtitle => 'Mahallen';

  @override
  String get meDefaultVisibilitySubtitle =>
      'Yeni kitaplar için varsayılan görünürlük';

  @override
  String meThumbsUp(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Komşulardan $count beğeni',
      one: 'Komşulardan 1 beğeni',
      zero: 'Henüz beğeni yok',
    );
    return '$_temp0';
  }

  @override
  String get addBook => 'Kitap ekle';

  @override
  String get addScan => 'Barkod tara';

  @override
  String get addScanHelp =>
      'Rafını doldurmanın en hızlı yolu: kitapları art arda tara.';

  @override
  String get addSearch => 'Ara';

  @override
  String get addSearchHelp =>
      'Bir kitabı adına, yazarına veya ISBN\'ine göre bul.';

  @override
  String get addManual => 'Elle gir';

  @override
  String get addManualHelp =>
      'ISBN\'i olmayan ya da aramada çıkmayan kitaplar için.';

  @override
  String get addToShelf => 'Rafıma ekle';

  @override
  String addedToShelf(String title) {
    return '“$title” rafına eklendi';
  }

  @override
  String alreadyOnShelf(String title) {
    return '“$title” zaten rafında';
  }

  @override
  String get onYourShelf => 'Rafında';

  @override
  String get undo => 'Geri al';

  @override
  String get cancel => 'İptal';

  @override
  String get ok => 'Tamam';

  @override
  String get done => 'Bitti';

  @override
  String get remove => 'Kaldır';

  @override
  String shelfFilterAll(int count) {
    return 'Tümü ($count)';
  }

  @override
  String get statusUnread => 'Henüz okunmadı';

  @override
  String get statusReading => 'Okunuyor';

  @override
  String get statusRead => 'Okundu';

  @override
  String pageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sayfa',
      one: '1 sayfa',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Kitap adı, yazar veya ISBN';

  @override
  String get searchNoResults => 'Bu kitabı bulamadık. Kendin ekleyebilirsin.';

  @override
  String get scanTypeIsbn => 'ISBN yaz';

  @override
  String get scanInvalidIsbn => 'Bu geçerli bir ISBN gibi görünmüyor.';

  @override
  String get scanTorch => 'Fener';

  @override
  String get scanCameraError =>
      'Kamera kullanılamıyor. Kamera iznini kontrol et ya da ISBN\'i elle yaz.';

  @override
  String get scanHint =>
      'Kamerayı kitabın arkasındaki barkoda tut. Devam et: her kitap otomatik olarak eklenir.';

  @override
  String scanAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kitap eklendi',
      one: '1 kitap eklendi',
      zero: 'Henüz kitap eklenmedi',
    );
    return '$_temp0';
  }

  @override
  String get scanLookingUp => 'Aranıyor…';

  @override
  String get scanAdded => 'Eklendi';

  @override
  String get scanNotFound => 'İnternette bulunamadı';

  @override
  String get scanFailed => 'Eklenemedi';

  @override
  String get manualTitle => 'Kitap adı';

  @override
  String get manualAuthors => 'Yazar(lar)';

  @override
  String get manualAuthorsHelp => 'Birden fazla yazarı virgülle ayır.';

  @override
  String get manualIsbn => 'ISBN (isteğe bağlı)';

  @override
  String get manualPages => 'Sayfa';

  @override
  String get manualYear => 'Yıl';

  @override
  String get manualNumberInvalid => 'Lütfen geçerli bir sayı gir.';

  @override
  String get detailStatus => 'Okuma durumum';

  @override
  String get detailRating => 'Puanım';

  @override
  String detailStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yıldız',
      one: '1 yıldız',
    );
    return '$_temp0';
  }

  @override
  String get detailReview => 'Düşüncelerim';

  @override
  String get detailReviewHint => 'Komşuların için birkaç söz (isteğe bağlı)';

  @override
  String get detailLendable => 'Bu kitabı seve seve ödünç veririm';

  @override
  String get detailLendableHelp =>
      'Kitabı görebilen komşular ödünç isteyebilir.';

  @override
  String get detailVisibility => 'Bu kitabı kimler görebilir';

  @override
  String detailVisibilityDefault(String level) {
    return 'Varsayılanım ($level)';
  }

  @override
  String get removeTitle => 'Raftan kaldırılsın mı?';

  @override
  String get removeBody =>
      'Bu kitaba verdiğin puan ve düşüncelerin de silinecek.';

  @override
  String get discoverHint => 'Hangi kitabı arıyorsun?';

  @override
  String get discoverAroundYou => 'Çevrendeki raflardaki kitaplar';

  @override
  String discoverResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kitap bulundu',
      one: '1 kitap bulundu',
    );
    return '$_temp0';
  }

  @override
  String get discoverNothingNearbyTitle => 'Henüz paylaşılan raf yok';

  @override
  String get discoverNothingNearbyBody =>
      'Arkadaşların ve komşuların kitap ekledikçe burada görünecek. Başlamak için bir arkadaşını davet et!';

  @override
  String get discoverNoMatchTitle => 'Yakınında henüz kimsede bu kitap yok';

  @override
  String get discoverNoMatchBody =>
      'Başka bir kitap adı veya yazar dene ya da daha fazla raf görmek için arkadaş ekle.';

  @override
  String countFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arkadaş',
      one: '1 arkadaş',
      zero: 'Henüz arkadaş yok',
    );
    return '$_temp0';
  }

  @override
  String countNeighbors(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count komşu',
      one: '1 komşu',
    );
    return '$_temp0';
  }

  @override
  String countOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kişi daha',
      one: '1 kişi daha',
    );
    return '$_temp0';
  }

  @override
  String countCanLend(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kişi ödünç verebilir',
      one: '1 kişi ödünç verebilir',
    );
    return '$_temp0';
  }

  @override
  String get holdersCanLend => 'Ödünç verebilir';

  @override
  String get holdersNotLending => 'Raflarında da var (şu an ödünç vermiyor)';

  @override
  String get holdersNone => 'Görebildiğin kimsede şu an bu kitap yok.';

  @override
  String get relFriend => 'Arkadaş';

  @override
  String get relNeighbor => 'Komşu';

  @override
  String get relOther => 'VennskApp\'te';

  @override
  String get relYou => 'Sen';

  @override
  String get distanceSameArea => 'aynı bölge';

  @override
  String distanceKm(int km) {
    return '~$km km';
  }

  @override
  String get personNotFound => 'Bu kişiye ulaşılamıyor.';

  @override
  String get personPrivateNote =>
      'Profili gizli. Yine de paylaşmayı seçtiği kitapları görebilirsin.';

  @override
  String personShelf(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Görebildiğin $count kitap',
      one: 'Görebildiğin 1 kitap',
    );
    return '$_temp0';
  }

  @override
  String get personShelfEmpty => 'Henüz seninle paylaşılan kitap yok.';

  @override
  String get friendsTitle => 'Arkadaşlar';

  @override
  String get friendsAdd => 'Arkadaş ekle';

  @override
  String get friendsAddHelp =>
      'VennskApp\'te tanıdığın biri mi var? Kullanıcı adıyla ekle.';

  @override
  String get friendsIncoming => 'Arkadaşlık istekleri';

  @override
  String friendsIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yeni istek',
      one: '1 yeni istek',
    );
    return '$_temp0';
  }

  @override
  String get friendsList => 'Arkadaşların';

  @override
  String get friendsOutgoing => 'Yanıt bekleniyor';

  @override
  String get friendsBlocked => 'Engellenenler';

  @override
  String get friendsEmpty =>
      'Henüz arkadaş yok. Arkadaşların, arkadaşlarla paylaştığın kitapları görebilir.';

  @override
  String friendRequestSent(String name) {
    return 'Arkadaşlık isteği gönderildi: @$name';
  }

  @override
  String friendNowFriends(String name) {
    return 'Sen ve @$name artık arkadaşsınız!';
  }

  @override
  String friendNotFound(String name) {
    return '@$name kullanıcı adıyla kimse yok';
  }

  @override
  String get friendIsMe => 'Bu sensin!';

  @override
  String get friendAccept => 'Kabul et';

  @override
  String get friendDecline => 'Reddet';

  @override
  String get friendRequestSentCancel => 'İstek gönderildi · İptal';

  @override
  String get unfriend => 'Arkadaşlıktan çıkar';

  @override
  String get block => 'Engelle';

  @override
  String get unblock => 'Engeli kaldır';

  @override
  String blockTitle(String name) {
    return '$name engellensin mi?';
  }

  @override
  String get blockBody =>
      'Birbirinizin kitaplarını ve profillerini görmeyeceksiniz, sana istek de gönderemeyecek. Kendisine haber verilmez.';

  @override
  String get view => 'Görüntüle';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün',
      one: '1 gün',
    );
    return '$_temp0';
  }

  @override
  String get holderAskToBorrow => 'Ödünç iste';

  @override
  String get holderRequested => 'İstendi';

  @override
  String get holderPromised => 'Sana söz verildi';

  @override
  String get holderYouHaveIt => 'Sende';

  @override
  String get holderLentOut => 'Ödünçte';

  @override
  String get loanDefaultMessage =>
      'Merhaba komşu! Bu kitabı okumayı çok isterim.';

  @override
  String loanRequestTitle(String title) {
    return '“$title” kitabını ödünç al';
  }

  @override
  String loanRequestFrom(String name) {
    return 'Sahibi: $name';
  }

  @override
  String get loanMessageLabel => 'Birkaç sıcak söz';

  @override
  String get loanRequestTip =>
      'Kabul edilince nerede buluşacağınıza birlikte karar verirsiniz. Kafe ya da kütüphane gibi halka açık bir yer iyi olur.';

  @override
  String get loanRequestSend => 'İsteği gönder';

  @override
  String loanRequestSent(String name) {
    return 'İstek gönderildi: $name';
  }

  @override
  String get loansTabActive => 'Aktif';

  @override
  String get loansTabRequests => 'İstekler';

  @override
  String get loansTabHistory => 'Geçmiş';

  @override
  String get loansEmptyActive =>
      'Ödünç aldığın veya verdiğin kitaplar burada görünecek.';

  @override
  String get loansEmptyRequests =>
      'Açık istek yok. Keşfet\'te bir kitap bul ve ödünç iste!';

  @override
  String get loansEmptyHistory => 'Biten ödünçler burada saklanır.';

  @override
  String get loanYouLend => 'Sen veriyorsun';

  @override
  String get loanYouBorrow => 'Sen alıyorsun';

  @override
  String loanLentTo(String name) {
    return 'Ödünç verilen: $name';
  }

  @override
  String loanBorrowedFrom(String name) {
    return 'Ödünç alınan: $name';
  }

  @override
  String loanLineWantsToBorrow(String name) {
    return '$name ödünç almak istiyor';
  }

  @override
  String loanLineWaitingAnswer(String name) {
    return 'Yanıt bekleniyor: $name';
  }

  @override
  String get loanLineArrangeHandover => 'Buluşun ve teslimi onaylayın';

  @override
  String loanLineWaitingHandover(String name) {
    return 'Teslim onayı bekleniyor: $name';
  }

  @override
  String loanLineOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün gecikti',
      one: '1 gün gecikti',
      zero: 'Bugün teslim',
    );
    return '$_temp0';
  }

  @override
  String loanLineExtensionAsked(String name, int days) {
    return '$name $days gün daha istiyor';
  }

  @override
  String loanLineReturned(String date) {
    return 'İade edildi: $date';
  }

  @override
  String get loanLineDeclined => 'Bu sefer olmadı';

  @override
  String get loanLineCancelled => 'İptal edildi';

  @override
  String get loanNotFound => 'Bu ödünç kaydına ulaşılamıyor.';

  @override
  String get loanChanged => 'Bu ödünç bu arada değişti. İşte son hali.';

  @override
  String loanDueOn(String date) {
    return 'İade tarihi: $date';
  }

  @override
  String get loanHandoverTip =>
      'Kafe veya kütüphane gibi halka açık bir yerde buluşun. Kitap el değiştirince ikiniz de onaya dokunun.';

  @override
  String loanTheyConfirmed(String name) {
    return '$name zaten onayladı.';
  }

  @override
  String loanMessageFrom(String name) {
    return 'Gönderen: $name';
  }

  @override
  String get loanYourMessage => 'Senin mesajın';

  @override
  String get loanTimeline => 'Geçmiş';

  @override
  String get loanAccept => 'Ödünç ver';

  @override
  String get loanDecline => 'Bu sefer olmaz';

  @override
  String get loanAcceptTitle => 'Ne kadar süre kalabilir?';

  @override
  String loanAcceptHelp(String name) {
    return '$name için bir ödünç süresi seç. Süre, kitabı teslim ettiğinde başlar.';
  }

  @override
  String get loanDaysLabel => 'Gün';

  @override
  String loanDaysRange(int min, int max) {
    return '$min ile $max gün arası';
  }

  @override
  String loanAcceptedSnack(String name) {
    return 'Harika! Şimdi teslimi $name ile ayarla.';
  }

  @override
  String get loanDeclineTitle => 'Nazikçe hayır de';

  @override
  String get loanDeclineReason => 'Neden (isteğe bağlı)';

  @override
  String get loanCancelRequest => 'İsteği geri çek';

  @override
  String get loanCallOff => 'Vazgeç';

  @override
  String get loanConfirmGave => 'Teslim ettim';

  @override
  String get loanConfirmGot => 'Kitabı aldım';

  @override
  String get loanMarkReturned => 'Kitabım geri geldi';

  @override
  String get loanReturnedSnack => 'Tekrar hoş geldin, kitap!';

  @override
  String get loanExtendAsk => 'Ek süre iste';

  @override
  String get loanExtendTitle => 'Kaç gün daha?';

  @override
  String get loanExtraDaysLabel => 'Ek gün';

  @override
  String loanExtendSent(String name) {
    return 'Ek süre isteğin gönderildi ($name)';
  }

  @override
  String loanExtendAccept(int days) {
    return '$days gün daha ver';
  }

  @override
  String get loanExtendDecline => 'İade tarihi aynı kalsın';

  @override
  String get eventRequested => 'İstek gönderildi';

  @override
  String eventAccepted(int days) {
    return '$days gün için kabul edildi';
  }

  @override
  String get eventDeclined => 'Reddedildi';

  @override
  String get eventDeclinedOther => 'Başka birine ödünç verildi';

  @override
  String get eventCancelled => 'İptal edildi';

  @override
  String get eventHandoverByMe => 'Teslimi onayladın';

  @override
  String get eventHandoverByThem => 'Karşı taraf teslimi onayladı';

  @override
  String get eventStarted => 'Ödünç başladı';

  @override
  String eventExtensionRequested(int days) {
    return '$days gün ek süre istendi';
  }

  @override
  String get eventExtensionAccepted => 'Ek süre kabul edildi';

  @override
  String get eventExtensionDeclined => 'Ek süre reddedildi';

  @override
  String get eventReturned => 'Kitap iade edildi';

  @override
  String get eventExpired => 'Otomatik iptal: 7 gün içinde teslim yapılmadı';

  @override
  String loanAcceptSuggested(String name, int days, int pages) {
    return '$name için okuma hızına ve kitabın uzunluğuna ($pages sayfa) göre $days gün öneriyoruz. İstediğin süreyi seçebilirsin.';
  }

  @override
  String get readingTitle => 'Okuma';

  @override
  String get readingLogButton => 'Okuma kaydet';

  @override
  String get readingLogTitle => 'Ne okudun?';

  @override
  String get readingPages => 'Okunan sayfa';

  @override
  String get readingHours => 'Saat';

  @override
  String get readingMinutes => 'Dakika';

  @override
  String get readingWhichBook => 'Kitap (isteğe bağlı)';

  @override
  String get readingNoBook => 'Belirli bir kitap yok';

  @override
  String get readingChangeDate => 'Değiştir';

  @override
  String get readingSave => 'Kaydet';

  @override
  String get readingTimeInvalid =>
      'Lütfen 1 dakika ile 24 saat arasında bir okuma süresi gir.';

  @override
  String get readingLogged => 'Güzel okuma! Kaydedildi.';

  @override
  String get readingFinishedRangeHelp =>
      'Ne zaman başladın, ne zaman bitirdin?';

  @override
  String get readingFinishedSaved =>
      'Bitti! Bu, sana adil ödünç süreleri önermemize yardımcı olur.';

  @override
  String get readingPrivacyNote =>
      'Okuma kaydın gizlidir. Ödünç verenler istatistiklerini değil, yalnızca önerilen gün sayısını görür.';

  @override
  String get readingFinishedTitle => 'Bitirilen kitaplar';

  @override
  String get readingFinishedEmpty =>
      'Buraya eklemek için bir kitabı Okundu olarak işaretle.';

  @override
  String readingFinishedLine(String date, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days günde okundu',
      one: '1 günde okundu',
    );
    return '$date · $_temp0';
  }

  @override
  String get readingSessionsTitle => 'Okuma oturumları';

  @override
  String get readingSessionsEmpty =>
      'Henüz oturum yok. Hızını görmek için okumalarını kaydet.';

  @override
  String readingSessionLine(int pages, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '$pages sayfa',
      one: '1 sayfa',
    );
    return '$minutes dakikada $_temp0';
  }

  @override
  String get statBooksThisYear => 'bu yıl kitap';

  @override
  String get statPages30 => '30 günde sayfa';

  @override
  String get statPagesPerHour => 'saatte sayfa';

  @override
  String statPace(int pages) {
    return 'Hızın: günde yaklaşık $pages sayfa';
  }

  @override
  String get statPaceNew =>
      'Tipik bir hızla başlıyoruz; kitap bitirdikçe senin hızını öğreniyoruz.';

  @override
  String statPaceLearned(int days) {
    return '300 sayfalık bir kitap için yaklaşık $days gün önerilir.';
  }

  @override
  String get statConfidence => 'Hızını ne kadar iyi biliyoruz';

  @override
  String get notificationsTitle => 'Bildirimler';

  @override
  String get notificationsMarkAllRead => 'Tümünü okundu yap';

  @override
  String get notificationsEmptyTitle => 'Her şey sakin';

  @override
  String get notificationsEmptyBody =>
      'Ödünç istekleri, teslimler, hatırlatmalar ve arkadaşlık istekleri burada görünecek.';

  @override
  String get notificationsUnread => 'Okunmadı';

  @override
  String get notificationsView => 'Görüntüle';

  @override
  String notifLoanRequested(String name, String title) {
    return '$name, “$title” kitabını ödünç almak istiyor';
  }

  @override
  String notifLoanAccepted(String name, String title, int days) {
    return '$name, “$title” kitabını sana $days günlüğüne ödünç verecek. Teslimi ayarlayın!';
  }

  @override
  String notifLoanLentElsewhere(String title) {
    return '“$title” bu sefer başka bir komşuya gitti';
  }

  @override
  String notifLoanDeclined(String name, String title) {
    return '$name bu sefer “$title” kitabını ödünç veremiyor';
  }

  @override
  String notifLoanCancelled(String name, String title) {
    return '$name, “$title” ödüncünden vazgeçti';
  }

  @override
  String notifLoanHandover(String name, String title) {
    return '$name, “$title” teslimini onayladı. Lütfen sen de onayla.';
  }

  @override
  String notifLoanStarted(String title) {
    return '“$title” ödüncü başladı';
  }

  @override
  String notifExtensionRequested(String name, String title, int days) {
    return '$name, “$title” için $days gün daha istiyor';
  }

  @override
  String notifExtensionAccepted(String name, String title) {
    return '$name, “$title” için sana ek süre verdi';
  }

  @override
  String notifExtensionDeclined(String name, String title) {
    return '$name, “$title” için ek süre veremedi';
  }

  @override
  String notifLoanReturned(String name, String title) {
    return '“$title” iade edildi, $name onayladı. Nasıl geçti?';
  }

  @override
  String notifLoanExpired(String title) {
    return '“$title” ödüncü iptal edildi: 7 gün içinde teslim yapılmadı';
  }

  @override
  String notifLoanDueSoon(String title, String name, String date) {
    return '“$title” için iade tarihi $date ($name)';
  }

  @override
  String notifLoanOverdue(String title, String name) {
    return '“$title” gecikti. Lütfen sahibine geri ver ($name).';
  }

  @override
  String notifLoanOverdueOwner(String name, String title) {
    return '$name, “$title” kitabını henüz iade etmedi';
  }

  @override
  String notifFriendRequest(String name) {
    return '$name sana arkadaşlık isteği gönderdi';
  }

  @override
  String notifFriendAccepted(String name) {
    return '$name arkadaşlık isteğini kabul etti';
  }

  @override
  String get notifGeneric => 'Yeni bir bildirimin var';

  @override
  String get report => 'Şikâyet et';

  @override
  String get reportProblem => 'Sorun bildir';

  @override
  String reportTitle(String name) {
    return 'Şikâyet: $name';
  }

  @override
  String get reportBody =>
      'Şikâyetler gizlidir: karşı taraf kimin gönderdiğini görmez.';

  @override
  String get reportNotReturned => 'Kitap iade edilmedi';

  @override
  String get reportDamaged => 'Kitap hasarlı döndü';

  @override
  String get reportNoShow => 'Teslim buluşmasına gelmedi';

  @override
  String get reportInappropriate => 'Kaba veya uygunsuz davranış';

  @override
  String get reportSpam => 'Spam veya sahte hesap';

  @override
  String get reportOther => 'Başka bir şey';

  @override
  String get reportDetails => 'Ne oldu? (isteğe bağlı)';

  @override
  String reportAlsoBlock(String name) {
    return '$name ayrıca engellensin';
  }

  @override
  String get reportSend => 'Şikâyeti gönder';

  @override
  String get reportSent => 'Teşekkürler. İnceleyeceğiz.';

  @override
  String feedbackQuestion(String name) {
    return '$name ile nasıl geçti?';
  }

  @override
  String get feedbackUp => 'İyi geçti';

  @override
  String get feedbackDown => 'Pek iyi değildi';

  @override
  String get feedbackPrivate =>
      'Profillerde yalnızca toplam beğeni sayısı gösterilir.';

  @override
  String get feedbackThanks => 'Geri bildirimin için teşekkürler!';

  @override
  String get feedbackGiven => 'Teşekkürler, geri bildirimin kaydedildi.';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get privacyTitle => 'Gizlilik';

  @override
  String get privacySubtitle => 'Neleri, neden saklıyoruz';

  @override
  String get authPrivacyLink => 'Verilerini nasıl kullanıyoruz';

  @override
  String get privacyDemoNote =>
      'VennskApp, arkadaşlar ve komşular için bir kişinin yürüttüğü bir demodur. Henüz bir şirket hizmeti değildir.';

  @override
  String get privacyDataTitle => 'Ne saklıyoruz';

  @override
  String get privacyDataBody =>
      'E-postan, adın, kullanıcı adın, yaklaşık bölgen (yaklaşık 1 km), rafın, ödünçlerin, arkadaşların, gönderdiğin şikâyetler ve okuma kaydın. Adresini, telefon numaranı veya tam konumunu asla saklamayız.';

  @override
  String get privacyWhoTitle => 'Kim neyi görür';

  @override
  String get privacyWhoBody =>
      'Kitaplarını ve profilini kimin göreceğini sen seçersin. Okuma kaydın yalnızca senin içindir: ödünç verenler sadece önerilen gün sayısını görür. Diğerleri semt adını ve yuvarlanmış bir mesafeyi görür, konumunu asla.';

  @override
  String get privacyWhyTitle => 'Neden';

  @override
  String get privacyWhyBody =>
      'Yalnızca uygulamayı çalıştırmak için: kitaplarını seçtiğin kişilere göstermek, ödünçleri düzenlemek ve hatırlatma göndermek. Reklam yok, veri satışı yok, takip yok.';

  @override
  String get privacyWhereTitle => 'Nerede saklanıyor';

  @override
  String get privacyWhereBody =>
      'Bir Supabase veritabanında. Kitap bilgileri Open Library ve Google Books\'tan gelir, bu yüzden arama kelimelerin onlara gönderilir. Harita OpenStreetMap kullanır.';

  @override
  String get privacyRightsTitle => 'Hakların';

  @override
  String get privacyRightsBody =>
      'KVKK ve GDPR kapsamında verilerini görebilir, düzeltebilir ve silebilirsin. Hesabını istediğin zaman Ben sekmesinden silebilirsin; seninle ilgili her şey hemen kaldırılır. Verilerinin bir kopyası için seni davet eden kişiye sor.';

  @override
  String get deleteAccount => 'Hesabı sil';

  @override
  String get deleteAccountTitle => 'Hesabın silinsin mi?';

  @override
  String get deleteAccountBody =>
      'Profilin, rafın, okuma kaydın, arkadaşların, bildirimlerin ve ödünç geçmişin kalıcı olarak silinir. Bu işlem geri alınamaz.';

  @override
  String get deleteAccountConfirm => 'Kalıcı olarak sil';

  @override
  String get deleteAccountOpenLoans =>
      'Lütfen önce açık ödünçlerini tamamla: ödünç verdiğin veya aldığın kitapların iade edilmesi gerekiyor.';

  @override
  String get deleteAccountDone => 'Hesabın silindi. Kendine iyi bak, komşu!';
}
