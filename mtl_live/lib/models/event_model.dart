import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle principal d'événement MTL Live.
/// Unifie toutes les sources (Ticketmaster, Ville de Montréal, PredictHQ, etc.)
class MtlEvent {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final List<String> imageUrls;
  final DateTime startDate;
  final DateTime? endDate;
  final String venue;
  final String? venueAddress;
  final double? latitude;
  final double? longitude;
  final String category;
  final List<String> tags;
  final String source;
  final String? sourceUrl;
  final String? externalId;

  // Prix en temps réel
  final double? priceCurrent;
  final double? priceMin;
  final double? priceMax;
  final bool isFree;
  final String currency;

  // Disponibilité
  final EventStatus status;
  final int? availableTickets;
  final int? totalCapacity;

  // PredictHQ
  final double? impactScore;
  final int? predictedAttendance;

  // Métadonnées
  final DateTime lastUpdated;
  final DateTime createdAt;
  final bool isIndoor;
  final bool isFamilyFriendly;
  final bool isAdultOnly;
  final String? neighborhood;

  // Transport
  final String? nearestMetro;
  final String? bixiStation;

  const MtlEvent({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.imageUrls = const [],
    required this.startDate,
    this.endDate,
    required this.venue,
    this.venueAddress,
    this.latitude,
    this.longitude,
    required this.category,
    this.tags = const [],
    required this.source,
    this.sourceUrl,
    this.externalId,
    this.priceCurrent,
    this.priceMin,
    this.priceMax,
    this.isFree = false,
    this.currency = 'CAD',
    this.status = EventStatus.available,
    this.availableTickets,
    this.totalCapacity,
    this.impactScore,
    this.predictedAttendance,
    required this.lastUpdated,
    required this.createdAt,
    this.isIndoor = true,
    this.isFamilyFriendly = true,
    this.isAdultOnly = false,
    this.neighborhood,
    this.nearestMetro,
    this.bixiStation,
  });

  String get priceDisplay {
    if (isFree) return 'Gratuit';
    if (priceMin != null && priceMax != null && priceMin != priceMax) {
      return '${priceMin!.toStringAsFixed(0)} – ${priceMax!.toStringAsFixed(0)} \$ $currency';
    }
    if (priceCurrent != null) {
      return '${priceCurrent!.toStringAsFixed(0)} \$ $currency';
    }
    if (priceMin != null) return 'À partir de ${priceMin!.toStringAsFixed(0)} \$';
    return 'Prix non disponible';
  }

  String get statusLabel {
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

  bool get isLiveNow {
    final now = DateTime.now();
    return startDate.isBefore(now) && (endDate == null || endDate!.isAfter(now));
  }

  bool get isToday {
    final now = DateTime.now();
    return startDate.year == now.year &&
        startDate.month == now.month &&
        startDate.day == now.day;
  }

  bool get isThisWeekend {
    final now = DateTime.now();
    final saturday = now.add(Duration(days: DateTime.saturday - now.weekday));
    final sunday = now.add(Duration(days: DateTime.sunday - now.weekday));
    final startDay = DateTime(startDate.year, startDate.month, startDate.day);
    return startDay == DateTime(saturday.year, saturday.month, saturday.day) ||
        startDay == DateTime(sunday.year, sunday.month, sunday.day);
  }

  Duration get timeUntilStart => startDate.difference(DateTime.now());

  bool get isStartingSoon =>
      timeUntilStart.inMinutes > 0 && timeUntilStart.inHours <= 2;

  bool get isDataStale =>
      DateTime.now().difference(lastUpdated).inMinutes > 30;

  factory MtlEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MtlEvent(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      venue: data['venue'] ?? '',
      venueAddress: data['venueAddress'],
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      category: data['category'] ?? 'Autre',
      tags: List<String>.from(data['tags'] ?? []),
      source: data['source'] ?? '',
      sourceUrl: data['sourceUrl'],
      externalId: data['externalId'],
      priceCurrent: (data['priceCurrent'] as num?)?.toDouble(),
      priceMin: (data['priceMin'] as num?)?.toDouble(),
      priceMax: (data['priceMax'] as num?)?.toDouble(),
      isFree: data['isFree'] ?? false,
      currency: data['currency'] ?? 'CAD',
      status: EventStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => EventStatus.available,
      ),
      availableTickets: data['availableTickets'],
      totalCapacity: data['totalCapacity'],
      impactScore: (data['impactScore'] as num?)?.toDouble(),
      predictedAttendance: data['predictedAttendance'],
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isIndoor: data['isIndoor'] ?? true,
      isFamilyFriendly: data['isFamilyFriendly'] ?? true,
      isAdultOnly: data['isAdultOnly'] ?? false,
      neighborhood: data['neighborhood'],
      nearestMetro: data['nearestMetro'],
      bixiStation: data['bixiStation'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'venue': venue,
      'venueAddress': venueAddress,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'tags': tags,
      'source': source,
      'sourceUrl': sourceUrl,
      'externalId': externalId,
      'priceCurrent': priceCurrent,
      'priceMin': priceMin,
      'priceMax': priceMax,
      'isFree': isFree,
      'currency': currency,
      'status': status.name,
      'availableTickets': availableTickets,
      'totalCapacity': totalCapacity,
      'impactScore': impactScore,
      'predictedAttendance': predictedAttendance,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'createdAt': Timestamp.fromDate(createdAt),
      'isIndoor': isIndoor,
      'isFamilyFriendly': isFamilyFriendly,
      'isAdultOnly': isAdultOnly,
      'neighborhood': neighborhood,
      'nearestMetro': nearestMetro,
      'bixiStation': bixiStation,
    };
  }

