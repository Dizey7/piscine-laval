import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../providers/providers.dart';
import '../theme/mtl_theme.dart';
import '../utils/date_helpers.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/weather_banner.dart';
import '../widgets/quick_filters.dart';
import '../widgets/section_header.dart';
import '../widgets/event_card.dart';
import '../widgets/active_filters_bar.dart';
import '../widgets/filter_sheet.dart';
import 'event_detail_screen.dart';

/// Écran d'accueil principal — Hero + sections
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openDetail(BuildContext context, MtlEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailScreen(eventId: event.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayEvents = ref.watch(todayEventsProvider);
    final nearbyEvents = ref.watch(nearbyEventsProvider);
    final weekendEvents = ref.watch(weekendEventsProvider);
    final filteredEvents = ref.watch(filteredEventsProvider);
    final filter = ref.watch(eventFilterProvider);

    return Scaffold(
      backgroundColor: MtlColors.darkBg,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: MtlColors.darkBg,
            title: const Row(
              children: [
                Text(
                  'MTL',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: MtlColors.orangeMtl,
                  ),
                ),
                Text(
                  ' Live',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: MtlColors.blanc,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: MtlColors.blanc),
                onPressed: () => _openSearch(context),
              ),
              IconButton(
                icon: Badge(
                  isLabelVisible: filter.isActive,
                  label: Text('${filter.activeCount}'),
                  child: const Icon(Icons.tune, color: MtlColors.blanc),
                ),
                onPressed: () => _openFilters(context),
              ),
            ],
          ),

          // Contenu
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Météo
                const WeatherBanner(),

                // Hero — Top événements du mois
                HeroCarousel(
                  onEventTap: (event) => _openDetail(context, event),
                ),

                const SizedBox(height: 8),

                // Quick filters
                const QuickFilters(),

                // Active filters chips
                const ActiveFiltersBar(),
              ],
            ),
          ),

          // Si des filtres sont actifs, afficher les résultats filtrés
          if (filter.isActive) ...[
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Résultats filtrés',
                subtitle: filteredEvents.when(
                  data: (e) => '${e.length} événement${e.length > 1 ? 's' : ''}',
                  loading: () => 'Chargement...',
                  error: (_, __) => 'Erreur',
                ),
              ),
            ),
            filteredEvents.when(
              data: (events) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: EventCard(
                        event: events[index],
                        onTap: () => _openDetail(context, events[index]),
                      ),
                    ),
                    childCount: events.length,
                  ),
                ),
              ),
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('Erreur: $e')),
              ),
            ),
          ] else ...[
            // ── Aujourd'hui / En ce moment ──
            SliverToBoxAdapter(
              child: SectionHeader(
                title: "Aujourd'hui / En ce moment",
                subtitle: 'Les prochaines heures',
                onSeeAll: () {},
              ),
            ),
            _buildHorizontalEventList(todayEvents, context),

            // ── Près de moi ──
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Près de moi',
                subtitle: 'Dans un rayon de 5 km',
                onSeeAll: () {},
              ),
            ),
            _buildHorizontalEventList(nearbyEvents, context),

            // ── Ce week-end ──
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Ce week-end',
                onSeeAll: () {},
              ),
            ),
            _buildHorizontalEventList(weekendEvents, context),
          ],

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHorizontalEventList(
      AsyncValue<List<MtlEvent>> eventsAsync, BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 280,
        child: eventsAsync.when(
          data: (events) {
            if (events.isEmpty) {
              return const Center(
                child: Text(
                  'Aucun événement trouvé',
                  style: TextStyle(color: MtlColors.darkTextSecondary),
                ),
              );
            }
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: events.length.clamp(0, 10),
              itemBuilder: (context, index) {
                final event = events[index];
                return Container(
                  width: 260,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: EventCard(
                    event: event,
                    onTap: () => _openDetail(context, event),
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: MtlColors.orangeMtl),
          ),
          error: (e, _) => Center(
            child: Text(
              'Erreur de chargement',
              style: TextStyle(color: Colors.red.shade300),
            ),
          ),
        ),
      ),
    );
  }

  void _openFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterSheet(),
    );
  }

  void _openSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _EventSearchDelegate(),
    );
  }
}

class _EventSearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Rechercher un événement...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: MtlColors.darkBg,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: MtlColors.darkTextSecondary),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: MtlColors.blanc, fontSize: 16),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) => _buildSearchContent();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchContent();

  Widget _buildSearchContent() {
    if (query.isEmpty) {
      return Container(
        color: MtlColors.darkBg,
        child: const Center(
          child: Text(
            'Tapez pour rechercher...',
            style: TextStyle(color: MtlColors.darkTextSecondary),
          ),
        ),
      );
    }

    return Consumer(
      builder: (context, ref, _) {
        ref.read(searchQueryProvider.notifier).state = query;
        final results = ref.watch(searchResultsProvider);

        return Container(
          color: MtlColors.darkBg,
          child: results.when(
            data: (events) {
              if (events.isEmpty) {
                return const Center(
                  child: Text(
                    'Aucun résultat',
                    style: TextStyle(color: MtlColors.darkTextSecondary),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EventCard(
                    event: events[index],
                    compact: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EventDetailScreen(eventId: events[index].id),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: MtlColors.orangeMtl),
            ),
            error: (e, _) => Center(child: Text('Erreur: $e')),
          ),
        );
      },
    );
  }
}
