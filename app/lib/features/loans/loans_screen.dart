import 'package:flutter/material.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import '../shell/empty_state.dart';

class LoansScreen extends StatelessWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabLoans)),
      body: EmptyState(
        icon: Icons.swap_horiz,
        title: l10n.loansEmptyTitle,
        body: l10n.loansEmptyBody,
      ),
    );
  }
}
