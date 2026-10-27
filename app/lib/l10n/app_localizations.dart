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

  /// No description provided for @loansEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No loans yet'**
  String get loansEmptyTitle;

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

  /// No description provided for @addBook.
  ///
  /// In en, this message translates to:
  /// **'Add book'**
  String get addBook;

  /// No description provided for @addScan.
  ///
  /// In en, this message translates to:
  /// **'Scan barcodes'**
  String get addScan;

  /// No description provided for @addScanHelp.
  ///
  /// In en, this message translates to:
  /// **'Fastest way to fill your shelf: scan one book after another.'**
  String get addScanHelp;

  /// No description provided for @addSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get addSearch;

  /// No description provided for @addSearchHelp.
  ///
  /// In en, this message translates to:
  /// **'Find a book by title, author or ISBN.'**
  String get addSearchHelp;

  /// No description provided for @addManual.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get addManual;

  /// No description provided for @addManualHelp.
  ///
  /// In en, this message translates to:
  /// **'For books without an ISBN, or when search can\'t find them.'**
  String get addManualHelp;

  /// No description provided for @addToShelf.
  ///
  /// In en, this message translates to:
  /// **'Add to my shelf'**
  String get addToShelf;

  /// No description provided for @addedToShelf.
  ///
  /// In en, this message translates to:
  /// **'Added “{title}” to your shelf'**
  String addedToShelf(String title);

  /// No description provided for @alreadyOnShelf.
  ///
  /// In en, this message translates to:
  /// **'“{title}” is already on your shelf'**
  String alreadyOnShelf(String title);

  /// No description provided for @onYourShelf.
  ///
  /// In en, this message translates to:
  /// **'On your shelf'**
  String get onYourShelf;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @shelfFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All ({count})'**
  String shelfFilterAll(int count);

  /// No description provided for @statusUnread.
  ///
  /// In en, this message translates to:
  /// **'Not read yet'**
  String get statusUnread;

  /// No description provided for @statusReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get statusReading;

  /// No description provided for @statusRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get statusRead;

  /// No description provided for @pageCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String pageCount(int count);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Title, author or ISBN'**
  String get searchHint;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that book. You can add it yourself.'**
  String get searchNoResults;

  /// No description provided for @scanTypeIsbn.
  ///
  /// In en, this message translates to:
  /// **'Type an ISBN'**
  String get scanTypeIsbn;

  /// No description provided for @scanInvalidIsbn.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a valid ISBN.'**
  String get scanInvalidIsbn;

  /// No description provided for @scanTorch.
  ///
  /// In en, this message translates to:
  /// **'Flashlight'**
  String get scanTorch;

  /// No description provided for @scanCameraError.
  ///
  /// In en, this message translates to:
  /// **'The camera isn\'t available. Check camera permission, or type the ISBN instead.'**
  String get scanCameraError;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the barcode on the back of a book. Keep going: each book is added automatically.'**
  String get scanHint;

  /// No description provided for @scanAddedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No books added yet} =1{1 book added} other{{count} books added}}'**
  String scanAddedCount(int count);

  /// No description provided for @scanLookingUp.
  ///
  /// In en, this message translates to:
  /// **'Looking up…'**
  String get scanLookingUp;

  /// No description provided for @scanAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get scanAdded;

  /// No description provided for @scanNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found online'**
  String get scanNotFound;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add'**
  String get scanFailed;

  /// No description provided for @manualTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get manualTitle;

  /// No description provided for @manualAuthors.
  ///
  /// In en, this message translates to:
  /// **'Author(s)'**
  String get manualAuthors;

  /// No description provided for @manualAuthorsHelp.
  ///
  /// In en, this message translates to:
  /// **'Separate several authors with commas.'**
  String get manualAuthorsHelp;

  /// No description provided for @manualIsbn.
  ///
  /// In en, this message translates to:
  /// **'ISBN (optional)'**
  String get manualIsbn;

  /// No description provided for @manualPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get manualPages;

  /// No description provided for @manualYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get manualYear;

  /// No description provided for @manualNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number.'**
  String get manualNumberInvalid;

  /// No description provided for @detailStatus.
  ///
  /// In en, this message translates to:
  /// **'My reading'**
  String get detailStatus;

  /// No description provided for @detailRating.
  ///
  /// In en, this message translates to:
  /// **'My rating'**
  String get detailRating;

  /// No description provided for @detailStars.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 star} other{{count} stars}}'**
  String detailStars(int count);

  /// No description provided for @detailReview.
  ///
  /// In en, this message translates to:
  /// **'My thoughts'**
  String get detailReview;

  /// No description provided for @detailReviewHint.
  ///
  /// In en, this message translates to:
  /// **'A few words for your neighbors (optional)'**
  String get detailReviewHint;

  /// No description provided for @detailLendable.
  ///
  /// In en, this message translates to:
  /// **'Happy to lend this book'**
  String get detailLendable;

  /// No description provided for @detailLendableHelp.
  ///
  /// In en, this message translates to:
  /// **'Neighbors who can see it may ask to borrow it.'**
  String get detailLendableHelp;

  /// No description provided for @detailVisibility.
  ///
  /// In en, this message translates to:
  /// **'Who can see this book'**
  String get detailVisibility;

  /// No description provided for @detailVisibilityDefault.
  ///
  /// In en, this message translates to:
  /// **'My default ({level})'**
  String detailVisibilityDefault(String level);

  /// No description provided for @removeTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from shelf?'**
  String get removeTitle;

  /// No description provided for @removeBody.
  ///
  /// In en, this message translates to:
  /// **'Your rating and thoughts about this book will be removed too.'**
  String get removeBody;

  /// No description provided for @discoverHint.
  ///
  /// In en, this message translates to:
  /// **'Which book are you looking for?'**
  String get discoverHint;

  /// No description provided for @discoverAroundYou.
  ///
  /// In en, this message translates to:
  /// **'Books on shelves around you'**
  String get discoverAroundYou;

  /// No description provided for @discoverResults.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 book found} other{{count} books found}}'**
  String discoverResults(int count);

  /// No description provided for @discoverNothingNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'No shared shelves yet'**
  String get discoverNothingNearbyTitle;

  /// No description provided for @discoverNothingNearbyBody.
  ///
  /// In en, this message translates to:
  /// **'When friends and neighbors add books, they show up here. Invite a friend to get started!'**
  String get discoverNothingNearbyBody;

  /// No description provided for @discoverNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Nobody nearby has this one yet'**
  String get discoverNoMatchTitle;

  /// No description provided for @discoverNoMatchBody.
  ///
  /// In en, this message translates to:
  /// **'Try another title or author, or add friends to see more shelves.'**
  String get discoverNoMatchBody;

  /// No description provided for @countFriends.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No friends yet} =1{1 friend} other{{count} friends}}'**
  String countFriends(int count);

  /// No description provided for @countNeighbors.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 neighbor} other{{count} neighbors}}'**
  String countNeighbors(int count);

  /// No description provided for @countOthers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more} other{{count} more}}'**
  String countOthers(int count);

  /// No description provided for @countCanLend.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 can lend it} other{{count} can lend it}}'**
  String countCanLend(int count);

  /// No description provided for @holdersCanLend.
  ///
  /// In en, this message translates to:
  /// **'Can lend it'**
  String get holdersCanLend;

  /// No description provided for @holdersNotLending.
  ///
  /// In en, this message translates to:
  /// **'Also on their shelves (not lending right now)'**
  String get holdersNotLending;

  /// No description provided for @holdersNone.
  ///
  /// In en, this message translates to:
  /// **'Nobody you can see has this book right now.'**
  String get holdersNone;

  /// No description provided for @relFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get relFriend;

  /// No description provided for @relNeighbor.
  ///
  /// In en, this message translates to:
  /// **'Neighbor'**
  String get relNeighbor;

  /// No description provided for @relOther.
  ///
  /// In en, this message translates to:
  /// **'On VennskApp'**
  String get relOther;

  /// No description provided for @relYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get relYou;

  /// No description provided for @distanceSameArea.
  ///
  /// In en, this message translates to:
  /// **'same area'**
  String get distanceSameArea;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'~{km} km'**
  String distanceKm(int km);

  /// No description provided for @personNotFound.
  ///
  /// In en, this message translates to:
  /// **'This person isn\'t available.'**
  String get personNotFound;

  /// No description provided for @personPrivateNote.
  ///
  /// In en, this message translates to:
  /// **'Their profile is private. You can still see books they chose to share.'**
  String get personPrivateNote;

  /// No description provided for @personShelf.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 book you can see} other{{count} books you can see}}'**
  String personShelf(int count);

  /// No description provided for @personShelfEmpty.
  ///
  /// In en, this message translates to:
  /// **'No books shared with you yet.'**
  String get personShelfEmpty;

  /// No description provided for @friendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendsTitle;

  /// No description provided for @friendsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get friendsAdd;

  /// No description provided for @friendsAddHelp.
  ///
  /// In en, this message translates to:
  /// **'Know someone on VennskApp? Add them by their username.'**
  String get friendsAddHelp;

  /// No description provided for @friendsIncoming.
  ///
  /// In en, this message translates to:
  /// **'Friend requests'**
  String get friendsIncoming;

  /// No description provided for @friendsIncomingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new request} other{{count} new requests}}'**
  String friendsIncomingCount(int count);

  /// No description provided for @friendsList.
  ///
  /// In en, this message translates to:
  /// **'Your friends'**
  String get friendsList;

  /// No description provided for @friendsOutgoing.
  ///
  /// In en, this message translates to:
  /// **'Waiting for an answer'**
  String get friendsOutgoing;

  /// No description provided for @friendsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get friendsBlocked;

  /// No description provided for @friendsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No friends yet. Friends can see the books you share with friends.'**
  String get friendsEmpty;

  /// No description provided for @friendRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent to @{name}'**
  String friendRequestSent(String name);

  /// No description provided for @friendNowFriends.
  ///
  /// In en, this message translates to:
  /// **'You and @{name} are now friends!'**
  String friendNowFriends(String name);

  /// No description provided for @friendNotFound.
  ///
  /// In en, this message translates to:
  /// **'No one with the username @{name}'**
  String friendNotFound(String name);

  /// No description provided for @friendIsMe.
  ///
  /// In en, this message translates to:
  /// **'That\'s you!'**
  String get friendIsMe;

  /// No description provided for @friendAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get friendAccept;

  /// No description provided for @friendDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get friendDecline;

  /// No description provided for @friendRequestSentCancel.
  ///
  /// In en, this message translates to:
  /// **'Request sent · Cancel'**
  String get friendRequestSentCancel;

  /// No description provided for @unfriend.
  ///
  /// In en, this message translates to:
  /// **'Remove friend'**
  String get unfriend;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @blockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block {name}?'**
  String blockTitle(String name);

  /// No description provided for @blockBody.
  ///
  /// In en, this message translates to:
  /// **'You won\'t see each other\'s books or profiles, and they can\'t send you requests. They won\'t be told.'**
  String get blockBody;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysCount(int count);

  /// No description provided for @holderAskToBorrow.
  ///
  /// In en, this message translates to:
  /// **'Ask to borrow'**
  String get holderAskToBorrow;

  /// No description provided for @holderRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get holderRequested;

  /// No description provided for @holderPromised.
  ///
  /// In en, this message translates to:
  /// **'Promised to you'**
  String get holderPromised;

  /// No description provided for @holderYouHaveIt.
  ///
  /// In en, this message translates to:
  /// **'You have it'**
  String get holderYouHaveIt;

  /// No description provided for @holderLentOut.
  ///
  /// In en, this message translates to:
  /// **'Lent out'**
  String get holderLentOut;

  /// No description provided for @loanDefaultMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi neighbor! I\'d love to read this book.'**
  String get loanDefaultMessage;

  /// No description provided for @loanRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Borrow “{title}”'**
  String loanRequestTitle(String title);

  /// No description provided for @loanRequestFrom.
  ///
  /// In en, this message translates to:
  /// **'from {name}'**
  String loanRequestFrom(String name);

  /// No description provided for @loanMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'A few friendly words'**
  String get loanMessageLabel;

  /// No description provided for @loanRequestTip.
  ///
  /// In en, this message translates to:
  /// **'After they say yes, you\'ll agree on where to meet. A café or library is a good public spot.'**
  String get loanRequestTip;

  /// No description provided for @loanRequestSend.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get loanRequestSend;

  /// No description provided for @loanRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent to {name}'**
  String loanRequestSent(String name);

  /// No description provided for @loansTabActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get loansTabActive;

  /// No description provided for @loansTabRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get loansTabRequests;

  /// No description provided for @loansTabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get loansTabHistory;

  /// No description provided for @loansEmptyActive.
  ///
  /// In en, this message translates to:
  /// **'Books you borrow or lend will appear here.'**
  String get loansEmptyActive;

  /// No description provided for @loansEmptyRequests.
  ///
  /// In en, this message translates to:
  /// **'No open requests. Find a book in Discover and ask to borrow it!'**
  String get loansEmptyRequests;

  /// No description provided for @loansEmptyHistory.
  ///
  /// In en, this message translates to:
  /// **'Finished loans will be kept here.'**
  String get loansEmptyHistory;

  /// No description provided for @loanYouLend.
  ///
  /// In en, this message translates to:
  /// **'You lend'**
  String get loanYouLend;

  /// No description provided for @loanYouBorrow.
  ///
  /// In en, this message translates to:
  /// **'You borrow'**
  String get loanYouBorrow;

  /// No description provided for @loanLentTo.
  ///
  /// In en, this message translates to:
  /// **'Lending to {name}'**
  String loanLentTo(String name);

  /// No description provided for @loanBorrowedFrom.
  ///
  /// In en, this message translates to:
  /// **'Borrowing from {name}'**
  String loanBorrowedFrom(String name);

  /// No description provided for @loanLineWantsToBorrow.
  ///
  /// In en, this message translates to:
  /// **'{name} would like to borrow it'**
  String loanLineWantsToBorrow(String name);

  /// No description provided for @loanLineWaitingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name} to answer'**
  String loanLineWaitingAnswer(String name);

  /// No description provided for @loanLineArrangeHandover.
  ///
  /// In en, this message translates to:
  /// **'Meet up and confirm the handover'**
  String get loanLineArrangeHandover;

  /// No description provided for @loanLineWaitingHandover.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name} to confirm the handover'**
  String loanLineWaitingHandover(String name);

  /// No description provided for @loanLineOverdue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Due today} =1{Overdue by 1 day} other{Overdue by {count} days}}'**
  String loanLineOverdue(int count);

  /// No description provided for @loanLineExtensionAsked.
  ///
  /// In en, this message translates to:
  /// **'{name} asks for {days} more days'**
  String loanLineExtensionAsked(String name, int days);

  /// No description provided for @loanLineReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned {date}'**
  String loanLineReturned(String date);

  /// No description provided for @loanLineDeclined.
  ///
  /// In en, this message translates to:
  /// **'Not this time'**
  String get loanLineDeclined;

  /// No description provided for @loanLineCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get loanLineCancelled;

  /// No description provided for @loanNotFound.
  ///
  /// In en, this message translates to:
  /// **'This loan isn\'t available.'**
  String get loanNotFound;

  /// No description provided for @loanChanged.
  ///
  /// In en, this message translates to:
  /// **'This loan changed in the meantime. Here\'s the latest.'**
  String get loanChanged;

  /// No description provided for @loanDueOn.
  ///
  /// In en, this message translates to:
  /// **'Due back on {date}'**
  String loanDueOn(String date);

  /// No description provided for @loanHandoverTip.
  ///
  /// In en, this message translates to:
  /// **'Agree on a public place to meet, like a café or library. When the book changes hands, both of you tap confirm.'**
  String get loanHandoverTip;

  /// No description provided for @loanTheyConfirmed.
  ///
  /// In en, this message translates to:
  /// **'{name} has already confirmed.'**
  String loanTheyConfirmed(String name);

  /// No description provided for @loanMessageFrom.
  ///
  /// In en, this message translates to:
  /// **'Message from {name}'**
  String loanMessageFrom(String name);

  /// No description provided for @loanYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get loanYourMessage;

  /// No description provided for @loanTimeline.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get loanTimeline;

  /// No description provided for @loanAccept.
  ///
  /// In en, this message translates to:
  /// **'Lend it'**
  String get loanAccept;

  /// No description provided for @loanDecline.
  ///
  /// In en, this message translates to:
  /// **'Not this time'**
  String get loanDecline;

  /// No description provided for @loanAcceptTitle.
  ///
  /// In en, this message translates to:
  /// **'How long can they keep it?'**
  String get loanAcceptTitle;

  /// No description provided for @loanAcceptHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose a loan period for {name}. The time starts when you hand over the book.'**
  String loanAcceptHelp(String name);

  /// No description provided for @loanDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get loanDaysLabel;

  /// No description provided for @loanDaysRange.
  ///
  /// In en, this message translates to:
  /// **'Between {min} and {max} days'**
  String loanDaysRange(int min, int max);

  /// No description provided for @loanAcceptedSnack.
  ///
  /// In en, this message translates to:
  /// **'Great! Now arrange the handover with {name}.'**
  String loanAcceptedSnack(String name);

  /// No description provided for @loanDeclineTitle.
  ///
  /// In en, this message translates to:
  /// **'Say no kindly'**
  String get loanDeclineTitle;

  /// No description provided for @loanDeclineReason.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get loanDeclineReason;

  /// No description provided for @loanCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Withdraw request'**
  String get loanCancelRequest;

  /// No description provided for @loanCallOff.
  ///
  /// In en, this message translates to:
  /// **'Call off'**
  String get loanCallOff;

  /// No description provided for @loanConfirmGave.
  ///
  /// In en, this message translates to:
  /// **'I handed it over'**
  String get loanConfirmGave;

  /// No description provided for @loanConfirmGot.
  ///
  /// In en, this message translates to:
  /// **'I received the book'**
  String get loanConfirmGot;

  /// No description provided for @loanMarkReturned.
  ///
  /// In en, this message translates to:
  /// **'I got my book back'**
  String get loanMarkReturned;

  /// No description provided for @loanReturnedSnack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, book!'**
  String get loanReturnedSnack;

  /// No description provided for @loanExtendAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask for more time'**
  String get loanExtendAsk;

  /// No description provided for @loanExtendTitle.
  ///
  /// In en, this message translates to:
  /// **'How many more days?'**
  String get loanExtendTitle;

  /// No description provided for @loanExtraDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Extra days'**
  String get loanExtraDaysLabel;

  /// No description provided for @loanExtendSent.
  ///
  /// In en, this message translates to:
  /// **'Asked {name} for more time'**
  String loanExtendSent(String name);

  /// No description provided for @loanExtendAccept.
  ///
  /// In en, this message translates to:
  /// **'Give {days} more days'**
  String loanExtendAccept(int days);

  /// No description provided for @loanExtendDecline.
  ///
  /// In en, this message translates to:
  /// **'Keep the due date'**
  String get loanExtendDecline;

  /// No description provided for @eventRequested.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get eventRequested;

  /// No description provided for @eventAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted for {days} days'**
  String eventAccepted(int days);

  /// No description provided for @eventDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get eventDeclined;

  /// No description provided for @eventDeclinedOther.
  ///
  /// In en, this message translates to:
  /// **'Lent to someone else'**
  String get eventDeclinedOther;

  /// No description provided for @eventCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get eventCancelled;

  /// No description provided for @eventHandoverByMe.
  ///
  /// In en, this message translates to:
  /// **'You confirmed the handover'**
  String get eventHandoverByMe;

  /// No description provided for @eventHandoverByThem.
  ///
  /// In en, this message translates to:
  /// **'They confirmed the handover'**
  String get eventHandoverByThem;

  /// No description provided for @eventStarted.
  ///
  /// In en, this message translates to:
  /// **'Loan started'**
  String get eventStarted;

  /// No description provided for @eventExtensionRequested.
  ///
  /// In en, this message translates to:
  /// **'Asked for {days} more days'**
  String eventExtensionRequested(int days);

  /// No description provided for @eventExtensionAccepted.
  ///
  /// In en, this message translates to:
  /// **'Extension accepted'**
  String get eventExtensionAccepted;

  /// No description provided for @eventExtensionDeclined.
  ///
  /// In en, this message translates to:
  /// **'Extension declined'**
  String get eventExtensionDeclined;

  /// No description provided for @eventReturned.
  ///
  /// In en, this message translates to:
  /// **'Book returned'**
  String get eventReturned;

  /// No description provided for @eventExpired.
  ///
  /// In en, this message translates to:
  /// **'Cancelled automatically: no handover within 7 days'**
  String get eventExpired;

  /// No description provided for @loanAcceptSuggested.
  ///
  /// In en, this message translates to:
  /// **'Based on {name}\'s reading pace and the book\'s length ({pages} pages), we suggest {days} days. You can choose any length.'**
  String loanAcceptSuggested(String name, int days, int pages);

  /// No description provided for @readingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get readingTitle;

  /// No description provided for @readingLogButton.
  ///
  /// In en, this message translates to:
  /// **'Log reading'**
  String get readingLogButton;

  /// No description provided for @readingLogTitle.
  ///
  /// In en, this message translates to:
  /// **'What did you read?'**
  String get readingLogTitle;

  /// No description provided for @readingPages.
  ///
  /// In en, this message translates to:
  /// **'Pages read'**
  String get readingPages;

  /// No description provided for @readingHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get readingHours;

  /// No description provided for @readingMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get readingMinutes;

  /// No description provided for @readingWhichBook.
  ///
  /// In en, this message translates to:
  /// **'Book (optional)'**
  String get readingWhichBook;

  /// No description provided for @readingNoBook.
  ///
  /// In en, this message translates to:
  /// **'No specific book'**
  String get readingNoBook;

  /// No description provided for @readingChangeDate.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get readingChangeDate;

  /// No description provided for @readingSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get readingSave;

  /// No description provided for @readingTimeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reading time between 1 minute and 24 hours.'**
  String get readingTimeInvalid;

  /// No description provided for @readingLogged.
  ///
  /// In en, this message translates to:
  /// **'Nice reading! Saved.'**
  String get readingLogged;

  /// No description provided for @readingFinishedRangeHelp.
  ///
  /// In en, this message translates to:
  /// **'When did you start and finish it?'**
  String get readingFinishedRangeHelp;

  /// No description provided for @readingFinishedSaved.
  ///
  /// In en, this message translates to:
  /// **'Finished! This helps us suggest fair loan times for you.'**
  String get readingFinishedSaved;

  /// No description provided for @readingPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your reading log is private. Lenders only see a suggested number of days, never your stats.'**
  String get readingPrivacyNote;

  /// No description provided for @readingFinishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Finished books'**
  String get readingFinishedTitle;

  /// No description provided for @readingFinishedEmpty.
  ///
  /// In en, this message translates to:
  /// **'Mark a book as Read to add it here.'**
  String get readingFinishedEmpty;

  /// No description provided for @readingFinishedLine.
  ///
  /// In en, this message translates to:
  /// **'{date} · {days, plural, =1{read in 1 day} other{read in {days} days}}'**
  String readingFinishedLine(String date, int days);

  /// No description provided for @readingSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading sessions'**
  String get readingSessionsTitle;

  /// No description provided for @readingSessionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet. Log your reading to see your pace.'**
  String get readingSessionsEmpty;

  /// No description provided for @readingSessionLine.
  ///
  /// In en, this message translates to:
  /// **'{pages, plural, =1{1 page} other{{pages} pages}} in {minutes} min'**
  String readingSessionLine(int pages, int minutes);

  /// No description provided for @statBooksThisYear.
  ///
  /// In en, this message translates to:
  /// **'books this year'**
  String get statBooksThisYear;

  /// No description provided for @statPages30.
  ///
  /// In en, this message translates to:
  /// **'pages in 30 days'**
  String get statPages30;

  /// No description provided for @statPagesPerHour.
  ///
  /// In en, this message translates to:
  /// **'pages per hour'**
  String get statPagesPerHour;

  /// No description provided for @statPace.
  ///
  /// In en, this message translates to:
  /// **'Your pace: about {pages} pages a day'**
  String statPace(int pages);

  /// No description provided for @statPaceNew.
  ///
  /// In en, this message translates to:
  /// **'We start with a typical pace and learn yours as you finish books.'**
  String get statPaceNew;

  /// No description provided for @statPaceLearned.
  ///
  /// In en, this message translates to:
  /// **'A 300-page book would get about {days} days.'**
  String statPaceLearned(int days);

  /// No description provided for @statConfidence.
  ///
  /// In en, this message translates to:
  /// **'How well we know your pace'**
  String get statConfidence;
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
