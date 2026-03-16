import 'package:flutter/material.dart';
import '../utils/extensions.dart';

/// Badge de source de données (Ticketmaster, Ville de Montréal, etc.)
class SourceBadge extends StatelessWidget {
  final String source;
  final bool mini;

  const SourceBadge({
    super.key,
    required this.source,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: mini ? 5 : 7,
        vertical: mini ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: source.sourceColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: source.sourceColor.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Text(
        mini ? _shortName : source,
        style: TextStyle(
          fontSize: mini ? 9 : 10,
          fontWeight: FontWeight.w600,
          color: source.sourceColor,
        ),
      ),
    );
  }

  String get _shortName {
    switch (source.toLowerCase()) {
      case 'ticketmaster':
        return 'TM';
      case 'ville de montréal':
        return 'MTL';
      case 'predicthq':
        return 'PHQ';
      default:
        return source.substring(0, 3).toUpperCase();
    }
  }
}
