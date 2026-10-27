import 'package:flutter/material.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

/// Plain-language privacy notice (GDPR / KVKK basics). Open to signed-out
/// visitors too, so people can read it before creating an account.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final sections = [
      (Icons.inventory_2_outlined, l10n.privacyDataTitle, l10n.privacyDataBody),
      (Icons.visibility_outlined, l10n.privacyWhoTitle, l10n.privacyWhoBody),
      (Icons.favorite_border, l10n.privacyWhyTitle, l10n.privacyWhyBody),
      (Icons.cloud_outlined, l10n.privacyWhereTitle, l10n.privacyWhereBody),
      (Icons.gavel_outlined, l10n.privacyRightsTitle, l10n.privacyRightsBody),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: theme.colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.privacyDemoNote),
                ),
              ),
              for (final (icon, title, body) in sections)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: Icon(icon, color: theme.colorScheme.primary),
                  title: Text(title, style: theme.textTheme.titleMedium),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(body),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
