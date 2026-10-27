import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import '../books/book.dart';
import '../books/isbn.dart';
import 'add_to_shelf.dart';

class ManualBookScreen extends ConsumerStatefulWidget {
  const ManualBookScreen({super.key, this.isbn});

  /// Pre-filled when coming from a scan that found no metadata.
  final String? isbn;

  @override
  ConsumerState<ManualBookScreen> createState() => _ManualBookScreenState();
}

class _ManualBookScreenState extends ConsumerState<ManualBookScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _authors = TextEditingController();
  late final _isbn = TextEditingController(text: widget.isbn);
  final _pages = TextEditingController();
  final _year = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_title, _authors, _isbn, _pages, _year]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final candidate = BookCandidate(
      title: _title.text.trim(),
      source: BookSource.manual,
      authors: _authors.text
          .split(',')
          .map((a) => a.trim())
          .where((a) => a.isNotEmpty)
          .toList(),
      isbn13: _isbn.text.trim().isEmpty ? null : normalizeIsbn(_isbn.text),
      pageCount: int.tryParse(_pages.text.trim()),
      publishedYear: int.tryParse(_year.text.trim()),
    );
    final (result, _) = await addToShelf(context, ref, candidate);
    if (!mounted) return;
    setState(() => _busy = false);
    if (result != AddResult.failed) context.pop();
  }

  String? _number(String? v, int min, int max) {
    final text = (v ?? '').trim();
    if (text.isEmpty) return null;
    final n = int.tryParse(text);
    return (n == null || n < min || n > max)
        ? AppLocalizations.of(context).manualNumberInvalid
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addManual)),
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
                  TextFormField(
                    controller: _title,
                    decoration: InputDecoration(labelText: l10n.manualTitle),
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 300,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.fieldRequired
                        : null,
                  ),
                  TextFormField(
                    controller: _authors,
                    decoration: InputDecoration(
                      labelText: l10n.manualAuthors,
                      helperText: l10n.manualAuthorsHelp,
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _isbn,
                    decoration: InputDecoration(labelText: l10n.manualIsbn),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v ?? '').trim().isEmpty || normalizeIsbn(v!) != null
                        ? null
                        : l10n.scanInvalidIsbn,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _pages,
                          decoration: InputDecoration(
                            labelText: l10n.manualPages,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => _number(v, 1, 20000),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _year,
                          decoration: InputDecoration(
                            labelText: l10n.manualYear,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => _number(v, 0, 2100),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _save,
                    child: Text(l10n.addToShelf),
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
