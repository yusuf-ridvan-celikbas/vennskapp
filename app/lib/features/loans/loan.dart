/// Mirrors `public.loan_status`. Overdue is derived (see [Loan.overdue]).
enum LoanStatus { requested, accepted, active, returned, declined, cancelled }

enum LoanRole { owner, borrower }

/// A loan from the viewer's side (from the `my_loans` RPC).
class Loan {
  const Loan({
    required this.id,
    required this.role,
    required this.status,
    required this.overdue,
    required this.bookId,
    required this.title,
    required this.authors,
    required this.otherId,
    required this.otherName,
    required this.otherUsername,
    required this.myHandoverConfirmed,
    required this.theirHandoverConfirmed,
    required this.extensionsUsed,
    required this.createdAt,
    required this.updatedAt,
    this.coverUrl,
    this.pageCount,
    this.message,
    this.declineReason,
    this.durationDays,
    this.suggestedDays,
    this.handoverAt,
    this.dueAt,
    this.returnedAt,
    this.extensionDaysRequested,
    this.extensionStatus,
    this.myFeedback,
  });

  final String id;
  final LoanRole role;
  final LoanStatus status;
  final bool overdue;
  final String bookId;
  final String title;
  final List<String> authors;
  final String otherId;
  final String otherName;
  final String otherUsername;
  final bool myHandoverConfirmed;
  final bool theirHandoverConfirmed;
  final int extensionsUsed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? coverUrl;
  final int? pageCount;
  final String? message;
  final String? declineReason;
  final int? durationDays;
  final int? suggestedDays;
  final DateTime? handoverAt;
  final DateTime? dueAt;
  final DateTime? returnedAt;
  final int? extensionDaysRequested;
  final String? extensionStatus; // pending | accepted | declined
  final String? myFeedback; // up | down, after a returned loan

  bool get isOwner => role == LoanRole.owner;
  bool get isOpen => const {
    LoanStatus.requested,
    LoanStatus.accepted,
    LoanStatus.active,
  }.contains(status);
  bool get extensionPending => extensionStatus == 'pending';
  bool get canRequestExtension =>
      !isOwner &&
      status == LoanStatus.active &&
      extensionsUsed == 0 &&
      !extensionPending;

  /// Whole calendar days until the due date (negative when overdue).
  int? daysLeft(DateTime now) {
    final due = dueAt;
    if (due == null) return null;
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(due.year, due.month, due.day);
    return dueDay.difference(today).inDays;
  }

  /// Something here is waiting for the viewer to act.
  bool get needsMyAction => switch (status) {
    LoanStatus.requested => isOwner,
    LoanStatus.accepted => !myHandoverConfirmed,
    LoanStatus.active => (isOwner && extensionPending) || (!isOwner && overdue),
    _ => false,
  };

  static DateTime? _date(Object? v) =>
      v == null ? null : DateTime.parse(v as String).toLocal();

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
    id: json['id'] as String,
    role: LoanRole.values.byName(json['role'] as String),
    status: LoanStatus.values.byName(json['status'] as String),
    overdue: json['overdue'] as bool,
    bookId: json['book_id'] as String,
    title: json['title'] as String,
    authors: (json['authors'] as List).cast<String>(),
    otherId: json['other_id'] as String,
    otherName: json['other_name'] as String,
    otherUsername: json['other_username'] as String,
    myHandoverConfirmed: json['my_handover_confirmed'] as bool,
    theirHandoverConfirmed: json['their_handover_confirmed'] as bool,
    extensionsUsed: json['extensions_used'] as int,
    createdAt: _date(json['created_at'])!,
    updatedAt: _date(json['updated_at'])!,
    coverUrl: json['cover_url'] as String?,
    pageCount: json['page_count'] as int?,
    message: json['message'] as String?,
    declineReason: json['decline_reason'] as String?,
    durationDays: json['duration_days'] as int?,
    suggestedDays: json['suggested_days'] as int?,
    handoverAt: _date(json['handover_at']),
    dueAt: _date(json['due_at']),
    returnedAt: _date(json['returned_at']),
    extensionDaysRequested: json['extension_days_requested'] as int?,
    extensionStatus: json['extension_status'] as String?,
    myFeedback: json['my_feedback'] as String?,
  );
}

class LoanEvent {
  const LoanEvent({
    required this.type,
    required this.createdAt,
    this.actorId,
    this.payload = const {},
  });

  final String type;
  final DateTime createdAt;
  final String? actorId;
  final Map<String, dynamic> payload;

  factory LoanEvent.fromJson(Map<String, dynamic> json) => LoanEvent(
    type: json['type'] as String,
    createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    actorId: json['actor_id'] as String?,
    payload: (json['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
  );
}
