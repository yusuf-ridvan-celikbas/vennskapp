// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'VennskApp';

  @override
  String get tabShelf => 'My shelf';

  @override
  String get tabDiscover => 'Discover';

  @override
  String get tabLoans => 'Loans';

  @override
  String get tabMe => 'Me';

  @override
  String get shelfEmptyTitle => 'Your shelf is waiting';

  @override
  String get shelfEmptyBody =>
      'Add the books you own so your neighbors can discover them.';

  @override
  String get discoverEmptyTitle => 'Find a book nearby';

  @override
  String get discoverEmptyBody =>
      'Search for a title and see which friends and neighbors can lend it.';

  @override
  String get loansEmptyTitle => 'No loans yet';

  @override
  String get loansEmptyBody => 'Books you borrow or lend will appear here.';

  @override
  String get meTitle => 'Your corner';

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
      zero: 'Due today',
    );
    return '$_temp0';
  }

  @override
  String get welcomeTagline =>
      'Your neighbors\' bookshelves, one shared library.';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authEmailInvalid => 'Please enter a valid email address.';

  @override
  String get authPasswordTooShort => 'Use at least 8 characters.';

  @override
  String get authAdultCheckbox => 'I am 18 or older';

  @override
  String get authAdultRequired => 'VennskApp is for adults (18+) for now.';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignUp => 'Create account';

  @override
  String get authHaveAccount => 'Already have an account? Sign in';

  @override
  String get authNoAccount => 'New here? Create an account';

  @override
  String get authCheckEmail =>
      'Almost there! Check your email to confirm your account.';

  @override
  String authFailed(String message) {
    return 'Couldn\'t sign you in: $message';
  }

  @override
  String genericError(String message) {
    return 'Something went wrong: $message';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get fieldRequired => 'This field is required.';

  @override
  String get onboardingTitle => 'Welcome, neighbor!';

  @override
  String get onboardingIntro =>
      'Tell us a little about yourself so friends and neighbors can find you.';

  @override
  String get onboardingDisplayName => 'Your name';

  @override
  String get onboardingUsername => 'Username';

  @override
  String get onboardingUsernameHelp =>
      '3–20 characters: lowercase letters, numbers, _';

  @override
  String get onboardingUsernameInvalid =>
      'Use 3–20 lowercase letters, numbers or _.';

  @override
  String get onboardingUsernameTaken =>
      'That username is taken. Try another one.';

  @override
  String get onboardingWhereTitle => 'Where is your bookshelf?';

  @override
  String get onboardingAreaName => 'Neighborhood name';

  @override
  String get onboardingAreaNameHelp =>
      'Shown to others, e.g. \"Grünerløkka\" or \"Kadıköy\".';

  @override
  String get onboardingVisibilityTitle => 'Who can see your books by default?';

  @override
  String get onboardingFinish => 'Start sharing';

  @override
  String get locationUseMine => 'Use my location';

  @override
  String get locationPrivacyNote =>
      'Tap the map near your home. We only save an approximate area (about 1 km), never your address.';

  @override
  String get locationRequired => 'Please mark your area on the map.';

  @override
  String get locationDenied =>
      'Location permission was denied. You can tap the map instead.';

  @override
  String get locationFailed =>
      'Couldn\'t get your location. You can tap the map instead.';

  @override
  String get visibilityPrivate => 'Only me';

  @override
  String get visibilityFriends => 'Friends';

  @override
  String get visibilityNeighbors => 'Friends + neighborhood';

  @override
  String get visibilityPublic => 'Everyone';

  @override
  String get visibilityPrivateHelp => 'A private catalog, just for you.';

  @override
  String get visibilityFriendsHelp => 'People you\'ve added as friends.';

  @override
  String get visibilityNeighborsHelp =>
      'Friends, plus neighbors within about 5 km.';

  @override
  String get visibilityPublicHelp => 'Anyone on VennskApp.';

  @override
  String get meAreaSubtitle => 'Your neighborhood';

  @override
  String get meDefaultVisibilitySubtitle => 'Default visibility for new books';

  @override
  String meThumbsUp(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thumbs-up from neighbors',
      one: '1 thumbs-up from neighbors',
      zero: 'No thumbs-up yet',
    );
    return '$_temp0';
  }
}
