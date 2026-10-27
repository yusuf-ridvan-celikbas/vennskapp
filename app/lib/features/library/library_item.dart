import '../books/book.dart';
import '../profile/profile.dart';

enum ReadingStatus { unread, reading, read }

/// The user's own copy of a book, with their personal notes about it.
class LibraryItem {
  const LibraryItem({
    required this.id,
    required this.book,
    required this.status,
    required this.lendable,
    this.rating,
    this.review,
    this.visibility,
  });

  final String id;
  final Book book;
  final ReadingStatus status;
  final bool lendable;
  final int? rating;
  final String? review;

  /// null = follow the profile default.
  final VisibilityLevel? visibility;

  factory LibraryItem.fromJson(Map<String, dynamic> json) => LibraryItem(
    id: json['id'] as String,
    book: Book.fromJson(json['books'] as Map<String, dynamic>),
    status: ReadingStatus.values.byName(json['status'] as String),
    lendable: json['lendable'] as bool,
    rating: json['rating'] as int?,
    review: json['review'] as String?,
    visibility: json['visibility'] == null
        ? null
        : VisibilityLevel.fromDb(json['visibility'] as String),
  );
}

/// Fields the owner can change on their copy. Only non-null fields are sent,
/// except the ones listed in [clear].
class LibraryItemChanges {
  const LibraryItemChanges({
    this.status,
    this.lendable,
    this.rating,
    this.review,
    this.visibility,
    this.clear = const {},
  });

  final ReadingStatus? status;
  final bool? lendable;
  final int? rating;
  final String? review;
  final VisibilityLevel? visibility;

  /// Column names to set to null, e.g. {'visibility'} to use the default.
  final Set<String> clear;

  Map<String, dynamic> toJson() => {
    if (status != null) 'status': status!.name,
    if (lendable != null) 'lendable': lendable,
    if (rating != null) 'rating': rating,
    if (review != null) 'review': review,
    if (visibility != null) 'visibility': visibility!.name,
    for (final column in clear) column: null,
  };
}
