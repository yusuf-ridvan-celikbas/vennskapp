/// Mirrors `public.relationship`: how the viewer relates to someone.
enum Relationship {
  none,
  publicUser,
  neighbor,
  friend,
  owner;

  static Relationship fromDb(String value) => switch (value) {
    'public_user' => Relationship.publicUser,
    _ => Relationship.values.byName(value),
  };
}

/// Another user as the viewer may see them (from the `get_person` RPC).
/// Area, thumbs and distance are null when their profile is not visible.
class Person {
  const Person({
    required this.id,
    required this.username,
    required this.displayName,
    required this.relationship,
    required this.profileVisible,
    required this.blockedByMe,
    this.areaName,
    this.thumbsUp,
    this.approxKm,
    this.friendshipId,
    this.friendshipAccepted = false,
    this.requestSentByMe = false,
  });

  final String id;
  final String username;
  final String displayName;
  final Relationship relationship;
  final bool profileVisible;
  final bool blockedByMe;
  final String? areaName;
  final int? thumbsUp;
  final int? approxKm;
  final String? friendshipId;
  final bool friendshipAccepted;
  final bool requestSentByMe;

  bool get hasPendingRequest => friendshipId != null && !friendshipAccepted;

  factory Person.fromJson(Map<String, dynamic> json) => Person(
    id: json['id'] as String,
    username: json['username'] as String,
    displayName: json['display_name'] as String,
    relationship: Relationship.fromDb(json['relationship'] as String),
    profileVisible: json['profile_visible'] as bool,
    blockedByMe: json['blocked_by_me'] as bool,
    areaName: json['area_name'] as String?,
    thumbsUp: json['thumbs_up'] as int?,
    approxKm: json['approx_km'] as int?,
    friendshipId: json['friendship_id'] as String?,
    friendshipAccepted: json['friendship_status'] == 'accepted',
    requestSentByMe: json['request_sent_by_me'] as bool? ?? false,
  );
}

enum PeopleKind { friend, incoming, outgoing, blocked }

/// One row of "my people": friends, requests and blocked users.
class PeopleEntry {
  const PeopleEntry({
    required this.id,
    required this.username,
    required this.displayName,
    required this.kind,
    this.friendshipId,
  });

  final String id;
  final String username;
  final String displayName;
  final PeopleKind kind;
  final String? friendshipId;

  factory PeopleEntry.fromJson(Map<String, dynamic> json) => PeopleEntry(
    id: json['id'] as String,
    username: json['username'] as String,
    displayName: json['display_name'] as String,
    kind: PeopleKind.values.byName(json['kind'] as String),
    friendshipId: json['friendship_id'] as String?,
  );
}
