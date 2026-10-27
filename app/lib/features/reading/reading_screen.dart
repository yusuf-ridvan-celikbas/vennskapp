import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import '../loans/loan_labels.dart';
import 'log_session_sheet.dart';
import 'reading_repository.dart';

/// Compact stats used on the Me tab and at the top of the reading screen.
class ReadingStatsCard extends ConsumerWidget {
  const ReadingStatsCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final stats = ref.watch(readingStatsProvider).value;

    Widget figure(String value, String label) => Expanded(
      child: Column(
        children: [
          Text(value, style: theme.textTheme.headlineSmall),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: stats == null
              ? const SizedBox(
                  height: 64,
                  child: Center(child: CircularProgressIndicator()),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        figure(
                          '${stats.booksThisYear}',
                          l10n.statBooksThisYear,
                        ),
                        figure('${stats.pagesLast30Days}', l10n.statPages30),
                        figure(
                          stats.pagesPerHour == null
                              ? '–'
                              : stats.pagesPerHour!.round().toString(),
                          l10n.statPagesPerHour,
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      l10n.statPace(stats.pacePagesPerDay.round()),
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stats.paceConfidence < 0.3
                          ? l10n.statPaceNew
                          : l10n.statPaceLearned(stats.exampleDays300),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: stats.paceConfidence.clamp(0.05, 1.0),
                      semanticsLabel: l10n.statConfidence,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class ReadingScreen extends ConsumerWidget {
  const ReadingScreen({super.key});

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function(ReadingRepository) action,
  ) async {
    await action(ref.read(readingRepositoryProvider));
    invalidateReading(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final sessions = ref.watch(recentSessionsProvider).value ?? const [];
    final finished = ref.watch(finishedBooksProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.readingTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showLogSessionSheet(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.readingLogButton),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              const ReadingStatsCard(),
              const SizedBox(height: 8),
              Text(l10n.readingPrivacyNote, style: theme.textTheme.bodySmall),
              const SizedBox(height: 16),
              Text(
                l10n.readingFinishedTitle,
                style: theme.textTheme.titleMedium,
              ),
              if (finished.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(l10n.readingFinishedEmpty),
                ),
              for (final f in finished)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(f.title),
                  subtitle: Text(
                    l10n.readingFinishedLine(
                      formatDate(context, f.finishedOn),
                      f.days,
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: l10n.remove,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () =>
                        _delete(context, ref, (r) => r.deleteFinished(f.id)),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                l10n.readingSessionsTitle,
                style: theme.textTheme.titleMedium,
              ),
              if (sessions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(l10n.readingSessionsEmpty),
                ),
              for (final s in sessions)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(l10n.readingSessionLine(s.pages, s.minutes)),
                  subtitle: Text(
                    [
                      formatDate(context, s.date),
                      if (s.bookTitle != null) s.bookTitle!,
                    ].join(' · '),
                  ),
                  trailing: IconButton(
                    tooltip: l10n.remove,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () =>
                        _delete(context, ref, (r) => r.deleteSession(s.id)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
