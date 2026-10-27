/// A row of `public.notifications`. The text is rendered on the device from
/// [type] and [payload], so it follows the reader's language.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get unread => readAt == null;

  String? get loanId => payload['loan_id'] as String?;
  String? get personId => payload['person_id'] as String?;
  String get name => payload['name'] as String? ?? '';
  String get title => payload['title'] as String? ?? '';

  /// Where tapping the notification takes you.
  String? get route => switch (type) {
    _ when loanId != null => '/loans/$loanId',
    'friend_request' => '/me/friends',
    _ when personId != null => '/people/$personId',
    _ => null,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        type: json['type'] as String,
        payload: (json['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        readAt: json['read_at'] == null
            ? null
            : DateTime.parse(json['read_at'] as String).toLocal(),
      );
}
