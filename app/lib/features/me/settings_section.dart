import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import '../../core/supabase.dart';
import '../profile/profile.dart';
import '../profile/profile_repository.dart';

/// Languages the app ships with, by `profiles.locale` code.
Map<String, String> appLanguages(AppLocalizations l10n) => {
  'en': l10n.languageEnglish,
  'tr': l10n.languageTurkish,
};

/// Language, privacy notice and account deletion on the Me tab.
class SettingsSection extends ConsumerWidget {
  const SettingsSection({super.key, required this.profile});

  final Profile profile;

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showDialog<String>(
      context: context,
      builder: (dialog) => SimpleDialog(
        title: Text(l10n.settingsLanguage),
        children: [
          RadioGroup<String>(
            groupValue: profile.locale,
            onChanged: (v) => Navigator.pop(dialog, v),
            child: Column(
              children: [
                for (final MapEntry(:key, :value) in appLanguages(l10n).entries)
                  RadioListTile<String>(value: key, title: Text(value)),
              ],
            ),
          ),
        ],
      ),
    );
    if (picked == null || picked == profile.locale) return;
    await ref.read(profileRepositoryProvider).setLocale(profile.id, picked);
    ref.invalidate(myProfileProvider);
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        icon: const Icon(Icons.warning_amber_outlined),
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l10n.deleteAccountConfirm),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final db = ref.read(supabaseProvider);
    try {
      await ref.read(profileRepositoryProvider).deleteMyAccount();
    } on PostgrestException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.code == '55000'
                ? l10n.deleteAccountOpenLoans
                : l10n.genericError(e.message),
          ),
        ),
      );
      return;
    }
    // The user no longer exists, so only the local session needs clearing.
    await db.auth.signOut(scope: SignOutScope.local);
    messenger.showSnackBar(SnackBar(content: Text(l10n.deleteAccountDone)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(l10n.settingsTitle, style: theme.textTheme.titleMedium),
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(l10n.settingsLanguage),
          subtitle: Text(
            appLanguages(l10n)[profile.locale] ?? l10n.languageEnglish,
          ),
          onTap: () => _pickLanguage(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: Text(l10n.privacyTitle),
          subtitle: Text(l10n.privacySubtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/privacy'),
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: Text(l10n.signOut),
          onTap: () => ref.read(supabaseProvider).auth.signOut(),
        ),
        ListTile(
          leading: Icon(
            Icons.delete_forever_outlined,
            color: theme.colorScheme.error,
          ),
          title: Text(
            l10n.deleteAccount,
            style: TextStyle(color: theme.colorScheme.error),
          ),
          onTap: () => _deleteAccount(context, ref),
        ),
      ],
    );
  }
}
