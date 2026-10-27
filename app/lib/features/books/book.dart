/// A row of the shared `books` catalog.
class Book {
  const Book({
    required this.id,
    required this.title,
    required this.authors,
    this.isbn13,
    this.pageCount,
    this.coverUrl,
    this.publishedYear,
  });

  final String id;
  final String title;
  final List<String> authors;
  final String? isbn13;
  final int? pageCount;
  final String? coverUrl;
  final int? publishedYear;

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'] as String,
    title: json['title'] as String,
    authors: (json['authors'] as List).cast<String>(),
    isbn13: json['isbn13'] as String?,
    pageCount: json['page_count'] as int?,
    coverUrl: json['cover_url'] as String?,
    publishedYear: json['published_year'] as int?,
  );
}

enum BookSource { openlibrary, google, manual }

/// Book metadata found via an external API or typed in, not yet in the catalog.
class BookCandidate {
  const BookCandidate({
    required this.title,
    required this.source,
    this.authors = const [],
    this.isbn13,
    this.pageCount,
    this.coverUrl,
    this.language,
    this.publishedYear,
    this.externalId,
  });

  final String title;
  final BookSource source;
  final List<String> authors;
  final String? isbn13;
  final int? pageCount;
  final String? coverUrl;
  final String? language;
  final int? publishedYear;
  final String? externalId;

  /// Payload for the `upsert_book` RPC.
  Map<String, dynamic> toJson() => {
    'title': title,
    'source': source.name,
    'authors': authors,
    'isbn13': isbn13,
    'page_count': pageCount,
    'cover_url': coverUrl,
    'language': language,
    'published_year': publishedYear,
    'external_id': externalId,
  };
}
