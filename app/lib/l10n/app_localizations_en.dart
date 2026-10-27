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

  @override
  String get addBook => 'Add book';

  @override
  String get addScan => 'Scan barcodes';

  @override
  String get addScanHelp =>
      'Fastest way to fill your shelf: scan one book after another.';

  @override
  String get addSearch => 'Search';

  @override
  String get addSearchHelp => 'Find a book by title, author or ISBN.';

  @override
  String get addManual => 'Enter manually';

  @override
  String get addManualHelp =>
      'For books without an ISBN, or when search can\'t find them.';

  @override
  String get addToShelf => 'Add to my shelf';

  @override
  String addedToShelf(String title) {
    return 'Added “$title” to your shelf';
  }

  @override
  String alreadyOnShelf(String title) {
    return '“$title” is already on your shelf';
  }

  @override
  String get onYourShelf => 'On your shelf';

  @override
  String get undo => 'Undo';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Done';

  @override
  String get remove => 'Remove';

  @override
  String shelfFilterAll(int count) {
    return 'All ($count)';
  }

  @override
  String get statusUnread => 'Not read yet';

  @override
  String get statusReading => 'Reading';

  @override
  String get statusRead => 'Read';

  @override
  String pageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Title, author or ISBN';

  @override
  String get searchNoResults =>
      'We couldn\'t find that book. You can add it yourself.';

  @override
  String get scanTypeIsbn => 'Type an ISBN';

  @override
  String get scanInvalidIsbn => 'That doesn\'t look like a valid ISBN.';

  @override
  String get scanTorch => 'Flashlight';

  @override
  String get scanCameraError =>
      'The camera isn\'t available. Check camera permission, or type the ISBN instead.';

  @override
  String get scanHint =>
      'Point the camera at the barcode on the back of a book. Keep going: each book is added automatically.';

  @override
  String scanAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books added',
      one: '1 book added',
      zero: 'No books added yet',
    );
    return '$_temp0';
  }

  @override
  String get scanLookingUp => 'Looking up…';

  @override
  String get scanAdded => 'Added';

  @override
  String get scanNotFound => 'Not found online';

  @override
  String get scanFailed => 'Couldn\'t add';

  @override
  String get manualTitle => 'Title';

  @override
  String get manualAuthors => 'Author(s)';

  @override
  String get manualAuthorsHelp => 'Separate several authors with commas.';

  @override
  String get manualIsbn => 'ISBN (optional)';

  @override
  String get manualPages => 'Pages';

  @override
  String get manualYear => 'Year';

  @override
  String get manualNumberInvalid => 'Please enter a valid number.';

  @override
  String get detailStatus => 'My reading';

  @override
  String get detailRating => 'My rating';

  @override
  String detailStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stars',
      one: '1 star',
    );
    return '$_temp0';
  }

  @override
  String get detailReview => 'My thoughts';

  @override
  String get detailReviewHint => 'A few words for your neighbors (optional)';

  @override
  String get detailLendable => 'Happy to lend this book';

  @override
  String get detailLendableHelp =>
      'Neighbors who can see it may ask to borrow it.';

  @override
  String get detailVisibility => 'Who can see this book';

  @override
  String detailVisibilityDefault(String level) {
    return 'My default ($level)';
  }

  @override
  String get removeTitle => 'Remove from shelf?';

  @override
  String get removeBody =>
      'Your rating and thoughts about this book will be removed too.';

  @override
  String get discoverHint => 'Which book are you looking for?';

  @override
  String get discoverAroundYou => 'Books on shelves around you';

  @override
  String discoverResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books found',
      one: '1 book found',
    );
    return '$_temp0';
  }

  @override
  String get discoverNothingNearbyTitle => 'No shared shelves yet';

  @override
  String get discoverNothingNearbyBody =>
      'When friends and neighbors add books, they show up here. Invite a friend to get started!';

  @override
  String get discoverNoMatchTitle => 'Nobody nearby has this one yet';

  @override
  String get discoverNoMatchBody =>
      'Try another title or author, or add friends to see more shelves.';

  @override
  String countFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count friends',
      one: '1 friend',
      zero: 'No friends yet',
    );
    return '$_temp0';
  }

  @override
  String countNeighbors(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neighbors',
      one: '1 neighbor',
    );
    return '$_temp0';
  }

  @override
  String countOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more',
      one: '1 more',
    );
    return '$_temp0';
  }

  @override
  String countCanLend(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count can lend it',
      one: '1 can lend it',
    );
    return '$_temp0';
  }

  @override
  String get holdersCanLend => 'Can lend it';

  @override
  String get holdersNotLending =>
      'Also on their shelves (not lending right now)';

  @override
  String get holdersNone => 'Nobody you can see has this book right now.';

  @override
  String get relFriend => 'Friend';

  @override
  String get relNeighbor => 'Neighbor';

  @override
  String get relOther => 'On VennskApp';

  @override
  String get relYou => 'You';

  @override
  String get distanceSameArea => 'same area';

  @override
  String distanceKm(int km) {
    return '~$km km';
  }

  @override
  String get personNotFound => 'This person isn\'t available.';

  @override
  String get personPrivateNote =>
      'Their profile is private. You can still see books they chose to share.';

  @override
  String personShelf(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books you can see',
      one: '1 book you can see',
    );
    return '$_temp0';
  }

  @override
  String get personShelfEmpty => 'No books shared with you yet.';

  @override
  String get friendsTitle => 'Friends';

  @override
  String get friendsAdd => 'Add friend';

  @override
  String get friendsAddHelp =>
      'Know someone on VennskApp? Add them by their username.';

  @override
  String get friendsIncoming => 'Friend requests';

  @override
  String friendsIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new requests',
      one: '1 new request',
    );
    return '$_temp0';
  }

  @override
  String get friendsList => 'Your friends';

  @override
  String get friendsOutgoing => 'Waiting for an answer';

  @override
  String get friendsBlocked => 'Blocked';

  @override
  String get friendsEmpty =>
      'No friends yet. Friends can see the books you share with friends.';

  @override
  String friendRequestSent(String name) {
    return 'Friend request sent to @$name';
  }

  @override
  String friendNowFriends(String name) {
    return 'You and @$name are now friends!';
  }

  @override
  String friendNotFound(String name) {
    return 'No one with the username @$name';
  }

  @override
  String get friendIsMe => 'That\'s you!';

  @override
  String get friendAccept => 'Accept';

  @override
  String get friendDecline => 'Decline';

  @override
  String get friendRequestSentCancel => 'Request sent · Cancel';

  @override
  String get unfriend => 'Remove friend';

  @override
  String get block => 'Block';

  @override
  String get unblock => 'Unblock';

  @override
  String blockTitle(String name) {
    return 'Block $name?';
  }

  @override
  String get blockBody =>
      'You won\'t see each other\'s books or profiles, and they can\'t send you requests. They won\'t be told.';
}
