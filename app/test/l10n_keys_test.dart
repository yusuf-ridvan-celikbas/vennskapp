import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every translation file must define exactly the keys of the English template.
void main() {
  Set<String> keysOf(File file) {
    final map = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return map.keys.where((k) => !k.startsWith('@')).toSet();
  }

  test('all ARB files have the same keys as app_en.arb', () {
    final dir = Directory('lib/l10n');
    final template = keysOf(File('lib/l10n/app_en.arb'));
    final others = dir.listSync().whereType<File>().where(
      (f) => f.path.endsWith('.arb') && !f.path.endsWith('app_en.arb'),
    );

    for (final file in others) {
      final keys = keysOf(file);
      expect(
        template.difference(keys),
        isEmpty,
        reason: '${file.path} is missing keys',
      );
      expect(
        keys.difference(template),
        isEmpty,
        reason: '${file.path} has unknown keys',
      );
    }
  });
}
