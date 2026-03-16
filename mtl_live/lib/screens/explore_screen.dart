import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../providers/providers.dart';
import '../theme/mtl_theme.dart';
import '../widgets/event_card.dart';
import '../widgets/quick_filters.dart';
import '../widgets/active_filters_bar.dart';
import '../widgets/filter_sheet.dart';
import 'event_detail_screen.dart';

/// Écran Explorer / Découverte — Liste complète filtrée
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredEvents = ref.watch(filteredEventsProvider);
    final filter = ref.watch(eventFilterProvider);

    return Scaffold(
      backgroundColor: MtlColors.darkBg,
      appBar: AppBar(
        backgroundColor: MtlColors.darkBg,
        title: const Text('Explorer'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: filter.isActive,
              label: Text('${filter.activeCount}'),
              child: const Icon(Icons.tune),
            ),
            onPressed: () => _openFilters(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const QuickFilters(),
          const SizedBox(height: 8),
          const ActiveFiltersBar(),
          const SizedBox(height: 8),

          // Grille de catégories rapides
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: EventCategory.values.map((cat) {
                return _CategoryTile(
                  category: cat,
                  onTap: () => ref
                      .read(eventFilterProvider.notifier)
                      .toggleCategory(cat.label),
                  isSelected: filter.categories.contains(cat.label),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Liste des événements
          Expanded(
            child: filteredEvents.when(
              data: (events) {
                if (events.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 60, color: MtlColors.darkTextSecondary),
                        SizedBox(height: 12),
                        Text(
                          'Aucun événement trouvé',
                          style: TextStyle(
                            fontSize: 16,
                            color: MtlColors.darkTextSecondary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Essaie de modifier tes filtres',
                          style: TextStyle(
                            fontSize: 13,
                            color: MtlColors.darkTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: events.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: EventCard(
                      event: events[index],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EventDetailScreen(eventId: events[index].id),
                        ),
                      ),
                    ),
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: MtlColors.orangeMtl),
              ),
              error: (e, _) => Center(
                child: Text('Erreur: $e',
                    style: const TextStyle(color: MtlColors.annule)),
              ),
            ),
          ),
        ],
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
}

class _CategoryTile extends StatelessWidget {
  final EventCategory category;
  final VoidCallback onTap;
  final bool isSelected;

  const _CategoryTile({
    required this.category,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? MtlColors.bleuMtl : MtlColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: MtlColors.orangeMtl, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 6),
            Text(
              category.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: MtlColors.blanc,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
