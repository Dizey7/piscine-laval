import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/event_model.dart';
import '../theme/mtl_theme.dart';
import '../utils/date_helpers.dart';
import '../utils/extensions.dart';
import 'source_badge.dart';
import 'status_badge.dart';

/// Carte d'événement principale — utilisée dans toutes les listes
class EventCard extends StatelessWidget {
  final MtlEvent event;
  final VoidCallback? onTap;
  final bool compact;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: MtlColors.darkCard,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: compact ? _buildCompact(context) : _buildFull(context),
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        _buildImage(height: 180),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Catégorie + Date
              Row(
                children: [
                  _categoryChip(),
                  const Spacer(),
                  Text(
                    DateHelpers.dateTimeDisplay(event.startDate),
                    style: const TextStyle(
                      fontSize: 12,
                      color: MtlColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Titre
              Text(
                event.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MtlColors.blanc,
                ),
              ),
              const SizedBox(height: 4),

              // Lieu
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: MtlColors.darkTextSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.venue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: MtlColors.darkTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Prix + Source + Statut
              Row(
                children: [
                  // Prix
                  Text(
                    event.priceDisplay,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: event.isFree ? MtlColors.gratuit : MtlColors.orangeMtl,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SourceBadge(source: event.source),
                  const Spacer(),
                  StatusBadge(status: event.status),
                ],
              ),

              // Stale data warning
              if (event.isDataStale)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 14, color: Colors.amber.shade300),
                      const SizedBox(width: 4),
                      Text(
                        'Données > 30 min',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.amber.shade300,
                        ),
                      ),
                    ],
                  ),
                ),

              // Last updated
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Mis à jour ${DateHelpers.timeAgo(event.lastUpdated)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: MtlColors.darkTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompact(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          _buildImage(width: 100, height: 100),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MtlColors.blanc,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateHelpers.dateTimeDisplay(event.startDate),
                    style: const TextStyle(
                      fontSize: 12,
                      color: MtlColors.darkTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        event.priceDisplay,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: event.isFree
                              ? MtlColors.gratuit
                              : MtlColors.orangeMtl,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SourceBadge(source: event.source, mini: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage({double? width, double? height}) {
    return Stack(
      children: [
        if (event.imageUrl != null)
          CachedNetworkImage(
            imageUrl: event.imageUrl!,
            width: width,
            height: height?.toDouble(),
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              width: width,
              height: height?.toDouble(),
              color: MtlColors.darkCardAlt,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: MtlColors.orangeMtl,
                ),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              width: width,
              height: height?.toDouble(),
              color: MtlColors.darkCardAlt,
              child: const Icon(Icons.event, color: MtlColors.darkTextSecondary),
            ),
          )
        else
          Container(
            width: width,
            height: height?.toDouble(),
            color: MtlColors.darkCardAlt,
            child: const Icon(Icons.event, size: 40, color: MtlColors.darkTextSecondary),
          ),

        // Countdown badge
        if (event.isStartingSoon)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: MtlColors.orangeMtl,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                DateHelpers.countdown(event.timeUntilStart),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: MtlColors.blanc,
                ),
              ),
            ),
          ),

        // Live badge
        if (event.isLiveNow)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'EN DIRECT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Impact badge
        if (event.impactScore != null && event.impactScore! >= 80)
          Positioned(
            top: 8,
            left: event.isLiveNow ? null : 8,
            right: event.isLiveNow ? 8 : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: MtlColors.predictHQ,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Impact élevé',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _categoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: MtlColors.bleuMtl.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        event.category,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: MtlColors.blanc,
        ),
      ),
    );
  }
}
