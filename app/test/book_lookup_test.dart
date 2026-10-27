import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vennskapp/features/books/book.dart';
import 'package:vennskapp/features/books/book_lookup.dart';

http.Response _json(Object body) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  test('ISBN lookup reads Open Library data', () async {
    final service = BookLookupService(
      MockClient((req) async {
        expect(req.url.host, 'openlibrary.org');
        return _json({
          'ISBN:9789750719387': {
            'title': 'Kürk Mantolu Madonna',
            'authors': [
              {'name': 'Sabahattin Ali'},
            ],
            'number_of_pages': 160,
            'publish_date': 'Mart 2017',
            'cover': {'medium': 'https://covers.openlibrary.org/b/id/1-M.jpg'},
            'key': '/books/OL1M',
          },
        });
      }),
    );

    final book = await service.byIsbn('9789750719387');
    expect(book!.title, 'Kürk Mantolu Madonna');
    expect(book.authors, ['Sabahattin Ali']);
    expect(book.pageCount, 160);
    expect(book.publishedYear, 2017);
    expect(book.source, BookSource.openlibrary);
  });

  test('falls back to Google Books when Open Library has nothing', () async {
    final service = BookLookupService(
      MockClient((req) async {
        if (req.url.host == 'openlibrary.org') return _json({});
        return _json({
          'items': [
            {
              'id': 'g1',
              'volumeInfo': {
                'title': 'Sult',
                'authors': ['Knut Hamsun'],
                'pageCount': 220,
                'publishedDate': '1890',
                'imageLinks': {'thumbnail': 'http://books.google.com/x.jpg'},
              },
            },
          ],
        });
      }),
    );

    final book = await service.byIsbn('9788205379118');
    expect(book!.title, 'Sult');
    expect(book.source, BookSource.google);
    expect(book.isbn13, '9788205379118');
    expect(book.coverUrl, startsWith('https://'));
  });

  test('network errors mean "not found", not a crash', () async {
    final service = BookLookupService(
      MockClient((_) async => throw http.ClientException('offline')),
    );
    expect(await service.byIsbn('9780141439518'), isNull);
    expect(await service.search('anything'), isEmpty);
  });

  test('parseYear finds the year in free text', () {
    expect(parseYear('March 2003'), 2003);
    expect(parseYear('1813'), 1813);
    expect(parseYear(null), isNull);
  });
}
