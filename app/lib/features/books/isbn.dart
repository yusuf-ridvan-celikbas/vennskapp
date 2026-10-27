/// ISBN helpers. Everything is normalised to ISBN-13 before it is stored.
library;

String _digits(String raw) =>
    raw.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();

bool isValidIsbn13(String isbn) {
  if (!RegExp(r'^97[89][0-9]{10}$').hasMatch(isbn)) return false;
  var sum = 0;
  for (var i = 0; i < 12; i++) {
    sum += int.parse(isbn[i]) * (i.isEven ? 1 : 3);
  }
  return (10 - sum % 10) % 10 == int.parse(isbn[12]);
}

bool isValidIsbn10(String isbn) {
  if (!RegExp(r'^[0-9]{9}[0-9X]$').hasMatch(isbn)) return false;
  var sum = 0;
  for (var i = 0; i < 10; i++) {
    final v = isbn[i] == 'X' ? 10 : int.parse(isbn[i]);
    sum += v * (10 - i);
  }
  return sum % 11 == 0;
}

String isbn10To13(String isbn10) {
  final core = '978${isbn10.substring(0, 9)}';
  var sum = 0;
  for (var i = 0; i < 12; i++) {
    sum += int.parse(core[i]) * (i.isEven ? 1 : 3);
  }
  return '$core${(10 - sum % 10) % 10}';
}

/// Returns a valid ISBN-13 for any ISBN-10/13 input (with or without dashes),
/// or null if the input is not a valid ISBN.
String? normalizeIsbn(String raw) {
  final d = _digits(raw);
  if (d.length == 13 && isValidIsbn13(d)) return d;
  if (d.length == 10 && isValidIsbn10(d)) return isbn10To13(d);
  return null;
}
