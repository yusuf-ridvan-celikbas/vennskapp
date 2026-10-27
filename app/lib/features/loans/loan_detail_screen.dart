import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import '../../core/supabase.dart';
import '../books/book_cover.dart';
import '../discover/discover_repository.dart';
import 'loan.dart';
import 'loan_labels.dart';
import 'loans_repository.dart';

/// One loan: who, what, where it stands, and the actions available now.
class LoanDetailScreen extends ConsumerWidget {
  const LoanDetailScreen({super.key, required this.loanId});

  final String loanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final loan = ref.watch(loanProvider(loanId));
    return Scaffold(
      appBar: AppBar(),
      body: switch (loan) {
        AsyncData(:final value) when value == null => Center(
          child: Text(l10n.loanNotFound),
        ),
        AsyncData(:final value) => _LoanBody(loan: value!),
        AsyncError(:final error) => Center(
          child: Text(l10n.genericError('$error')),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _LoanBody extends ConsumerStatefulWidget {
  const _LoanBody({required this.loan});

  final Loan loan;

  @override
  ConsumerState<_LoanBody> createState() => _LoanBodyState();
}

class _LoanBodyState extends ConsumerState<_LoanBody> {
  bool _busy = false;

  Loan get loan => widget.loan;

  Future<void> _run(
    Future<void> Function(LoansRepository repo) action, {
    String? done,
  }) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await action(ref.read(loansRepositoryProvider));
      if (done != null) messenger.showSnackBar(SnackBar(content: Text(done)));
    } on LoanStateChanged {
      messenger.showSnackBar(SnackBar(content: Text(l10n.loanChanged)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.genericError('$e'))));
    }
    ref.invalidate(loanProvider(loan.id));
    ref.invalidate(loanEventsProvider(loan.id));
    ref.invalidate(myLoansProvider);
    ref.invalidate(bookHoldersProvider(loan.bookId));
    if (mounted) setState(() => _busy = false);
  }

  Future<int?> _askDays({
    required String title,
    required String label,
    required int initial,
    required List<int> presets,
    required int min,
    required int max,
    String? help,
  }) {
    final l10n = AppLocalizations.of(context);
    final text = TextEditingController(text: '$initial');
    return showDialog<int>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (dialog, setDialogState) {
          final value = int.tryParse(text.text);
          final valid = value != null && value >= min && value <= max;
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (help != null) ...[Text(help), const SizedBox(height: 12)],
                Wrap(
                  spacing: 8,
                  children: [
                    for (final d in presets)
                      ChoiceChip(
                        label: Text(l10n.daysCount(d)),
                        selected: value == d,
                        onSelected: (_) =>
                            setDialogState(() => text.text = '$d'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: text,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: label,
                    helperText: l10n.loanDaysRange(min, max),
                    errorText: valid ? null : l10n.loanDaysRange(min, max),
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialog),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: valid ? () => Navigator.pop(dialog, value) : null,
                child: Text(l10n.ok),
              ),
            ],
          );
        },
      ),
    ).whenComplete(text.dispose);
  }

  Future<String?> _askText(String title, String label) {
    final l10n = AppLocalizations.of(context);
    final text = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: text,
          maxLength: 200,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, text.text.trim()),
            child: Text(l10n.ok),
          ),
        ],
      ),
    ).whenComplete(text.dispose);
  }

  Future<void> _accept() async {
    final l10n = AppLocalizations.of(context);
    final days = await _askDays(
      title: l10n.loanAcceptTitle,
      label: l10n.loanDaysLabel,
      initial: loan.suggestedDays ?? 21,
      presets: const [7, 14, 21, 28],
      min: 3,
      max: 90,
      help: l10n.loanAcceptHelp(loan.otherName),
    );
    if (days != null) {
      await _run(
        (r) => r.accept(loan.id, days),
        done: l10n.loanAcceptedSnack(loan.otherName),
      );
    }
  }

  Future<void> _decline() async {
    final l10n = AppLocalizations.of(context);
    final reason = await _askText(
      l10n.loanDeclineTitle,
      l10n.loanDeclineReason,
    );
    if (reason != null) {
      await _run((r) => r.decline(loan.id, reason.isEmpty ? null : reason));
    }
  }

  Future<void> _extend() async {
    final l10n = AppLocalizations.of(context);
    final days = await _askDays(
      title: l10n.loanExtendTitle,
      label: l10n.loanExtraDaysLabel,
      initial: 7,
      presets: const [3, 7, 14],
      min: 1,
      max: 30,
    );
    if (days != null) {
      await _run(
        (r) => r.requestExtension(loan.id, days),
        done: l10n.loanExtendSent(loan.otherName),
      );
    }
  }

  List<Widget> _actions(AppLocalizations l10n) {
    final owner = loan.isOwner;
    return switch (loan.status) {
      LoanStatus.requested when owner => [
        FilledButton.icon(
          onPressed: _busy ? null : _accept,
          icon: const Icon(Icons.check),
          label: Text(l10n.loanAccept),
        ),
        OutlinedButton(
          onPressed: _busy ? null : _decline,
          child: Text(l10n.loanDecline),
        ),
      ],
      LoanStatus.requested => [
        OutlinedButton(
          onPressed: _busy ? null : () => _run((r) => r.cancel(loan.id)),
          child: Text(l10n.loanCancelRequest),
        ),
      ],
      LoanStatus.accepted => [
        if (!loan.myHandoverConfirmed)
          FilledButton.icon(
            onPressed: _busy
                ? null
                : () => _run((r) => r.confirmHandover(loan.id)),
            icon: const Icon(Icons.handshake_outlined),
            label: Text(owner ? l10n.loanConfirmGave : l10n.loanConfirmGot),
          ),
        OutlinedButton(
          onPressed: _busy ? null : () => _run((r) => r.cancel(loan.id)),
          child: Text(l10n.loanCallOff),
        ),
      ],
      LoanStatus.active when owner => [
        if (loan.extensionPending) ...[
          FilledButton(
            onPressed: _busy
                ? null
                : () => _run((r) => r.respondExtension(loan.id, accept: true)),
            child: Text(
              l10n.loanExtendAccept(loan.extensionDaysRequested ?? 0),
            ),
          ),
          OutlinedButton(
            onPressed: _busy
                ? null
                : () => _run((r) => r.respondExtension(loan.id, accept: false)),
            child: Text(l10n.loanExtendDecline),
          ),
        ],
        FilledButton.tonalIcon(
          onPressed: _busy
              ? null
              : () => _run(
                  (r) => r.confirmReturn(loan.id),
                  done: l10n.loanReturnedSnack,
                ),
          icon: const Icon(Icons.assignment_return_outlined),
          label: Text(l10n.loanMarkReturned),
        ),
      ],
      LoanStatus.active => [
        if (loan.canRequestExtension)
          OutlinedButton.icon(
            onPressed: _busy ? null : _extend,
            icon: const Icon(Icons.more_time),
            label: Text(l10n.loanExtendAsk),
          ),
      ],
      _ => const [],
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final myId = ref.watch(currentUserIdProvider);
    final events = ref.watch(loanEventsProvider(loan.id)).value ?? const [];
    final timeFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).add_Hm();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookCover(title: loan.title, url: loan.coverUrl, width: 90),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loan.title, style: theme.textTheme.titleLarge),
                      Text(loan.authors.join(', ')),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => context.push('/people/${loan.otherId}'),
                        child: Text(
                          loanCounterpart(l10n, loan),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              color: loan.overdue
                  ? theme.colorScheme.errorContainer
                  : theme.colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loanStatusLine(context, loan),
                      style: theme.textTheme.titleMedium,
                    ),
                    if (loan.dueAt != null)
                      Text(l10n.loanDueOn(formatDate(context, loan.dueAt!))),
                    if (loan.status == LoanStatus.accepted) ...[
                      const SizedBox(height: 8),
                      Text(l10n.loanHandoverTip),
                      if (loan.theirHandoverConfirmed)
                        Text(
                          l10n.loanTheyConfirmed(loan.otherName),
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                    if (loan.declineReason != null)
                      Text(
                        '“${loan.declineReason}”',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ),
            ),
            if (loan.message != null) ...[
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.chat_bubble_outline),
                title: Text('“${loan.message}”'),
                subtitle: Text(
                  loan.isOwner
                      ? l10n.loanMessageFrom(loan.otherName)
                      : l10n.loanYourMessage,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: _actions(l10n)),
            const SizedBox(height: 24),
            Text(l10n.loanTimeline, style: theme.textTheme.titleSmall),
            for (final e in events)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.circle, size: 10),
                title: Text(loanEventLabel(l10n, e, e.actorId == myId)),
                subtitle: Text(timeFormat.format(e.createdAt)),
              ),
          ],
        ),
      ),
    );
  }
}
