import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase.dart';

/// The signed-in user's reading numbers (from `my_reading_stats`).
class ReadingStats {
  const ReadingStats({
    required this.pacePagesPerDay,
    required this.paceConfidence,
    required this.booksThisYear,
    required this.pagesLast30Days,
    required this.minutesLast30Days,
    required this.sessionsCount,
    required this.exampleDays300,
    this.pagesPerHour,
  });

  /// Estimated pages per calendar day, including days without reading.
  final double pacePagesPerDay;

  /// 0 = only the default guess, approaching 1 with more finished books.
  final double paceConfidence;
  final int booksThisYear;
  final int pagesLast30Days;
  final int minutesLast30Days;
  final int sessionsCount;

  /// What a 300-page book would get as a suggested loan length.
  final int exampleDays300;
  final double? pagesPerHour;

  static double? _num(Object? v) => v == null ? null : (v as num).toDouble();

  factory ReadingStats.fromJson(Map<String, dynamic> json) => ReadingStats(
    pacePagesPerDay: _num(json['pace_pages_per_day']) ?? 20,
    paceConfidence: _num(json['pace_confidence']) ?? 0,
    booksThisYear: json['books_this_year'] as int,
    pagesLast30Days: json['pages_last_30_days'] as int,
    minutesLast30Days: json['minutes_last_30_days'] as int,
    sessionsCount: json['sessions_count'] as int,
    exampleDays300: json['example_days_300'] as int,
    pagesPerHour: _num(json['pages_per_hour']),
  );
}

class ReadingSession {
  const ReadingSession({
    required this.id,
    required this.date,
    required this.pages,
    required this.minutes,
    this.bookTitle,
  });

  final String id;
  final DateTime date;
  final int pages;
  final int minutes;
  final String? bookTitle;

  factory ReadingSession.fromJson(Map<String, dynamic> json) => ReadingSession(
    id: json['id'] as String,
    date: DateTime.parse(json['session_date'] as String),
    pages: json['pages'] as int,
    minutes: json['minutes'] as int,
    bookTitle: (json['books'] as Map?)?['title'] as String?,
  );
}

class FinishedBook {
  const FinishedBook({
    required this.id,
    required this.title,
    required this.startedOn,
    required this.finishedOn,
    this.pages,
  });

  final String id;
  final String title;
  final DateTime startedOn;
  final DateTime finishedOn;
  final int? pages;

  int get days => finishedOn.difference(startedOn).inDays + 1;

  factory FinishedBook.fromJson(Map<String, dynamic> json) => FinishedBook(
    id: json['id'] as String,
    title: (json['books'] as Map)['title'] as String,
    startedOn: DateTime.parse(json['started_on'] as String),
    finishedOn: DateTime.parse(json['finished_on'] as String),
    pages:
        json['pages_override'] as int? ??
        (json['books'] as Map)['page_count'] as int?,
  );
}

String _day(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class ReadingRepository {
  ReadingRepository(this._db);

  final SupabaseClient _db;

  Future<ReadingStats> stats() async {
    final rows = await _db.rpc('my_reading_stats') as List;
    return ReadingStats.fromJson(rows.first as Map<String, dynamic>);
  }

  Future<List<ReadingSession>> recentSessions() async {
    final rows = await _db
        .from('reading_sessions')
        .select('id, session_date, pages, minutes, books(title)')
        .order('session_date', ascending: false)
        .order('created_at', ascending: false)
        .limit(50);
    return rows.map(ReadingSession.fromJson).toList();
  }

  Future<List<FinishedBook>> finishedBooks() async {
    final rows = await _db
        .from('finished_books')
        .select(
          'id, started_on, finished_on, pages_override, books(title, page_count)',
        )
        .order('finished_on', ascending: false)
        .limit(50);
    return rows.map(FinishedBook.fromJson).toList();
  }

  Future<void> logSession({
    required int pages,
    required int minutes,
    required DateTime date,
    String? bookId,
  }) => _db.from('reading_sessions').insert({
    'pages': pages,
    'minutes': minutes,
    'session_date': _day(date),
    'book_id': bookId,
  });

  Future<void> finishBook({
    required String bookId,
    required DateTime startedOn,
    required DateTime finishedOn,
  }) => _db.from('finished_books').insert({
    'book_id': bookId,
    'started_on': _day(startedOn),
    'finished_on': _day(finishedOn),
  });

  Future<void> deleteSession(String id) =>
      _db.from('reading_sessions').delete().eq('id', id);

  Future<void> deleteFinished(String id) =>
      _db.from('finished_books').delete().eq('id', id);
}

final readingRepositoryProvider = Provider(
  (ref) => ReadingRepository(ref.watch(supabaseProvider)),
);

final readingStatsProvider = FutureProvider<ReadingStats>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.watch(readingRepositoryProvider).stats();
});

final recentSessionsProvider = FutureProvider<List<ReadingSession>>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.watch(readingRepositoryProvider).recentSessions();
});

final finishedBooksProvider = FutureProvider<List<FinishedBook>>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.watch(readingRepositoryProvider).finishedBooks();
});

void invalidateReading(WidgetRef ref) {
  ref.invalidate(readingStatsProvider);
  ref.invalidate(recentSessionsProvider);
  ref.invalidate(finishedBooksProvider);
}
