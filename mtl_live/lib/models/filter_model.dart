import 'event_model.dart';

/// Modèle de filtre persistant pour la recherche d'événements
class EventFilter {
  final DateFilter dateFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final Set<String> categories;
  final PriceFilter priceFilter;
  final double? maxPrice;
  final double? radiusKm;
  final Set<String> neighborhoods;
  final bool? isIndoor;
  final bool weatherCompatible;
  final bool familyFriendlyOnly;
  final bool adultOnly;
  final bool freeOnly;
  final SortOption sortBy;
  final String? searchQuery;

  const EventFilter({
    this.dateFilter = DateFilter.all,
    this.customStartDate,
    this.customEndDate,
    this.categories = const {},
    this.priceFilter = PriceFilter.all,
    this.maxPrice,
    this.radiusKm,
    this.neighborhoods = const {},
    this.isIndoor,
    this.weatherCompatible = false,
    this.familyFriendlyOnly = false,
    this.adultOnly = false,
    this.freeOnly = false,
    this.sortBy = SortOption.date,
    this.searchQuery,
  });

  bool get isActive =>
      dateFilter != DateFilter.all ||
      categories.isNotEmpty ||
      priceFilter != PriceFilter.all ||
      radiusKm != null ||
      neighborhoods.isNotEmpty ||
      isIndoor != null ||
      weatherCompatible ||
      familyFriendlyOnly ||
      adultOnly ||
      freeOnly ||
      searchQuery != null;

  int get activeCount {
    int count = 0;
    if (dateFilter != DateFilter.all) count++;
    if (categories.isNotEmpty) count++;
    if (priceFilter != PriceFilter.all || freeOnly) count++;
    if (radiusKm != null || neighborhoods.isNotEmpty) count++;
    if (isIndoor != null) count++;
    if (weatherCompatible) count++;
    if (familyFriendlyOnly || adultOnly) count++;
    return count;
  }

  List<String> get activeLabels {
    final labels = <String>[];
    if (dateFilter != DateFilter.all) labels.add(dateFilter.label);
    for (final cat in categories) {
      labels.add(cat);
    }
    if (freeOnly) labels.add('Gratuit');
    if (priceFilter != PriceFilter.all && !freeOnly) labels.add(priceFilter.label);
    if (radiusKm != null) labels.add('${radiusKm!.toStringAsFixed(0)} km');
    for (final n in neighborhoods) {
      labels.add(n);
    }
    if (isIndoor == true) labels.add('Intérieur');
    if (isIndoor == false) labels.add('Extérieur');
    if (weatherCompatible) labels.add('Météo-compatible');
    if (familyFriendlyOnly) labels.add('Famille');
    if (adultOnly) labels.add('18+');
    return labels;
  }

