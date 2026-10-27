import 'package:flutter_test/flutter_test.dart';
import 'package:vennskapp/features/books/isbn.dart';

void main() {
  test('valid ISBN-13 passes, wrong checksum fails', () {
    expect(isValidIsbn13('9780141439518'), isTrue);
    expect(isValidIsbn13('9780141439519'), isFalse);
    expect(isValidIsbn13('1234567890123'), isFalse); // not 978/979
  });

  test('ISBN-10 converts to ISBN-13', () {
    expect(normalizeIsbn('0-14-143951-3'), '9780141439518');
    expect(normalizeIsbn('080442957X'), '9780804429573');
  });

  test('dashes and spaces are ignored', () {
    expect(normalizeIsbn('978-0-14-143951-8'), '9780141439518');
    expect(normalizeIsbn(' 978 0141 439518 '), '9780141439518');
  });

  test('garbage is rejected', () {
    expect(normalizeIsbn(''), isNull);
    expect(normalizeIsbn('hello'), isNull);
    expect(normalizeIsbn('4006381333931'), isNull); // a non-book EAN
  });
}
