import 'package:flutter/material.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import 'library_item.dart';

extension ReadingStatusLabels on ReadingStatus {
  String label(AppLocalizations l10n) => switch (this) {
    ReadingStatus.unread => l10n.statusUnread,
    ReadingStatus.reading => l10n.statusReading,
    ReadingStatus.read => l10n.statusRead,
  };

  IconData get icon => switch (this) {
    ReadingStatus.unread => Icons.bookmark_border,
    ReadingStatus.reading => Icons.menu_book,
    ReadingStatus.read => Icons.check_circle_outline,
  };
}
