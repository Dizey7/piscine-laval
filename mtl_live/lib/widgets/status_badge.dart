import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../utils/extensions.dart';

/// Badge de statut de disponibilité
class StatusBadge extends StatelessWidget {
  final EventStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }

  String get _label {
    switch (status) {
      case EventStatus.available:
        return 'Disponible';
      case EventStatus.almostFull:
        return 'Presque complet';
      case EventStatus.soldOut:
        return 'Complet';
      case EventStatus.cancelled:
        return 'Annulé';
      case EventStatus.postponed:
        return 'Reporté';
      case EventStatus.rescheduled:
        return 'Reprogrammé';
    }
  }
}
