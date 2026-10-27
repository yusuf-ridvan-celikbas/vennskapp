import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'book.dart';
import 'isbn.dart';

/// Looks up book metadata: Open Library first (no key needed), Google Books as
/// a fallback when Open Library has nothing.
class BookLookupService {
  BookLookupService(this._client, {this.googleApiKey = ''});

  final http.Client _client;

  /// Free key from Google Cloud; without one the shared quota is often empty.
  final String googleApiKey;

  // Browsers forbid setting User-Agent; Open Library asks apps to identify.
  static const _headers = kIsWeb
      ? <String, String>{}
      : {'User-Agent': 'VennskApp/0.1 (prototype; book sharing)'};

  Future<BookCandidate?> byIsbn(String isbn13) async {
    return await _openLibraryByIsbn(isbn13) ??
        await _googleSearch(
          'isbn:$isbn13',
          isbn13: isbn13,
        ).then((r) => r.firstOrNull);
  }

  Future<List<BookCandidate>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final isbn = normalizeIsbn(q);
    if (isbn != null) {
      final hit = await byIsbn(isbn);
      return hit == null ? const [] : [hit];
    }
    final ol = await _openLibrarySearch(q);
    return ol.isNotEmpty ? ol : _googleSearch(q);
  }

  Future<Map<String, dynamic>?> _getJson(Uri uri) async {
    try {
      final res = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      return null; // offline, timeout or bad JSON: treat as "not found"
    }
  }

  Future<BookCandidate?> _openLibraryByIsbn(String isbn13) async {
    final json = await _getJson(
      Uri.https('openlibrary.org', '/api/books', {
        'bibkeys': 'ISBN:$isbn13',
        'format': 'json',
        'jscmd': 'data',
      }),
    );
    final data = json?['ISBN:$isbn13'] as Map<String, dynamic>?;
    if (data == null || data['title'] == null) return null;
    return BookCandidate(
      title: data['title'] as String,
      source: BookSource.openlibrary,
      isbn13: isbn13,
      authors: [
        for (final a in (data['authors'] as List? ?? const []))
          (a as Map)['name'] as String,
      ],
      pageCount: data['number_of_pages'] as int?,
      coverUrl: (data['cover'] as Map?)?['medium'] as String?,
      publishedYear: parseYear(data['publish_date'] as String?),
      externalId: data['key'] as String?,
    );
  }

  Future<List<BookCandidate>> _openLibrarySearch(String q) async {
    final json = await _getJson(
      Uri.https('openlibrary.org', '/search.json', {
        'q': q,
        'limit': '20',
        'fields': 'key,title,author_name,first_publish_year,isbn,number_of_pages_median,cover_i,language',
      }),
    );
    final docs = (json?['docs'] as List?) ?? const [];
    return [
      for (final d in docs.cast<Map<String, dynamic>>())
        if (d['title'] != null)
          BookCandidate(
            title: d['title'] as String,
            source: BookSource.openlibrary,
            authors: (d['author_name'] as List? ?? const []).cast<String>(),
            isbn13: _firstIsbn13((d['isbn'] as List?)?.cast<String>()),
            pageCount: d['number_of_pages_median'] as int?,
            coverUrl: d['cover_i'] == null
                ? null
                : 'https://covers.openlibrary.org/b/id/${d['cover_i']}-M.jpg',
            language: (d['language'] as List?)?.firstOrNull as String?,
            publishedYear: d['first_publish_year'] as int?,
            externalId: d['key'] as String?,
          ),
    ];
  }

  Future<List<BookCandidate>> _googleSearch(String q, {String? isbn13}) async {
    final json = await _getJson(
      Uri.https('www.googleapis.com', '/books/v1/volumes', {
        'q': q,
        'maxResults': '20',
        if (googleApiKey.isNotEmpty) 'key': googleApiKey,
      }),
    );
    final items = (json?['items'] as List?) ?? const [];
    return [
      for (final item in items.cast<Map<String, dynamic>>())
        if ((item['volumeInfo'] as Map?)?['title'] != null)
          _fromGoogle(item, isbn13),
    ];
  }

  BookCandidate _fromGoogle(Map<String, dynamic> item, String? isbn13) {
    final info = item['volumeInfo'] as Map<String, dynamic>;
    final ids = (info['industryIdentifiers'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    final found = ids
        .where((i) => i['type'] == 'ISBN_13')
        .map((i) => i['identifier'] as String);
    final thumb = (info['imageLinks'] as Map?)?['thumbnail'] as String?;
    return BookCandidate(
      title: info['title'] as String,
      source: BookSource.google,
      authors: (info['authors'] as List? ?? const []).cast<String>(),
      isbn13: isbn13 ?? _firstIsbn13(found.toList()),
      pageCount: info['pageCount'] as int?,
      coverUrl: thumb?.replaceFirst('http://', 'https://'),
      language: info['language'] as String?,
      publishedYear: parseYear(info['publishedDate'] as String?),
      externalId: item['id'] as String?,
    );
  }

  static String? _firstIsbn13(List<String>? isbns) {
    for (final raw in isbns ?? const <String>[]) {
      final n = normalizeIsbn(raw);
      if (n != null) return n;
    }
    return null;
  }
}

/// Picks the first 4-digit year out of strings like "March 2003" or "1813".
int? parseYear(String? text) {
  final m = RegExp(r'\b(\d{4})\b').firstMatch(text ?? '');
  return m == null ? null : int.parse(m.group(1)!);
}

final bookLookupProvider = Provider((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return BookLookupService(
    client,
    googleApiKey: const String.fromEnvironment('GOOGLE_BOOKS_API_KEY'),
  );
});