  /// Applique les filtres localement sur une liste d'événements
  List<MtlEvent> apply(List<MtlEvent> events) {
    var filtered = List<MtlEvent>.from(events);

    // Filtre texte
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final q = searchQuery!.toLowerCase();
      filtered = filtered.where((e) =>
          e.title.toLowerCase().contains(q) ||
          e.venue.toLowerCase().contains(q) ||
          e.description.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q)).toList();
    }

    // Filtre date
    final now = DateTime.now();
    switch (dateFilter) {
      case DateFilter.today:
        filtered = filtered.where((e) => e.isToday).toList();
        break;
      case DateFilter.tomorrow:
        final tomorrow = now.add(const Duration(days: 1));
        filtered = filtered.where((e) =>
            e.startDate.year == tomorrow.year &&
            e.startDate.month == tomorrow.month &&
            e.startDate.day == tomorrow.day).toList();
        break;
      case DateFilter.thisWeekend:
        filtered = filtered.where((e) => e.isThisWeekend).toList();
        break;
      case DateFilter.thisWeek:
        final endOfWeek = now.add(Duration(days: 7 - now.weekday));
        filtered = filtered.where((e) =>
            e.startDate.isAfter(now) &&
            e.startDate.isBefore(endOfWeek.add(const Duration(days: 1)))).toList();
        break;
      case DateFilter.custom:
        if (customStartDate != null) {
          filtered = filtered.where((e) =>
              e.startDate.isAfter(customStartDate!.subtract(const Duration(days: 1)))).toList();
        }
        if (customEndDate != null) {
          filtered = filtered.where((e) =>
              e.startDate.isBefore(customEndDate!.add(const Duration(days: 1)))).toList();
        }
        break;
      case DateFilter.all:
        break;
    }

    // Filtre catégorie
    if (categories.isNotEmpty) {
      filtered = filtered.where((e) => categories.contains(e.category)).toList();
    }

    // Filtre prix
    if (freeOnly) {
      filtered = filtered.where((e) => e.isFree).toList();
    } else {
      switch (priceFilter) {
        case PriceFilter.free:
          filtered = filtered.where((e) => e.isFree).toList();
          break;
        case PriceFilter.under10:
          filtered = filtered.where((e) =>
              e.isFree || (e.priceMin != null && e.priceMin! < 10)).toList();
          break;
        case PriceFilter.under20:
          filtered = filtered.where((e) =>
              e.isFree || (e.priceMin != null && e.priceMin! < 20)).toList();
          break;
        case PriceFilter.under50:
          filtered = filtered.where((e) =>
              e.isFree || (e.priceMin != null && e.priceMin! < 50)).toList();
          break;
        case PriceFilter.custom:
          if (maxPrice != null) {
            filtered = filtered.where((e) =>
                e.isFree || (e.priceMin != null && e.priceMin! <= maxPrice!)).toList();
          }
          break;
        case PriceFilter.all:
          break;
      }
    }

    // Intérieur / Extérieur
    if (isIndoor != null) {
      filtered = filtered.where((e) => e.isIndoor == isIndoor).toList();
    }

    // Famille / 18+
    if (familyFriendlyOnly) {
      filtered = filtered.where((e) => e.isFamilyFriendly).toList();
    }
    if (adultOnly) {
      filtered = filtered.where((e) => e.isAdultOnly).toList();
    }

    // Quartier
    if (neighborhoods.isNotEmpty) {
      filtered = filtered.where((e) =>
          e.neighborhood != null && neighborhoods.contains(e.neighborhood)).toList();
    }

    // Tri
    switch (sortBy) {
      case SortOption.date:
        filtered.sort((a, b) => a.startDate.compareTo(b.startDate));
        break;
      case SortOption.popularity:
        filtered.sort((a, b) =>
            (b.impactScore ?? 0).compareTo(a.impactScore ?? 0));
        break;
      case SortOption.priceAsc:
        filtered.sort((a, b) =>
            (a.priceMin ?? double.infinity).compareTo(b.priceMin ?? double.infinity));
        break;
      case SortOption.proximity:
        // Nécessite la position de l'utilisateur — trié côté provider
        break;
    }

    return filtered;
  }

  EventFilter copyWith({
    DateFilter? dateFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
    Set<String>? categories,
    PriceFilter? priceFilter,
    double? maxPrice,
    double? radiusKm,
    Set<String>? neighborhoods,
    bool? isIndoor,
    bool? weatherCompatible,
    bool? familyFriendlyOnly,
    bool? adultOnly,
    bool? freeOnly,
    SortOption? sortBy,
    String? searchQuery,
  }) {
    return EventFilter(
      dateFilter: dateFilter ?? this.dateFilter,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      categories: categories ?? this.categories,
      priceFilter: priceFilter ?? this.priceFilter,
      maxPrice: maxPrice ?? this.maxPrice,
      radiusKm: radiusKm ?? this.radiusKm,
      neighborhoods: neighborhoods ?? this.neighborhoods,
      isIndoor: isIndoor,
      weatherCompatible: weatherCompatible ?? this.weatherCompatible,
      familyFriendlyOnly: familyFriendlyOnly ?? this.familyFriendlyOnly,
      adultOnly: adultOnly ?? this.adultOnly,
      freeOnly: freeOnly ?? this.freeOnly,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  static const EventFilter empty = EventFilter();
}

enum DateFilter {
  all('Toutes les dates'),
  today('Aujourd\'hui'),
  tomorrow('Demain'),
  thisWeekend('Ce week-end'),
  thisWeek('Cette semaine'),
  custom('Dates personnalisées');

  final String label;
  const DateFilter(this.label);
}

enum PriceFilter {
  all('Tous les prix'),
  free('Gratuit'),
  under10('Moins de 10 \$'),
  under20('Moins de 20 \$'),
  under50('Moins de 50 \$'),
  custom('Prix max');

  final String label;
  const PriceFilter(this.label);
}

enum SortOption {
  date('Heure de début'),
  popularity('Popularité'),
  priceAsc('Prix croissant'),
  proximity('Proximité');

  final String label;
  const SortOption(this.label);
}

/// Quartiers de Montréal pour le filtre localisation
class MontrealNeighborhoods {
  static const List<String> all = [
    'Centre-ville',
    'Vieux-Montréal',
    'Plateau-Mont-Royal',
    'Mile End',
    'Hochelaga-Maisonneuve',
    'Rosemont–La Petite-Patrie',
    'Villeray–Saint-Michel–Parc-Extension',
    'Outremont',
    'Westmount',
    'NDG–Côte-des-Neiges',
    'Griffintown',
    'Saint-Henri',
    'Verdun',
    'Quartier des spectacles',
    'Quartier latin',
    'Parc Jean-Drapeau',
    'Laval',
    'Longueuil',
  ];
}
