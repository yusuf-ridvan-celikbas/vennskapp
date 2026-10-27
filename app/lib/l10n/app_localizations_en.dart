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
  String get loansEmptyTitle => 'No loans yet';

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

  @override
  String get view => 'View';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get holderAskToBorrow => 'Ask to borrow';

  @override
  String get holderRequested => 'Requested';

  @override
  String get holderPromised => 'Promised to you';

  @override
  String get holderYouHaveIt => 'You have it';

  @override
  String get holderLentOut => 'Lent out';

  @override
  String get loanDefaultMessage => 'Hi neighbor! I\'d love to read this book.';

  @override
  String loanRequestTitle(String title) {
    return 'Borrow “$title”';
  }

  @override
  String loanRequestFrom(String name) {
    return 'from $name';
  }

  @override
  String get loanMessageLabel => 'A few friendly words';

  @override
  String get loanRequestTip =>
      'After they say yes, you\'ll agree on where to meet. A café or library is a good public spot.';

  @override
  String get loanRequestSend => 'Send request';

  @override
  String loanRequestSent(String name) {
    return 'Request sent to $name';
  }

  @override
  String get loansTabActive => 'Active';

  @override
  String get loansTabRequests => 'Requests';

  @override
  String get loansTabHistory => 'History';

  @override
  String get loansEmptyActive => 'Books you borrow or lend will appear here.';

  @override
  String get loansEmptyRequests =>
      'No open requests. Find a book in Discover and ask to borrow it!';

  @override
  String get loansEmptyHistory => 'Finished loans will be kept here.';

  @override
  String get loanYouLend => 'You lend';

  @override
  String get loanYouBorrow => 'You borrow';

  @override
  String loanLentTo(String name) {
    return 'Lending to $name';
  }

  @override
  String loanBorrowedFrom(String name) {
    return 'Borrowing from $name';
  }

  @override
  String loanLineWantsToBorrow(String name) {
    return '$name would like to borrow it';
  }

  @override
  String loanLineWaitingAnswer(String name) {
    return 'Waiting for $name to answer';
  }

  @override
  String get loanLineArrangeHandover => 'Meet up and confirm the handover';

  @override
  String loanLineWaitingHandover(String name) {
    return 'Waiting for $name to confirm the handover';
  }

  @override
  String loanLineOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Overdue by $count days',
      one: 'Overdue by 1 day',
      zero: 'Due today',
    );
    return '$_temp0';
  }

  @override
  String loanLineExtensionAsked(String name, int days) {
    return '$name asks for $days more days';
  }

  @override
  String loanLineReturned(String date) {
    return 'Returned $date';
  }

  @override
  String get loanLineDeclined => 'Not this time';

  @override
  String get loanLineCancelled => 'Cancelled';

  @override
  String get loanNotFound => 'This loan isn\'t available.';

  @override
  String get loanChanged =>
      'This loan changed in the meantime. Here\'s the latest.';

  @override
  String loanDueOn(String date) {
    return 'Due back on $date';
  }

  @override
  String get loanHandoverTip =>
      'Agree on a public place to meet, like a café or library. When the book changes hands, both of you tap confirm.';

  @override
  String loanTheyConfirmed(String name) {
    return '$name has already confirmed.';
  }

  @override
  String loanMessageFrom(String name) {
    return 'Message from $name';
  }

  @override
  String get loanYourMessage => 'Your message';

  @override
  String get loanTimeline => 'History';

  @override
  String get loanAccept => 'Lend it';

  @override
  String get loanDecline => 'Not this time';

  @override
  String get loanAcceptTitle => 'How long can they keep it?';

  @override
  String loanAcceptHelp(String name) {
    return 'Choose a loan period for $name. The time starts when you hand over the book.';
  }

  @override
  String get loanDaysLabel => 'Days';

  @override
  String loanDaysRange(int min, int max) {
    return 'Between $min and $max days';
  }

  @override
  String loanAcceptedSnack(String name) {
    return 'Great! Now arrange the handover with $name.';
  }

  @override
  String get loanDeclineTitle => 'Say no kindly';

  @override
  String get loanDeclineReason => 'Reason (optional)';

  @override
  String get loanCancelRequest => 'Withdraw request';

  @override
  String get loanCallOff => 'Call off';

  @override
  String get loanConfirmGave => 'I handed it over';

  @override
  String get loanConfirmGot => 'I received the book';

  @override
  String get loanMarkReturned => 'I got my book back';

  @override
  String get loanReturnedSnack => 'Welcome back, book!';

  @override
  String get loanExtendAsk => 'Ask for more time';

  @override
  String get loanExtendTitle => 'How many more days?';

  @override
  String get loanExtraDaysLabel => 'Extra days';

  @override
  String loanExtendSent(String name) {
    return 'Asked $name for more time';
  }

  @override
  String loanExtendAccept(int days) {
    return 'Give $days more days';
  }

  @override
  String get loanExtendDecline => 'Keep the due date';

  @override
  String get eventRequested => 'Request sent';

  @override
  String eventAccepted(int days) {
    return 'Accepted for $days days';
  }

  @override
  String get eventDeclined => 'Declined';

  @override
  String get eventDeclinedOther => 'Lent to someone else';

  @override
  String get eventCancelled => 'Cancelled';

  @override
  String get eventHandoverByMe => 'You confirmed the handover';

  @override
  String get eventHandoverByThem => 'They confirmed the handover';

  @override
  String get eventStarted => 'Loan started';

  @override
  String eventExtensionRequested(int days) {
    return 'Asked for $days more days';
  }

  @override
  String get eventExtensionAccepted => 'Extension accepted';

  @override
  String get eventExtensionDeclined => 'Extension declined';

  @override
  String get eventReturned => 'Book returned';

  @override
  String get eventExpired =>
      'Cancelled automatically: no handover within 7 days';

  @override
  String loanAcceptSuggested(String name, int days, int pages) {
    return 'Based on $name\'s reading pace and the book\'s length ($pages pages), we suggest $days days. You can choose any length.';
  }

  @override
  String get readingTitle => 'Reading';

  @override
  String get readingLogButton => 'Log reading';

  @override
  String get readingLogTitle => 'What did you read?';

  @override
  String get readingPages => 'Pages read';

  @override
  String get readingHours => 'Hours';

  @override
  String get readingMinutes => 'Minutes';

  @override
  String get readingWhichBook => 'Book (optional)';

  @override
  String get readingNoBook => 'No specific book';

  @override
  String get readingChangeDate => 'Change';

  @override
  String get readingSave => 'Save';

  @override
  String get readingTimeInvalid =>
      'Please enter a reading time between 1 minute and 24 hours.';

  @override
  String get readingLogged => 'Nice reading! Saved.';

  @override
  String get readingFinishedRangeHelp => 'When did you start and finish it?';

  @override
  String get readingFinishedSaved =>
      'Finished! This helps us suggest fair loan times for you.';

  @override
  String get readingPrivacyNote =>
      'Your reading log is private. Lenders only see a suggested number of days, never your stats.';

  @override
  String get readingFinishedTitle => 'Finished books';

  @override
  String get readingFinishedEmpty => 'Mark a book as Read to add it here.';

  @override
  String readingFinishedLine(String date, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'read in $days days',
      one: 'read in 1 day',
    );
    return '$date · $_temp0';
  }

  @override
  String get readingSessionsTitle => 'Reading sessions';

  @override
  String get readingSessionsEmpty =>
      'No sessions yet. Log your reading to see your pace.';

  @override
  String readingSessionLine(int pages, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '$pages pages',
      one: '1 page',
    );
    return '$_temp0 in $minutes min';
  }

  @override
  String get statBooksThisYear => 'books this year';

  @override
  String get statPages30 => 'pages in 30 days';

  @override
  String get statPagesPerHour => 'pages per hour';

  @override
  String statPace(int pages) {
    return 'Your pace: about $pages pages a day';
  }

  @override
  String get statPaceNew =>
      'We start with a typical pace and learn yours as you finish books.';

  @override
  String statPaceLearned(int days) {
    return 'A 300-page book would get about $days days.';
  }

  @override
  String get statConfidence => 'How well we know your pace';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsEmptyTitle => 'All quiet';

  @override
  String get notificationsEmptyBody =>
      'Loan requests, handovers, reminders and friend requests will show up here.';

  @override
  String get notificationsUnread => 'Unread';

  @override
  String get notificationsView => 'View';

  @override
  String notifLoanRequested(String name, String title) {
    return '$name would like to borrow $title';
  }

  @override
  String notifLoanAccepted(String name, String title, int days) {
    return '$name will lend you $title for $days days. Arrange the handover!';
  }

  @override
  String notifLoanLentElsewhere(String title) {
    return '$title went to another neighbor this time';
  }

  @override
  String notifLoanDeclined(String name, String title) {
    return '$name can\'t lend $title this time';
  }

  @override
  String notifLoanCancelled(String name, String title) {
    return '$name called off the loan of $title';
  }

  @override
  String notifLoanHandover(String name, String title) {
    return '$name confirmed the handover of $title. Please confirm too.';
  }

  @override
  String notifLoanStarted(String title) {
    return 'The loan of $title has started';
  }

  @override
  String notifExtensionRequested(String name, String title, int days) {
    return '$name asks for $days more days with $title';
  }

  @override
  String notifExtensionAccepted(String name, String title) {
    return '$name gave you more time with $title';
  }

  @override
  String notifExtensionDeclined(String name, String title) {
    return '$name couldn\'t give you more time with $title';
  }

  @override
  String notifLoanReturned(String name, String title) {
    return '$name has $title back. How did it go?';
  }

  @override
  String notifLoanExpired(String title) {
    return 'The loan of $title was cancelled: no handover within 7 days';
  }

  @override
  String notifLoanDueSoon(String title, String name, String date) {
    return '$title is due back to $name on $date';
  }

  @override
  String notifLoanOverdue(String title, String name) {
    return '$title is overdue. Please bring it back to $name.';
  }

  @override
  String notifLoanOverdueOwner(String name, String title) {
    return '$name hasn\'t returned $title yet';
  }

  @override
  String notifFriendRequest(String name) {
    return '$name sent you a friend request';
  }

  @override
  String notifFriendAccepted(String name) {
    return '$name accepted your friend request';
  }

  @override
  String get notifGeneric => 'You have a new notification';

  @override
  String get report => 'Report';

  @override
  String get reportProblem => 'Report a problem';

  @override
  String reportTitle(String name) {
    return 'Report $name';
  }

  @override
  String get reportBody =>
      'Reports are private: the other person won\'t see who sent it.';

  @override
  String get reportNotReturned => 'The book was not returned';

  @override
  String get reportDamaged => 'The book came back damaged';

  @override
  String get reportNoShow => 'Didn\'t show up for the handover';

  @override
  String get reportInappropriate => 'Rude or inappropriate behavior';

  @override
  String get reportSpam => 'Spam or fake account';

  @override
  String get reportOther => 'Something else';

  @override
  String get reportDetails => 'What happened? (optional)';

  @override
  String reportAlsoBlock(String name) {
    return 'Also block $name';
  }

  @override
  String get reportSend => 'Send report';

  @override
  String get reportSent => 'Thank you. We\'ll look into it.';

  @override
  String feedbackQuestion(String name) {
    return 'How did it go with $name?';
  }

  @override
  String get feedbackUp => 'Went well';

  @override
  String get feedbackDown => 'Not great';

  @override
  String get feedbackPrivate =>
      'Only the total count of thumbs up is shown on profiles.';

  @override
  String get feedbackThanks => 'Thanks for your feedback!';

  @override
  String get feedbackGiven => 'Thanks, your feedback was saved.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacySubtitle => 'What we store and why';

  @override
  String get authPrivacyLink => 'How we handle your data';

  @override
  String get privacyDemoNote =>
      'VennskApp is a demo run by a private person for friends and neighbors. It is not a company service yet.';

  @override
  String get privacyDataTitle => 'What we store';

  @override
  String get privacyDataBody =>
      'Your email, name, username, an approximate area (about 1 km), your shelf, loans, friends, the reports you send and your reading log. We never store your address, phone number or exact location.';

  @override
  String get privacyWhoTitle => 'Who sees what';

  @override
  String get privacyWhoBody =>
      'You choose who sees your books and profile. Your reading log is only for you: lenders see just a suggested number of days. Others see your area name and a rounded distance, never your location.';

  @override
  String get privacyWhyTitle => 'Why';

  @override
  String get privacyWhyBody =>
      'Only to run the app: showing your books to the people you choose, arranging loans and sending reminders. No ads, no selling data, no tracking.';

  @override
  String get privacyWhereTitle => 'Where it is kept';

  @override
  String get privacyWhereBody =>
      'In a Supabase database. Book details come from Open Library and Google Books, so your search words are sent to them. The map uses OpenStreetMap.';

  @override
  String get privacyRightsTitle => 'Your rights';

  @override
  String get privacyRightsBody =>
      'Under GDPR and KVKK you can see, correct and delete your data. You can delete your account at any time on the Me tab, and everything about you is removed right away. For a copy of your data, ask the person who invited you.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountBody =>
      'This permanently removes your profile, shelf, reading log, friends, notifications and loan history. It can\'t be undone.';

  @override
  String get deleteAccountConfirm => 'Delete forever';

  @override
  String get deleteAccountOpenLoans =>
      'Please finish your open loans first: books you have lent or borrowed need to be returned.';

  @override
  String get deleteAccountDone =>
      'Your account was deleted. Take care, neighbor!';
}