  MtlEvent copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    List<String>? imageUrls,
    DateTime? startDate,
    DateTime? endDate,
    String? venue,
    String? venueAddress,
    double? latitude,
    double? longitude,
    String? category,
    List<String>? tags,
    String? source,
    String? sourceUrl,
    String? externalId,
    double? priceCurrent,
    double? priceMin,
    double? priceMax,
    bool? isFree,
    String? currency,
    EventStatus? status,
    int? availableTickets,
    int? totalCapacity,
    double? impactScore,
    int? predictedAttendance,
    DateTime? lastUpdated,
    DateTime? createdAt,
    bool? isIndoor,
    bool? isFamilyFriendly,
    bool? isAdultOnly,
    String? neighborhood,
    String? nearestMetro,
    String? bixiStation,
  }) {
    return MtlEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      venue: venue ?? this.venue,
      venueAddress: venueAddress ?? this.venueAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      source: source ?? this.source,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      externalId: externalId ?? this.externalId,
      priceCurrent: priceCurrent ?? this.priceCurrent,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      isFree: isFree ?? this.isFree,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      availableTickets: availableTickets ?? this.availableTickets,
      totalCapacity: totalCapacity ?? this.totalCapacity,
      impactScore: impactScore ?? this.impactScore,
      predictedAttendance: predictedAttendance ?? this.predictedAttendance,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
      isIndoor: isIndoor ?? this.isIndoor,
      isFamilyFriendly: isFamilyFriendly ?? this.isFamilyFriendly,
      isAdultOnly: isAdultOnly ?? this.isAdultOnly,
      neighborhood: neighborhood ?? this.neighborhood,
      nearestMetro: nearestMetro ?? this.nearestMetro,
      bixiStation: bixiStation ?? this.bixiStation,
    );
  }
}

enum EventStatus {
  available,
  almostFull,
  soldOut,
  cancelled,
  postponed,
  rescheduled,
}

enum EventCategory {
  musique('Musique', '🎵'),
  sports('Sports', '⚽'),
  festivals('Festivals', '🎪'),
  artsCulture('Arts & Culture', '🎨'),
  gastronomie('Gastronomie', '🍽️'),
  famille('Enfants / Famille', '👨‍👩‍👧‍👦'),
  meetups('Meetups', '🤝'),
  nightlife('Nightlife', '🌙'),
  cinema('Cinéma', '🎬'),
  theatre('Théâtre', '🎭'),
  conference('Conférence', '🎤'),
  pleinAir('Plein air', '🌲'),
  marche('Marchés', '🛍️'),
  autre('Autre', '📌');

  final String label;
  final String emoji;
  const EventCategory(this.label, this.emoji);
}
