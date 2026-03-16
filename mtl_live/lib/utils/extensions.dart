import 'dart:math';

import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../theme/mtl_theme.dart';

extension EventStatusColor on EventStatus {
  Color get color {
    switch (this) {
      case EventStatus.available:
        return MtlColors.disponible;
      case EventStatus.almostFull:
        return MtlColors.presqueComplet;
      case EventStatus.soldOut:
        return MtlColors.complet;
      case EventStatus.cancelled:
        return MtlColors.annule;
      case EventStatus.postponed:
        return Colors.amber;
      case EventStatus.rescheduled:
        return Colors.blue;
    }
  }
}

extension SourceBadgeColor on String {
  Color get sourceColor {
    switch (toLowerCase()) {
      case 'ticketmaster':
        return MtlColors.ticketmaster;
      case 'ville de montréal':
        return MtlColors.villeMtl;
      case 'predicthq':
        return MtlColors.predictHQ;
      default:
        return MtlColors.bleuMtl;
    }
  }
}

extension GeoDistanceCalc on ({double lat, double lng}) {
  /// Distance Haversine en kilomètres
  double distanceTo(double lat2, double lng2) {
    const R = 6371.0; // Rayon de la Terre en km
    final dLat = _toRad(lat2 - lat);
    final dLng = _toRad(lng2 - lng);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat)) * cos(_toRad(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180;
}

extension StringCapitalize on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
