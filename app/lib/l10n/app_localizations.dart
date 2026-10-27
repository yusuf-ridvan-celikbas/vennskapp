import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// App name; not translated.
  ///
  /// In en, this message translates to:
  /// **'VennskApp'**
  String get appTitle;

  /// Bottom tab: the user's own books.
  ///
  /// In en, this message translates to:
  /// **'My shelf'**
  String get tabShelf;

  /// Bottom tab: find books neighbors have.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get tabDiscover;

  /// Bottom tab: books borrowed and lent.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get tabLoans;

  /// Bottom tab: profile, reading log, settings.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get tabMe;

  /// No description provided for @shelfEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your shelf is waiting'**
  String get shelfEmptyTitle;

  /// No description provided for @shelfEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add the books you own so your neighbors can discover them.'**
  String get shelfEmptyBody;

  /// No description provided for @discoverEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Find a book nearby'**
  String get discoverEmptyTitle;

  /// No description provided for @discoverEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Search for a title and see which friends and neighbors can lend it.'**
  String get discoverEmptyBody;

  /// No description provided for @loansEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No loans yet'**
  String get loansEmptyTitle;

  /// No description provided for @loansEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Books you borrow or lend will appear here.'**
  String get loansEmptyBody;

  /// No description provided for @meTitle.
  ///
  /// In en, this message translates to:
  /// **'Your corner'**
  String get meTitle;

  /// Countdown on an active loan.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Due today} =1{1 day left} other{{count} days left}}'**
  String daysLeft(int count);

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Your neighbors\' bookshelves, one shared library.'**
  String get welcomeTagline;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get authPasswordTooShort;

  /// No description provided for @authAdultCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I am 18 or older'**
  String get authAdultCheckbox;

  /// No description provided for @authAdultRequired.
  ///
  /// In en, this message translates to:
  /// **'VennskApp is for adults (18+) for now.'**
  String get authAdultRequired;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authSignUp;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get authHaveAccount;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get authNoAccount;

  /// No description provided for @authCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Almost there! Check your email to confirm your account.'**
  String get authCheckEmail;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign you in: {message}'**
  String authFailed(String message);

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {message}'**
  String genericError(String message);

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get fieldRequired;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome, neighbor!'**
  String get onboardingTitle;

  /// No description provided for @onboardingIntro.
  ///
  /// In en, this message translates to:
  /// **'Tell us a little about yourself so friends and neighbors can find you.'**
  String get onboardingIntro;

  /// No description provided for @onboardingDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get onboardingDisplayName;

  /// No description provided for @onboardingUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get onboardingUsername;

  /// No description provided for @onboardingUsernameHelp.
  ///
  /// In en, this message translates to:
  /// **'3–20 characters: lowercase letters, numbers, _'**
  String get onboardingUsernameHelp;

  /// No description provided for @onboardingUsernameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use 3–20 lowercase letters, numbers or _.'**
  String get onboardingUsernameInvalid;

  /// No description provided for @onboardingUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'That username is taken. Try another one.'**
  String get onboardingUsernameTaken;

  /// No description provided for @onboardingWhereTitle.
  ///
  /// In en, this message translates to:
  /// **'Where is your bookshelf?'**
  String get onboardingWhereTitle;

  /// No description provided for @onboardingAreaName.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood name'**
  String get onboardingAreaName;

  /// No description provided for @onboardingAreaNameHelp.
  ///
  /// In en, this message translates to:
  /// **'Shown to others, e.g. \"Grünerløkka\" or \"Kadıköy\".'**
  String get onboardingAreaNameHelp;

  /// No description provided for @onboardingVisibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Who can see your books by default?'**
  String get onboardingVisibilityTitle;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Start sharing'**
  String get onboardingFinish;

  /// No description provided for @locationUseMine.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get locationUseMine;

  /// No description provided for @locationPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Tap the map near your home. We only save an approximate area (about 1 km), never your address.'**
  String get locationPrivacyNote;

  /// No description provided for @locationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please mark your area on the map.'**
  String get locationRequired;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. You can tap the map instead.'**
  String get locationDenied;

  /// No description provided for @locationFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get your location. You can tap the map instead.'**
  String get locationFailed;

  /// No description provided for @visibilityPrivate.
  ///
  /// In en, this message translates to:
  /// **'Only me'**
  String get visibilityPrivate;

  /// No description provided for @visibilityFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get visibilityFriends;

  /// No description provided for @visibilityNeighbors.
  ///
  /// In en, this message translates to:
  /// **'Friends + neighborhood'**
  String get visibilityNeighbors;

  /// No description provided for @visibilityPublic.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get visibilityPublic;

  /// No description provided for @visibilityPrivateHelp.
  ///
  /// In en, this message translates to:
  /// **'A private catalog, just for you.'**
  String get visibilityPrivateHelp;

  /// No description provided for @visibilityFriendsHelp.
  ///
  /// In en, this message translates to:
  /// **'People you\'ve added as friends.'**
  String get visibilityFriendsHelp;

  /// No description provided for @visibilityNeighborsHelp.
  ///
  /// In en, this message translates to:
  /// **'Friends, plus neighbors within about 5 km.'**
  String get visibilityNeighborsHelp;

  /// No description provided for @visibilityPublicHelp.
  ///
  /// In en, this message translates to:
  /// **'Anyone on VennskApp.'**
  String get visibilityPublicHelp;

  /// No description provided for @meAreaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your neighborhood'**
  String get meAreaSubtitle;

  /// No description provided for @meDefaultVisibilitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Default visibility for new books'**
  String get meDefaultVisibilitySubtitle;

  /// No description provided for @meThumbsUp.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No thumbs-up yet} =1{1 thumbs-up from neighbors} other{{count} thumbs-up from neighbors}}'**
  String meThumbsUp(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
