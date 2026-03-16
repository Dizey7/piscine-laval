import 'package:dio/dio.dart';
import '../utils/constants.dart';

/// Service client pour Ticketmaster Discovery API + Availability API
class TicketmasterService {
  final Dio _dio;
  final String _apiKey;

  TicketmasterService({Dio? dio, String? apiKey})
      : _dio = dio ?? Dio(),
        _apiKey = apiKey ?? AppConstants.ticketmasterApiKey;

  /// Recherche d'événements à Montréal via Discovery API
  Future<Map<String, dynamic>> searchEvents({
    int page = 0,
    int size = 50,
    String? keyword,
    String? classificationName,
    String? startDateTime,
    String? endDateTime,
    String sort = 'date,asc',
  }) async {
    final response = await _dio.get(
      '${AppConstants.ticketmasterBaseUrl}/events.json',
      queryParameters: {
        'apikey': _apiKey,
        'city': 'Montreal',
        'countryCode': 'CA',
        'stateCode': 'QC',
        'locale': 'fr-ca',
        'page': page,
        'size': size,
        'sort': sort,
        if (keyword != null) 'keyword': keyword,
        if (classificationName != null) 'classificationName': classificationName,
        if (startDateTime != null) 'startDateTime': startDateTime,
        if (endDateTime != null) 'endDateTime': endDateTime,
      },
    );
    return response.data;
  }

  /// Détails d'un événement spécifique
  Future<Map<String, dynamic>> getEventDetails(String eventId) async {
    final response = await _dio.get(
      '${AppConstants.ticketmasterBaseUrl}/events/$eventId.json',
      queryParameters: {
        'apikey': _apiKey,
        'locale': 'fr-ca',
      },
    );
    return response.data;
  }

  /// Vérification de disponibilité en temps réel (Availability API)
  Future<Map<String, dynamic>?> checkAvailability(String eventId) async {
    try {
      final response = await _dio.get(
        '${AppConstants.ticketmasterAvailabilityUrl}/availability/event/$eventId',
        queryParameters: {'apikey': _apiKey},
      );
      return response.data;
    } catch (e) {
      // L'API Availability peut ne pas être disponible pour tous les événements
      return null;
    }
  }

  /// Parse les prix depuis la réponse Ticketmaster
  static ({double? min, double? max, String? currency}) parsePriceRanges(
      Map<String, dynamic> event) {
    final priceRanges = event['priceRanges'] as List<dynamic>?;
    if (priceRanges == null || priceRanges.isEmpty) {
      return (min: null, max: null, currency: null);
    }
    final range = priceRanges.first;
    return (
      min: (range['min'] as num?)?.toDouble(),
      max: (range['max'] as num?)?.toDouble(),
      currency: range['currency'] as String?,
    );
  }

  /// Parse les images depuis la réponse Ticketmaster
  static String? parseBestImage(Map<String, dynamic> event) {
    final images = event['images'] as List<dynamic>?;
    if (images == null || images.isEmpty) return null;

    // Préférer les images en ratio 16:9 et haute résolution
    final sorted = List<Map<String, dynamic>>.from(images)
      ..sort((a, b) {
        final aW = a['width'] as int? ?? 0;
        final bW = b['width'] as int? ?? 0;
        return bW.compareTo(aW);
      });

    return sorted.first['url'] as String?;
  }

  /// Parse les coordonnées GPS
  static ({double? lat, double? lng}) parseLocation(Map<String, dynamic> event) {
    final venues = event['_embedded']?['venues'] as List<dynamic>?;
    if (venues == null || venues.isEmpty) return (lat: null, lng: null);
    final loc = venues.first['location'];
    if (loc == null) return (lat: null, lng: null);
    return (
      lat: double.tryParse(loc['latitude']?.toString() ?? ''),
      lng: double.tryParse(loc['longitude']?.toString() ?? ''),
    );
  }
}
