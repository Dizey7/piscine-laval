import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/event_model.dart';
import '../providers/providers.dart';
import '../theme/mtl_theme.dart';
import '../utils/date_helpers.dart';
import 'source_badge.dart';

/// Hero section — Top 8 événements du mois par impact score
class HeroCarousel extends ConsumerWidget {
  final void Function(MtlEvent event) onEventTap;

  const HeroCarousel({super.key, required this.onEventTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topEvents = ref.watch(topEventsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(
            'Les meilleurs événements à venir ce mois',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: MtlColors.blanc,
            ),
          ),
        ),
        SizedBox(
          height: 260,
          child: topEvents.when(
            data: (events) {
              if (events.isEmpty) {
                return const Center(
                  child: Text(
                    'Aucun événement à venir',
                    style: TextStyle(color: MtlColors.darkTextSecondary),
                  ),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: events.length,
                itemBuilder: (context, index) =>
                    _HeroCard(event: events[index], onTap: () => onEventTap(events[index])),
              );
            },
            loading: () => _buildShimmer(),
            error: (e, _) => Center(
              child: Text('Erreur : $e',
                  style: const TextStyle(color: MtlColors.darkTextSecondary)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        width: 220,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: MtlColors.darkCard,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final MtlEvent event;
  final VoidCallback onTap;

  const _HeroCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: MtlColors.darkCard,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                if (event.imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: event.imageUrl!,
                    height: 140,
                    width: 220,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 140,
                      color: MtlColors.darkCardAlt,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 140,
                      color: MtlColors.darkCardAlt,
                      child: const Icon(Icons.event, color: MtlColors.darkTextSecondary),
                    ),
                  )
                else
                  Container(
                    height: 140,
                    width: 220,
                    color: MtlColors.darkCardAlt,
                    child: const Icon(Icons.event, size: 36, color: MtlColors.darkTextSecondary),
                  ),

                // Impact badge
                if (event.impactScore != null && event.impactScore! >= 70)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [MtlColors.predictHQ, MtlColors.bleuMtl],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Top ${event.impactScore!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Infos
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: MtlColors.blanc,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateHelpers.dateTimeDisplay(event.startDate),
                      style: const TextStyle(
                        fontSize: 11,
                        color: MtlColors.darkTextSecondary,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          event.priceDisplay,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: event.isFree
                                ? MtlColors.gratuit
                                : MtlColors.orangeMtl,
                          ),
                        ),
                        const Spacer(),
                        SourceBadge(source: event.source, mini: true),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
