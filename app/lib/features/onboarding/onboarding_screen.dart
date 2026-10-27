import 'package:flutter/material.dart';
import 'package:vennskapp/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase.dart';
import '../profile/profile.dart';
import '../profile/profile_repository.dart';
import '../profile/visibility_labels.dart';
import 'location_picker.dart';

final _usernamePattern = RegExp(r'^[a-z0-9_]{3,20}$');

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _form = GlobalKey<FormState>();
  final _displayName = TextEditingController();
  final _username = TextEditingController();
  final _area = TextEditingController();
  LatLng? _home;
  VisibilityLevel _visibility = VisibilityLevel.neighbors;
  String? _usernameTaken;
  bool _busy = false;

  @override
  void dispose() {
    _displayName.dispose();
    _username.dispose();
    _area.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _usernameTaken = null);
    if (!_form.currentState!.validate()) return;
    if (_home == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.locationRequired)));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .completeOnboarding(
            userId: ref.read(currentUserIdProvider)!,
            username: _username.text.trim().toLowerCase(),
            displayName: _displayName.text.trim(),
            defaultVisibility: _visibility,
            lat: _home!.latitude,
            lon: _home!.longitude,
            areaName: _area.text.trim(),
          );
      ref.invalidate(myProfileProvider);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        setState(() => _usernameTaken = l10n.onboardingUsernameTaken);
        _form.currentState!.validate();
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.genericError(e.message))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingTitle),
        actions: [
          TextButton(
            onPressed: () => ref.read(supabaseProvider).auth.signOut(),
            child: Text(l10n.signOut),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.onboardingIntro, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _displayName,
                    decoration: InputDecoration(
                      labelText: l10n.onboardingDisplayName,
                    ),
                    textCapitalization: TextCapitalization.words,
                    maxLength: 50,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.fieldRequired
                        : null,
                  ),
                  TextFormField(
                    controller: _username,
                    decoration: InputDecoration(
                      labelText: l10n.onboardingUsername,
                      prefixText: '@',
                      helperText: l10n.onboardingUsernameHelp,
                    ),
                    autocorrect: false,
                    maxLength: 20,
                    validator: (v) {
                      if (_usernameTaken != null) return _usernameTaken;
                      final value = (v ?? '').trim().toLowerCase();
                      return _usernamePattern.hasMatch(value)
                          ? null
                          : l10n.onboardingUsernameInvalid;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.onboardingWhereTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  LocationPicker(
                    value: _home,
                    onChanged: (p) => setState(() => _home = p),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _area,
                    decoration: InputDecoration(
                      labelText: l10n.onboardingAreaName,
                      helperText: l10n.onboardingAreaNameHelp,
                    ),
                    textCapitalization: TextCapitalization.words,
                    maxLength: 60,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.fieldRequired
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.onboardingVisibilityTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  RadioGroup<VisibilityLevel>(
                    groupValue: _visibility,
                    onChanged: (v) => setState(() => _visibility = v!),
                    child: Column(
                      children: [
                        for (final level in VisibilityLevel.values)
                          RadioListTile<VisibilityLevel>(
                            value: level,
                            secondary: Icon(level.icon),
                            title: Text(level.label(l10n)),
                            subtitle: Text(level.explanation(l10n)),
                            contentPadding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: Text(l10n.onboardingFinish),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
