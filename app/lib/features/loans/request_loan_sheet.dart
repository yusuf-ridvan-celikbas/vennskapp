import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import '../discover/discover_repository.dart';
import 'loans_repository.dart';

/// Bottom sheet to ask a holder to lend their copy, with a friendly note.
Future<void> showRequestLoanSheet(
  BuildContext context, {
  required Holder holder,
  required String bookId,
  required String bookTitle,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) =>
        _RequestLoanSheet(holder: holder, bookId: bookId, bookTitle: bookTitle),
  );
}

class _RequestLoanSheet extends ConsumerStatefulWidget {
  const _RequestLoanSheet({
    required this.holder,
    required this.bookId,
    required this.bookTitle,
  });

  final Holder holder;
  final String bookId;
  final String bookTitle;

  @override
  ConsumerState<_RequestLoanSheet> createState() => _RequestLoanSheetState();
}

class _RequestLoanSheetState extends ConsumerState<_RequestLoanSheet> {
  TextEditingController? _message;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _message ??= TextEditingController(
      text: AppLocalizations.of(context).loanDefaultMessage,
    );
  }

  @override
  void dispose() {
    _message?.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _busy = true);
    try {
      final loanId = await ref
          .read(loansRepositoryProvider)
          .request(widget.holder.itemId, _message!.text.trim());
      ref.invalidate(bookHoldersProvider(widget.bookId));
      ref.invalidate(myLoansProvider);
      if (mounted) Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.loanRequestSent(widget.holder.displayName)),
          action: SnackBarAction(
            label: l10n.view,
            onPressed: () => router.push('/loans/$loanId'),
          ),
        ),
      );
    } on LoanStateChanged {
      messenger.showSnackBar(SnackBar(content: Text(l10n.loanChanged)));
      if (mounted) setState(() => _busy = false);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.genericError('$e'))));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.loanRequestTitle(widget.bookTitle),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(l10n.loanRequestFrom(widget.holder.displayName)),
          const SizedBox(height: 16),
          TextField(
            controller: _message,
            maxLength: 300,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.loanMessageLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.loanRequestTip,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy ? null : _send,
            icon: const Icon(Icons.send),
            label: Text(l10n.loanRequestSend),
          ),
        ],
      ),
    );
  }
}
