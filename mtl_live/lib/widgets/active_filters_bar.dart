import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/mtl_theme.dart';

/// Barre de chips actives affichée en haut des listes filtrées
class ActiveFiltersBar extends ConsumerWidget {
  const ActiveFiltersBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(eventFilterProvider);

    if (!filter.isActive) return const SizedBox.shrink();

    final labels = filter.activeLabels;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: labels.length + 1, // +1 pour le bouton "Effacer"
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == labels.length) {
            return ActionChip(
              label: const Text('Effacer tout'),
              onPressed: () => ref.read(eventFilterProvider.notifier).reset(),
              backgroundColor: MtlColors.annule.withValues(alpha: 0.2),
              labelStyle: const TextStyle(
                color: MtlColors.annule,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide.none,
            );
          }
          return Chip(
            label: Text(labels[index]),
            backgroundColor: MtlColors.bleuMtl.withValues(alpha: 0.2),
            labelStyle: const TextStyle(
              color: MtlColors.blanc,
              fontSize: 12,
            ),
            side: BorderSide.none,
            deleteIcon: const Icon(Icons.close, size: 14, color: MtlColors.blanc),
            onDeleted: () {
              // Simplified: reset all for now. Full impl would remove individual filters.
              ref.read(eventFilterProvider.notifier).reset();
            },
          );
        },
      ),
    );
  }
}
