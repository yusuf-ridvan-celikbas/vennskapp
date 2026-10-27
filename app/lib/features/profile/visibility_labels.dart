import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'profile.dart';

extension VisibilityLabels on VisibilityLevel {
  String label(AppLocalizations l10n) => switch (this) {
        VisibilityLevel.private => l10n.visibilityPrivate,
        VisibilityLevel.friends => l10n.visibilityFriends,
        VisibilityLevel.neighbors => l10n.visibilityNeighbors,
        VisibilityLevel.public => l10n.visibilityPublic,
      };

  String explanation(AppLocalizations l10n) => switch (this) {
        VisibilityLevel.private => l10n.visibilityPrivateHelp,
        VisibilityLevel.friends => l10n.visibilityFriendsHelp,
        VisibilityLevel.neighbors => l10n.visibilityNeighborsHelp,
        VisibilityLevel.public => l10n.visibilityPublicHelp,
      };

  IconData get icon => switch (this) {
        VisibilityLevel.private => Icons.lock_outline,
        VisibilityLevel.friends => Icons.people_outline,
        VisibilityLevel.neighbors => Icons.holiday_village_outlined,
        VisibilityLevel.public => Icons.public,
      };
}
