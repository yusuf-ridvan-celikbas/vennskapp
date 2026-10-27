import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import '../books/book_lookup.dart';
import '../books/isbn.dart';
import 'add_to_shelf.dart';

enum _ScanState { lookingUp, added, duplicate, notFound, failed }

class _Scanned {
  _Scanned(this.isbn);
  final String isbn;
  _ScanState state = _ScanState.lookingUp;
  String? title;
}

/// Bulk scanning: the camera stays open and every new ISBN barcode is looked
/// up and added to the shelf straight away (with Undo in the snackbar).
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.ean13],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final _scanned = <_Scanned>[];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    for (final code in capture.barcodes) {
      final isbn = normalizeIsbn(code.rawValue ?? '');
      if (isbn != null) _handleIsbn(isbn);
    }
  }

  Future<void> _handleIsbn(String isbn) async {
    if (_scanned.any((s) => s.isbn == isbn)) return; // already handled
    final entry = _Scanned(isbn);
    setState(() => _scanned.insert(0, entry));

    final candidate = await ref.read(bookLookupProvider).byIsbn(isbn);
    if (!mounted) return;
    if (candidate == null) {
      setState(() => entry.state = _ScanState.notFound);
      return;
    }
    entry.title = candidate.title;
    final (result, _) = await addToShelf(
      context,
      ref,
      candidate,
      undoable: true,
    );
    if (!mounted) return;
    setState(
      () => entry.state = switch (result) {
        AddResult.added => _ScanState.added,
        AddResult.duplicate => _ScanState.duplicate,
        AddResult.failed => _ScanState.failed,
      },
    );
  }

  Future<void> _typeIsbn() async {
    final l10n = AppLocalizations.of(context);
    final text = TextEditingController();
    final isbn = await showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n.scanTypeIsbn),
        content: TextField(
          controller: text,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '978…'),
          onSubmitted: (v) => Navigator.pop(dialog, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, text.text),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
    text.dispose();
    if (isbn == null || !mounted) return;
    final normalized = normalizeIsbn(isbn);
    if (normalized == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.scanInvalidIsbn)));
      return;
    }
    _handleIsbn(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final added = _scanned.where((s) => s.state == _ScanState.added).length;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addScan),
        actions: [
          IconButton(
            onPressed: _typeIsbn,
            icon: const Icon(Icons.keyboard),
            tooltip: l10n.scanTypeIsbn,
          ),
          IconButton(
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flashlight_on_outlined),
            tooltip: l10n.scanTorch,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                  errorBuilder: (context, error) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.scanCameraError,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 280,
                    height: 140,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.scanAddedCount(added),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: Text(l10n.done),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: _scanned.isEmpty
                ? Center(
                    child: Text(l10n.scanHint, textAlign: TextAlign.center),
                  )
                : ListView(
                    children: [
                      for (final s in _scanned) _ScannedTile(entry: s),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ScannedTile extends StatelessWidget {
  const _ScannedTile({required this.entry});

  final _Scanned entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (icon, color, text) = switch (entry.state) {
      _ScanState.lookingUp => (
        Icons.hourglass_top,
        scheme.outline,
        l10n.scanLookingUp,
      ),
      _ScanState.added => (Icons.check_circle, scheme.primary, l10n.scanAdded),
      _ScanState.duplicate => (
        Icons.info_outline,
        scheme.secondary,
        l10n.onYourShelf,
      ),
      _ScanState.notFound => (
        Icons.help_outline,
        scheme.error,
        l10n.scanNotFound,
      ),
      _ScanState.failed => (Icons.error_outline, scheme.error, l10n.scanFailed),
    };
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color),
      title: Text(entry.title ?? entry.isbn),
      subtitle: Text(text),
      trailing: entry.state == _ScanState.notFound
          ? TextButton(
              onPressed: () =>
                  context.push('/shelf/add/manual?isbn=${entry.isbn}'),
              child: Text(l10n.addManual),
            )
          : null,
    );
  }
}
