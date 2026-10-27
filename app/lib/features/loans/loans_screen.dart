import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import '../books/book_cover.dart';
import '../notifications/notifications_screen.dart';
import '../shell/empty_state.dart';
import 'loan.dart';
import 'loan_labels.dart';
import 'loans_repository.dart';

class LoansScreen extends ConsumerWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final loans = ref.watch(myLoansProvider);
    final all = loans.value ?? const <Loan>[];

    final requests = all
        .where((l) => l.status == LoanStatus.requested)
        .toList();
    final active = all
        .where(
          (l) =>
              l.status == LoanStatus.accepted || l.status == LoanStatus.active,
        )
        .toList();
    final history = all.where((l) => !l.isOpen).toList();

    Tab tab(String label, List<Loan> list) {
      final waiting = list.where((l) => l.needsMyAction).length;
      return Tab(
        child: Badge(
          isLabelVisible: waiting > 0,
          label: Text('$waiting'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(label),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.tabLoans),
          actions: const [NotificationBell()],
          bottom: TabBar(
            tabs: [
              tab(l10n.loansTabActive, active),
              tab(l10n.loansTabRequests, requests),
              tab(l10n.loansTabHistory, history),
            ],
          ),
        ),
        body: switch (loans) {
          AsyncError(:final error) => Center(
            child: Text(l10n.genericError('$error')),
          ),
          AsyncData() => TabBarView(
            children: [
              _LoanList(loans: active, emptyText: l10n.loansEmptyActive),
              _LoanList(loans: requests, emptyText: l10n.loansEmptyRequests),
              _LoanList(loans: history, emptyText: l10n.loansEmptyHistory),
            ],
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _LoanList extends ConsumerWidget {
  const _LoanList({required this.loans, required this.emptyText});

  final List<Loan> loans;
  final String emptyText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(myLoansProvider.future),
      child: loans.isEmpty
          ? ListView(
              children: [
                EmptyState(
                  icon: Icons.swap_horiz,
                  title: l10n.loansEmptyTitle,
                  body: emptyText,
                ),
              ],
            )
          : ListView.separated(
              itemCount: loans.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) => LoanTile(loan: loans[i]),
            ),
    );
  }
}

class LoanTile extends StatelessWidget {
  const LoanTile({super.key, required this.loan});

  final Loan loan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: BookCover(title: loan.title, url: loan.coverUrl, width: 44),
      title: Text(loan.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loanCounterpart(l10n, loan)),
          Text(
            loanStatusLine(context, loan),
            style: theme.textTheme.bodySmall?.copyWith(
              color: loanStatusColor(theme.colorScheme, loan),
              fontWeight: loan.needsMyAction ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
      trailing: Icon(
        loan.isOwner ? Icons.north_east : Icons.south_west,
        semanticLabel: loan.isOwner ? l10n.loanYouLend : l10n.loanYouBorrow,
      ),
      onTap: () => context.push('/loans/${loan.id}'),
    );
  }
}
