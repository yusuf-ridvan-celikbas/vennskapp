import 'package:flutter/material.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import '../shell/empty_state.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabDiscover)),
      body: EmptyState(
        icon: Icons.travel_explore,
        title: l10n.discoverEmptyTitle,
        body: l10n.discoverEmptyBody,
      ),
    );
  }
}
