import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../models/filter_model.dart';
import '../providers/providers.dart';
import '../theme/mtl_theme.dart';

/// Bottom sheet de filtres complet
class FilterSheet extends ConsumerWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(eventFilterProvider);
    final notifier = ref.read(eventFilterProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: MtlColors.darkSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle + Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: MtlColors.darkTextSecondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Filtres',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: MtlColors.blanc,
                          ),
                        ),
                        if (filter.isActive)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: MtlColors.orangeMtl,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${filter.activeCount}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: MtlColors.blanc,
                              ),
                            ),
                          ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => notifier.reset(),
                          child: const Text(
                            'Réinitialiser',
                            style: TextStyle(color: MtlColors.orangeMtl),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(color: MtlColors.darkCardAlt),

              // Filtres scrollables
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ── Date ──
                    _sectionTitle('Date'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: DateFilter.values.map((d) {
                        final selected = filter.dateFilter == d;
                        return ChoiceChip(
                          label: Text(d.label),
                          selected: selected,
                          onSelected: (_) => notifier.updateDateFilter(d),
                          selectedColor: MtlColors.bleuMtl,
                          backgroundColor: MtlColors.darkCardAlt,
                          labelStyle: TextStyle(
                            color: selected ? MtlColors.blanc : MtlColors.darkText,
                            fontSize: 13,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ── Catégorie ──
                    _sectionTitle('Catégorie'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: EventCategory.values.map((cat) {
                        final selected = filter.categories.contains(cat.label);
                        return FilterChip(
                          label: Text('${cat.emoji} ${cat.label}'),
                          selected: selected,
                          onSelected: (_) => notifier.toggleCategory(cat.label),
                          selectedColor: MtlColors.bleuMtl,
                          backgroundColor: MtlColors.darkCardAlt,
                          checkmarkColor: MtlColors.blanc,
                          labelStyle: TextStyle(
                            color: selected ? MtlColors.blanc : MtlColors.darkText,
                            fontSize: 13,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ── Prix ──
                    _sectionTitle('Prix'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildToggleChip(
                          'Gratuit seulement',
                          filter.freeOnly,
                          () => notifier.toggleFreeOnly(),
                        ),
                        ...PriceFilter.values
                            .where((p) => p != PriceFilter.all && p != PriceFilter.custom)
                            .map((p) {
                          final selected = filter.priceFilter == p && !filter.freeOnly;
                          return ChoiceChip(
                            label: Text(p.label),
                            selected: selected,
                            onSelected: (_) => notifier.updatePriceFilter(p),
                            selectedColor: MtlColors.bleuMtl,
                            backgroundColor: MtlColors.darkCardAlt,
                            labelStyle: TextStyle(
                              color: selected ? MtlColors.blanc : MtlColors.darkText,
                              fontSize: 13,
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Localisation ──
                    _sectionTitle('Localisation'),
                    _sectionSubtitle('Rayon'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [1.0, 3.0, 5.0, 10.0, 25.0].map((r) {
                        final selected = filter.radiusKm == r;
                        return ChoiceChip(
                          label: Text('${r.toStringAsFixed(0)} km'),
                          selected: selected,
                          onSelected: (_) =>
                              notifier.setRadius(selected ? null : r),
                          selectedColor: MtlColors.bleuMtl,
                          backgroundColor: MtlColors.darkCardAlt,
                          labelStyle: TextStyle(
                            color: selected ? MtlColors.blanc : MtlColors.darkText,
                            fontSize: 13,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    _sectionSubtitle('Quartiers'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MontrealNeighborhoods.all.map((n) {
                        final selected = filter.neighborhoods.contains(n);
                        return FilterChip(
                          label: Text(n),
                          selected: selected,
                          onSelected: (_) => notifier.toggleNeighborhood(n),
                          selectedColor: MtlColors.bleuMtl,
                          backgroundColor: MtlColors.darkCardAlt,
                          checkmarkColor: MtlColors.blanc,
                          labelStyle: TextStyle(
                            color: selected ? MtlColors.blanc : MtlColors.darkText,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ── Intérieur / Extérieur ──
                    _sectionTitle('Intérieur / Extérieur'),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Intérieur'),
                          selected: filter.isIndoor == true,
                          onSelected: (_) => notifier.setIndoor(
                              filter.isIndoor == true ? null : true),
                          selectedColor: MtlColors.bleuMtl,
                          backgroundColor: MtlColors.darkCardAlt,
                        ),
                        ChoiceChip(
                          label: const Text('Extérieur'),
                          selected: filter.isIndoor == false,
                          onSelected: (_) => notifier.setIndoor(
                              filter.isIndoor == false ? null : false),
                          selectedColor: MtlColors.bleuMtl,
                          backgroundColor: MtlColors.darkCardAlt,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Options ──
                    _sectionTitle('Options'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildToggleChip(
                          'Météo-compatible',
                          filter.weatherCompatible,
                          () => notifier.toggleWeatherCompatible(),
                        ),
                        _buildToggleChip(
                          'Famille',
                          filter.familyFriendlyOnly,
                          () => notifier.toggleFamilyFriendly(),
                        ),
                        _buildToggleChip(
                          '18+',
                          filter.adultOnly,
                          () => notifier.toggleAdultOnly(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Tri ──
                    _sectionTitle('Trier par'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SortOption.values.map((s) {
                        final selected = filter.sortBy == s;
                        return ChoiceChip(
                          label: Text(s.label),
                          selected: selected,
                          onSelected: (_) => notifier.updateSort(s),
                          selectedColor: MtlColors.bleuMtl,
                          backgroundColor: MtlColors.darkCardAlt,
                          labelStyle: TextStyle(
                            color: selected ? MtlColors.blanc : MtlColors.darkText,
                            fontSize: 13,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // Bouton Appliquer
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Appliquer les filtres'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: MtlColors.blanc,
          ),
        ),
      );

  Widget _sectionSubtitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: MtlColors.darkTextSecondary,
          ),
        ),
      );

  Widget _buildToggleChip(String label, bool selected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: MtlColors.orangeMtl,
      backgroundColor: MtlColors.darkCardAlt,
      checkmarkColor: MtlColors.blanc,
      labelStyle: TextStyle(
        color: selected ? MtlColors.blanc : MtlColors.darkText,
        fontSize: 13,
      ),
    );
  }
}
