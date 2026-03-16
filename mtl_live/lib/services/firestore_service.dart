import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../utils/constants.dart';

/// Service principal Firestore — lecture/cache des événements
class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _eventsRef =>
      _db.collection(AppConstants.eventsCollection);

  /// Récupère tous les événements à venir, triés par date
  Stream<List<MtlEvent>> streamUpcomingEvents({int limit = 100}) {
    return _eventsRef
        .where('startDate', isGreaterThanOrEqualTo: Timestamp.now())
        .where('status', isNotEqualTo: 'cancelled')
        .orderBy('startDate')
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => MtlEvent.fromFirestore(d)).toList());
  }

  /// Top événements par score d'impact PredictHQ
  Stream<List<MtlEvent>> streamTopEvents({int limit = 8}) {
    return _eventsRef
        .where('startDate', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('startDate')
        .orderBy('impactScore', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => MtlEvent.fromFirestore(d)).toList());
  }

  /// Événements en cours maintenant
  Stream<List<MtlEvent>> streamLiveNow() {
    final now = Timestamp.now();
    return _eventsRef
        .where('startDate', isLessThanOrEqualTo: now)
        .where('endDate', isGreaterThanOrEqualTo: now)
        .snapshots()
        .map((snap) => snap.docs.map((d) => MtlEvent.fromFirestore(d)).toList());
  }

  /// Événements aujourd'hui
  Stream<List<MtlEvent>> streamTodayEvents() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _eventsRef
        .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startDate', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('startDate')
        .snapshots()
        .map((snap) => snap.docs.map((d) => MtlEvent.fromFirestore(d)).toList());
  }

  /// Événements gratuits
  Stream<List<MtlEvent>> streamFreeEvents({int limit = 50}) {
    return _eventsRef
        .where('isFree', isEqualTo: true)
        .where('startDate', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('startDate')
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => MtlEvent.fromFirestore(d)).toList());
  }

  /// Événements par catégorie
  Stream<List<MtlEvent>> streamByCategory(String category, {int limit = 50}) {
    return _eventsRef
        .where('category', isEqualTo: category)
        .where('startDate', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('startDate')
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => MtlEvent.fromFirestore(d)).toList());
  }

  /// Événements ce week-end
  Stream<List<MtlEvent>> streamWeekendEvents() {
    final now = DateTime.now();
    final daysUntilSaturday = DateTime.saturday - now.weekday;
    final saturday = DateTime(now.year, now.month, now.day)
        .add(Duration(days: daysUntilSaturday >= 0 ? daysUntilSaturday : 7 + daysUntilSaturday));
    final monday = saturday.add(const Duration(days: 2));
    return _eventsRef
        .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(saturday))
        .where('startDate', isLessThan: Timestamp.fromDate(monday))
        .orderBy('startDate')
        .snapshots()
        .map((snap) => snap.docs.map((d) => MtlEvent.fromFirestore(d)).toList());
  }

  /// Détail d'un événement unique
  Future<MtlEvent?> getEvent(String eventId) async {
    final doc = await _eventsRef.doc(eventId).get();
    if (!doc.exists) return null;
    return MtlEvent.fromFirestore(doc);
  }

  /// Recherche textuelle simple
  Future<List<MtlEvent>> searchEvents(String query) async {
    // Firestore ne supporte pas le full-text search nativement.
    // On filtre côté client pour l'instant — Algolia recommandé en production.
    final snap = await _eventsRef
        .where('startDate', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('startDate')
        .limit(200)
        .get();

    final q = query.toLowerCase();
    return snap.docs
        .map((d) => MtlEvent.fromFirestore(d))
        .where((e) =>
            e.title.toLowerCase().contains(q) ||
            e.venue.toLowerCase().contains(q) ||
            e.category.toLowerCase().contains(q))
        .toList();
  }

  /// Métadonnées de la dernière synchronisation
  Future<DateTime?> getLastSync(String source) async {
    final doc = await _db
        .collection(AppConstants.metadataCollection)
        .doc('sync_$source')
        .get();
    if (!doc.exists) return null;
    return (doc.data()?['lastSync'] as Timestamp?)?.toDate();
  }
}
