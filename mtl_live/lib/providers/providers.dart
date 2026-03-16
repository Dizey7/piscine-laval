import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../models/event_model.dart';
import '../models/filter_model.dart';
import '../models/weather_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../services/cache_service.dart';
import '../services/notification_service.dart';

// ─── Services ─────────────────────────────────────────────

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// ─── Auth State ───────────────────────────────────────────

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).value != null;
});

// ─── Location ─────────────────────────────────────────────

final userPositionProvider = FutureProvider<Position?>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.getCurrentPosition();
});

// ─── Weather ──────────────────────────────────────────────

final currentWeatherProvider = FutureProvider<WeatherData>((ref) async {
  final weatherService = ref.watch(weatherServiceProvider);
  return await weatherService.getCurrentWeather();
});

final shouldRecommendIndoorProvider = Provider<bool>((ref) {
  final weather = ref.watch(currentWeatherProvider);
  return weather.value?.shouldRecommendIndoor ?? false;
});

// ─── Events Streams ───────────────────────────────────────

final upcomingEventsProvider = StreamProvider<List<MtlEvent>>((ref) {
  return ref.watch(firestoreServiceProvider).streamUpcomingEvents();
});

final topEventsProvider = StreamProvider<List<MtlEvent>>((ref) {
  return ref.watch(firestoreServiceProvider).streamTopEvents(limit: 8);
});

final liveNowEventsProvider = StreamProvider<List<MtlEvent>>((ref) {
  return ref.watch(firestoreServiceProvider).streamLiveNow();
});

final todayEventsProvider = StreamProvider<List<MtlEvent>>((ref) {
  return ref.watch(firestoreServiceProvider).streamTodayEvents();
});

final weekendEventsProvider = StreamProvider<List<MtlEvent>>((ref) {
  return ref.watch(firestoreServiceProvider).streamWeekendEvents();
});

final freeEventsProvider = StreamProvider<List<MtlEvent>>((ref) {
  return ref.watch(firestoreServiceProvider).streamFreeEvents();
});

// ─── Filters ──────────────────────────────────────────────

final eventFilterProvider = StateNotifierProvider<EventFilterNotifier, EventFilter>((ref) {
  return EventFilterNotifier();
});

class EventFilterNotifier extends StateNotifier<EventFilter> {
  EventFilterNotifier() : super(const EventFilter());

  void updateDateFilter(DateFilter filter) =>
      state = state.copyWith(dateFilter: filter);

  void setCustomDates(DateTime? start, DateTime? end) =>
      state = state.copyWith(
        dateFilter: DateFilter.custom,
        customStartDate: start,
        customEndDate: end,
      );

  void toggleCategory(String category) {
    final cats = Set<String>.from(state.categories);
    if (cats.contains(category)) {
      cats.remove(category);
    } else {
      cats.add(category);
    }
    state = state.copyWith(categories: cats);
  }

  void updatePriceFilter(PriceFilter filter) =>
      state = state.copyWith(priceFilter: filter);

  void setMaxPrice(double? price) =>
      state = state.copyWith(priceFilter: PriceFilter.custom, maxPrice: price);

  void setRadius(double? km) => state = state.copyWith(radiusKm: km);

  void toggleNeighborhood(String neighborhood) {
    final hoods = Set<String>.from(state.neighborhoods);
    if (hoods.contains(neighborhood)) {
      hoods.remove(neighborhood);
    } else {
      hoods.add(neighborhood);
    }
    state = state.copyWith(neighborhoods: hoods);
  }

  void setIndoor(bool? indoor) => state = state.copyWith(isIndoor: indoor);

  void toggleWeatherCompatible() =>
      state = state.copyWith(weatherCompatible: !state.weatherCompatible);

  void toggleFamilyFriendly() =>
      state = state.copyWith(familyFriendlyOnly: !state.familyFriendlyOnly);

  void toggleAdultOnly() =>
      state = state.copyWith(adultOnly: !state.adultOnly);

  void toggleFreeOnly() =>
      state = state.copyWith(freeOnly: !state.freeOnly);

  void updateSort(SortOption sort) => state = state.copyWith(sortBy: sort);

  void setSearchQuery(String? query) =>
      state = state.copyWith(searchQuery: query);

  void reset() => state = const EventFilter();
}

// ─── Filtered Events ──────────────────────────────────────

final filteredEventsProvider = Provider<AsyncValue<List<MtlEvent>>>((ref) {
  final eventsAsync = ref.watch(upcomingEventsProvider);
  final filter = ref.watch(eventFilterProvider);

  return eventsAsync.whenData((events) => filter.apply(events));
});

// ─── Nearby Events ────────────────────────────────────────

final nearbyEventsProvider = Provider<AsyncValue<List<MtlEvent>>>((ref) {
  final eventsAsync = ref.watch(upcomingEventsProvider);
  final positionAsync = ref.watch(userPositionProvider);
  final position = positionAsync.value;

  if (position == null) return eventsAsync;

  return eventsAsync.whenData((events) {
    final nearby = events.where((e) {
      if (e.latitude == null || e.longitude == null) return false;
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        e.latitude!,
        e.longitude!,
      );
      return distance <= 5000; // 5 km par défaut
    }).toList()
      ..sort((a, b) {
        final distA = Geolocator.distanceBetween(
          position.latitude, position.longitude,
          a.latitude!, a.longitude!,
        );
        final distB = Geolocator.distanceBetween(
          position.latitude, position.longitude,
          b.latitude!, b.longitude!,
        );
        return distA.compareTo(distB);
      });
    return nearby;
  });
});

// ─── Favorites ────────────────────────────────────────────

final favoritesProvider = StreamProvider<List<String>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) return Stream.value([]);

  return FirestoreService()
      .streamUpcomingEvents()
      .map((events) => events.map((e) => e.id).toList());
});

final userFavoriteIdsProvider = FutureProvider<List<String>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final profile = await authService.getUserProfile();
  return profile?.favoriteIds ?? [];
});

// ─── Search ───────────────────────────────────────────────

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<MtlEvent>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  return ref.watch(firestoreServiceProvider).searchEvents(query);
});

// ─── Single Event ─────────────────────────────────────────

final eventDetailProvider =
    FutureProvider.family<MtlEvent?, String>((ref, eventId) async {
  return ref.watch(firestoreServiceProvider).getEvent(eventId);
});

// ─── Bottom Nav ───────────────────────────────────────────

final selectedTabProvider = StateProvider<int>((ref) => 0);
