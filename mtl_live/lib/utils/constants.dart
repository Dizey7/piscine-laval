/// Constantes de l'application MTL Live
class AppConstants {
  AppConstants._();

  // App
  static const String appName = 'MTL Live';
  static const String appTagline = 'Toutes les activités en temps réel à Montréal';

  // Montréal coordonnées centre
  static const double mtlLatitude = 45.5017;
  static const double mtlLongitude = -73.5673;

  // API Keys (à remplacer par les vraies clés — stockées dans .env)
  static const String ticketmasterApiKey = 'TICKETMASTER_API_KEY';
  static const String predictHqApiKey = 'PREDICTHQ_API_KEY';
  static const String googleMapsApiKey = 'GOOGLE_MAPS_API_KEY';

  // API URLs
  static const String ticketmasterBaseUrl = 'https://app.ticketmaster.com/discovery/v2';
  static const String ticketmasterAvailabilityUrl = 'https://app.ticketmaster.com/availability/v1';
  static const String predictHqBaseUrl = 'https://api.predicthq.com/v1';
  static const String openMeteoBaseUrl = 'https://api.open-meteo.com/v1';
  static const String villeMtlOpenDataUrl = 'https://donnees.montreal.ca/api/3/action';
  static const String stmGtfsUrl = 'https://api.stm.info/pub/od/gtfs-rt/ic/v2';

  // Refresh intervals
  static const Duration ticketmasterRefresh = Duration(minutes: 15);
  static const Duration villeMtlRefresh = Duration(hours: 24);
  static const Duration weatherRefresh = Duration(hours: 1);
  static const Duration staleDataThreshold = Duration(minutes: 30);

  // Cache
  static const Duration offlineCacheDuration = Duration(days: 7);
  static const String hiveCacheBox = 'mtl_live_cache';
  static const String hiveSettingsBox = 'mtl_live_settings';

  // Firestore collections
  static const String eventsCollection = 'events';
  static const String usersCollection = 'users';
  static const String weatherCollection = 'weather';
  static const String metadataCollection = 'metadata';
  static const String photosCollection = 'event_photos';

  // Rayons de recherche (km)
  static const List<double> searchRadii = [1.0, 3.0, 5.0, 10.0, 25.0];
  static const double defaultRadius = 5.0;

  // Pagination
  static const int pageSize = 20;
  static const int heroEventCount = 8;
}
