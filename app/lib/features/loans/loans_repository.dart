import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase.dart';
import 'loan.dart';

/// The loan changed in the meantime (e.g. the other person already acted).
class LoanStateChanged implements Exception {
  const LoanStateChanged();
}

class LoansRepository {
  LoansRepository(this._db);

  final SupabaseClient _db;

  Future<List<Loan>> myLoans() async {
    final rows = await _db.rpc('my_loans') as List;
    return rows.cast<Map<String, dynamic>>().map(Loan.fromJson).toList();
  }

  Future<Loan?> loan(String id) async {
    final rows = await _db.rpc('my_loans', params: {'only_loan': id}) as List;
    return rows.isEmpty
        ? null
        : Loan.fromJson(rows.first as Map<String, dynamic>);
  }

  Future<List<LoanEvent>> events(String loanId) async {
    final rows = await _db
        .from('loan_events')
        .select()
        .eq('loan_id', loanId)
        .order('created_at', ascending: true);
    return rows.map(LoanEvent.fromJson).toList();
  }

  Future<String> request(String itemId, String? message) =>
      _call<String>('request_loan', {'item': itemId, 'note': message});

  Future<void> accept(String loanId, int days) => _call<void>('respond_loan', {
    'loan': loanId,
    'accept': true,
    'days': days,
  });

  Future<void> decline(String loanId, String? reason) => _call<void>(
    'respond_loan',
    {'loan': loanId, 'accept': false, 'reason': reason},
  );

  Future<void> cancel(String loanId) =>
      _call<void>('cancel_loan', {'loan': loanId});

  Future<void> confirmHandover(String loanId) =>
      _call<void>('confirm_handover', {'loan': loanId});

  Future<void> requestExtension(String loanId, int days) =>
      _call<void>('request_extension', {'loan': loanId, 'days': days});

  Future<void> respondExtension(String loanId, {required bool accept}) =>
      _call<void>('respond_extension', {'loan': loanId, 'accept': accept});

  Future<void> confirmReturn(String loanId) =>
      _call<void>('confirm_return', {'loan': loanId});

  Future<void> leaveFeedback(String loanId, {required bool up}) =>
      _call<void>('leave_loan_feedback', {'loan': loanId, 'up': up});

  Future<T> _call<T>(String fn, Map<String, dynamic> params) async {
    try {
      return await _db.rpc(fn, params: params) as T;
    } on PostgrestException catch (e) {
      if (e.code == '55000') throw const LoanStateChanged();
      rethrow;
    }
  }
}

final loansRepositoryProvider = Provider(
  (ref) => LoansRepository(ref.watch(supabaseProvider)),
);

final myLoansProvider = FutureProvider<List<Loan>>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.watch(loansRepositoryProvider).myLoans();
});

final loanProvider = FutureProvider.family<Loan?, String>(
  (ref, id) => ref.watch(loansRepositoryProvider).loan(id),
);

final loanEventsProvider = FutureProvider.family<List<LoanEvent>, String>(
  (ref, id) => ref.watch(loansRepositoryProvider).events(id),
);

/// Number of loans waiting for the viewer, for the tab badge.
final loansNeedingActionProvider = Provider<int>(
  (ref) =>
      ref.watch(myLoansProvider).value?.where((l) => l.needsMyAction).length ??
      0,
);
