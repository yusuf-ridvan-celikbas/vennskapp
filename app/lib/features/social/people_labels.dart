import 'package:flutter/material.dart';
import 'package:vennskapp/l10n/app_localizations.dart';

import 'person.dart';

extension RelationshipLabels on Relationship {
  String label(AppLocalizations l10n) => switch (this) {
    Relationship.friend => l10n.relFriend,
    Relationship.neighbor => l10n.relNeighbor,
    Relationship.owner => l10n.relYou,
    Relationship.publicUser || Relationship.none => l10n.relOther,
  };

  IconData get icon => switch (this) {
    Relationship.friend => Icons.favorite_outline,
    Relationship.neighbor => Icons.holiday_village_outlined,
    _ => Icons.public,
  };
}

/// "Neighbor · Halkalı · ~2 km" style line; parts that are unknown are skipped.
String personSubtitle(
  AppLocalizations l10n,
  Relationship rel, {
  String? area,
  int? km,
}) {
  return [
    rel.label(l10n),
    ?area,
    if (km != null) km == 0 ? l10n.distanceSameArea : l10n.distanceKm(km),
  ].join(' · ');
}

class PersonAvatar extends StatelessWidget {
  const PersonAvatar({super.key, required this.name, this.radius = 20});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: TextStyle(fontSize: radius * 0.9),
      ),
    );
  }
}
