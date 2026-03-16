import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../models/filter_model.dart';
import '../providers/providers.dart';
import '../theme/mtl_theme.dart';

/// Filtres rapides horizontaux scrollables
class QuickFilters extends ConsumerWidget {
  const QuickFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(eventFilterProvider);
    final notifier = ref.read(eventFilterProvider.notifier);

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          // Date rapide
          _QuickChip(
            label: "Aujourd'hui",
            selected: filter.dateFilter == DateFilter.today,
            onTap: () => notifier.updateDateFilter(
              filter.dateFilter == DateFilter.today
                  ? DateFilter.all
                  : DateFilter.today,
            ),
          ),
          _QuickChip(
            label: 'Ce week-end',
            selected: filter.dateFilter == DateFilter.thisWeekend,
            onTap: () => notifier.updateDateFilter(
              filter.dateFilter == DateFilter.thisWeekend
                  ? DateFilter.all
                  : DateFilter.thisWeekend,
            ),
          ),
          _QuickChip(
            label: 'Gratuit',
            icon: Icons.money_off,
            selected: filter.freeOnly,
            onTap: () => notifier.toggleFreeOnly(),
          ),

          // Catégories rapides
          ...EventCategory.values.take(6).map((cat) => _QuickChip(
                label: '${cat.emoji} ${cat.label}',
                selected: filter.categories.contains(cat.label),
                onTap: () => notifier.toggleCategory(cat.label),
              )),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _QuickChip({
    required this.label,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14,
                  color: selected ? MtlColors.blanc : MtlColors.darkText),
              const SizedBox(width: 4),
            ],
            Text(label),
          ],
        ),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: MtlColors.bleuMtl,
        backgroundColor: MtlColors.darkCardAlt,
        checkmarkColor: MtlColors.blanc,
        labelStyle: TextStyle(
          color: selected ? MtlColors.blanc : MtlColors.darkText,
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
