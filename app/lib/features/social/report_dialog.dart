import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import 'social_repository.dart';

/// Reasons stored in `public.reports.reason`.
const _loanReasons = ['not_returned', 'damaged', 'no_show'];
const _generalReasons = ['inappropriate', 'spam', 'other'];

String reportReasonLabel(AppLocalizations l10n, String reason) =>
    switch (reason) {
      'not_returned' => l10n.reportNotReturned,
      'damaged' => l10n.reportDamaged,
      'no_show' => l10n.reportNoShow,
      'inappropriate' => l10n.reportInappropriate,
      'spam' => l10n.reportSpam,
      _ => l10n.reportOther,
    };

/// Asks why, saves the report and optionally blocks the person too.
Future<void> showReportDialog(
  BuildContext context,
  WidgetRef ref, {
  required String personId,
  required String name,
  String? loanId,
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final reasons = [if (loanId != null) ..._loanReasons, ..._generalReasons];
  final details = TextEditingController();
  var reason = reasons.first;
  var alsoBlock = false;

  final ok = await showDialog<bool>(
    context: context,
    builder: (dialog) => StatefulBuilder(
      builder: (dialog, setDialogState) => AlertDialog(
        title: Text(l10n.reportTitle(name)),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.reportBody),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: reason,
              onChanged: (v) => setDialogState(() => reason = v ?? reason),
              child: Column(
                children: [
                  for (final r in reasons)
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: r,
                      title: Text(reportReasonLabel(l10n, r)),
                    ),
                ],
              ),
            ),
            TextField(
              controller: details,
              maxLength: 1000,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(labelText: l10n.reportDetails),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: alsoBlock,
              onChanged: (v) => setDialogState(() => alsoBlock = v ?? false),
              title: Text(l10n.reportAlsoBlock(name)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l10n.reportSend),
          ),
        ],
      ),
    ),
  );
  final text = details.text.trim();
  details.dispose();
  if (ok != true) return;

  try {
    final repo = ref.read(socialRepositoryProvider);
    await repo.report(
      personId,
      reason: reason,
      details: text.isEmpty ? null : text,
      loanId: loanId,
    );
    if (alsoBlock) await repo.block(personId);
    messenger.showSnackBar(SnackBar(content: Text(l10n.reportSent)));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.genericError('$e'))));
  }
  invalidateSocial(ref, personId);
}
