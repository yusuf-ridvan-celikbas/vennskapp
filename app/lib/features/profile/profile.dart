/// Mirrors the `public.visibility` enum. Ordered: each level includes the
/// audiences of the levels before it.
enum VisibilityLevel {
  private,
  friends,
  neighbors,
  public;

  static VisibilityLevel fromDb(String value) =>
      VisibilityLevel.values.byName(value);
}

class Profile {
  const Profile({
    required this.id,
    required this.username,
    required this.displayName,
    required this.areaName,
    required this.locale,
    required this.defaultVisibility,
    required this.profileVisibility,
    required this.thumbsUp,
    required this.thumbsDown,
  });

  final String id;
  final String? username;
  final String? displayName;
  final String? areaName;
  final String locale;
  final VisibilityLevel defaultVisibility;
  final VisibilityLevel profileVisibility;
  final int thumbsUp;
  final int thumbsDown;

  /// Onboarding is done once the user has a name and a home area.
  bool get isComplete =>
      username != null && displayName != null && areaName != null;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    username: json['username'] as String?,
    displayName: json['display_name'] as String?,
    areaName: json['area_name'] as String?,
    locale: json['locale'] as String,
    defaultVisibility: VisibilityLevel.fromDb(
      json['default_visibility'] as String,
    ),
    profileVisibility: VisibilityLevel.fromDb(
      json['profile_visibility'] as String,
    ),
    thumbsUp: json['thumbs_up'] as int,
    thumbsDown: json['thumbs_down'] as int,
  );
}
