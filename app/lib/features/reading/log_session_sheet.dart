import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import '../library/library_item.dart';
import '../library/library_repository.dart';
import '../loans/loan_labels.dart';
import 'reading_repository.dart';

/// "I read 30 pages in 45 minutes today" — optionally for a specific book.
Future<void> showLogSessionSheet(BuildContext context, {String? bookId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _LogSessionSheet(initialBookId: bookId),
  );
}

class _LogSessionSheet extends ConsumerStatefulWidget {
  const _LogSessionSheet({this.initialBookId});

  final String? initialBookId;

  @override
  ConsumerState<_LogSessionSheet> createState() => _LogSessionSheetState();
}

class _LogSessionSheetState extends ConsumerState<_LogSessionSheet> {
  final _form = GlobalKey<FormState>();
  final _pages = TextEditingController();
  final _hours = TextEditingController(text: '0');
  final _minutes = TextEditingController(text: '30');
  late String? _bookId = widget.initialBookId;
  DateTime _date = DateTime.now();
  bool _busy = false;

  @override
  void dispose() {
    _pages.dispose();
    _hours.dispose();
    _minutes.dispose();
    super.dispose();
  }

  int get _totalMinutes =>
      (int.tryParse(_hours.text) ?? 0) * 60 +
      (int.tryParse(_minutes.text) ?? 0);

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!_form.currentState!.validate()) return;
    if (_totalMinutes < 1 || _totalMinutes > 1440) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.readingTimeInvalid)));
      return;
    }
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(readingRepositoryProvider)
          .logSession(
            pages: int.parse(_pages.text),
            minutes: _totalMinutes,
            date: _date,
            bookId: _bookId,
          );
      invalidateReading(ref);
      if (mounted) Navigator.pop(context);
      messenger.showSnackBar(SnackBar(content: Text(l10n.readingLogged)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.genericError('$e'))));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shelf = ref.watch(myShelfProvider).value ?? const <LibraryItem>[];
    // Books being read first, then the rest of the shelf.
    final books = [
      ...shelf.where((i) => i.status == ReadingStatus.reading),
      ...shelf.where((i) => i.status != ReadingStatus.reading),
    ];
    final digits = [FilteringTextInputFormatter.digitsOnly];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.readingLogTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pages,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: digits,
              decoration: InputDecoration(labelText: l10n.readingPages),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                return n == null || n < 1 || n > 2000
                    ? l10n.manualNumberInvalid
                    : null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _hours,
                    keyboardType: TextInputType.number,
                    inputFormatters: digits,
                    decoration: InputDecoration(labelText: l10n.readingHours),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _minutes,
                    keyboardType: TextInputType.number,
                    inputFormatters: digits,
                    decoration: InputDecoration(labelText: l10n.readingMinutes),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _bookId,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.readingWhichBook),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.readingNoBook)),
                for (final item in books)
                  DropdownMenuItem(
                    value: item.book.id,
                    child: Text(
                      item.book.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _bookId = v),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: Text(formatDate(context, _date)),
              trailing: TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: Text(l10n.readingChangeDate),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(l10n.readingSave),
            ),
          ],
        ),
      ),
    );
  }
}

/// Asks when a book was read and records it as finished. Returns true if saved.
Future<bool> askFinishedDates(
  BuildContext context,
  WidgetRef ref,
  String bookId,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final now = DateTime.now();
  final range = await showDateRangePicker(
    context: context,
    firstDate: DateTime(now.year - 5),
    lastDate: now,
    initialDateRange: DateTimeRange(
      start: now.subtract(const Duration(days: 14)),
      end: now,
    ),
    helpText: l10n.readingFinishedRangeHelp,
    saveText: l10n.readingSave,
  );
  if (range == null) return false;
  try {
    await ref
        .read(readingRepositoryProvider)
        .finishBook(
          bookId: bookId,
          startedOn: range.start,
          finishedOn: range.end,
        );
    invalidateReading(ref);
    messenger.showSnackBar(SnackBar(content: Text(l10n.readingFinishedSaved)));
    return true;
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.genericError('$e'))));
    return false;
  }
}
