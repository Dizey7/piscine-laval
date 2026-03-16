import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/mtl_theme.dart';

/// Bannière météo intelligente en haut de l'accueil
class WeatherBanner extends ConsumerWidget {
  const WeatherBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(currentWeatherProvider);

    return weatherAsync.when(
      data: (weather) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: MtlColors.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: weather.shouldRecommendIndoor
                ? Border.all(color: MtlColors.presqueComplet.withValues(alpha: 0.5))
                : null,
          ),
          child: Row(
            children: [
              Text(
                weather.conditionIcon,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperatureDisplay} — ${weather.conditionLabel}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: MtlColors.blanc,
                      ),
                    ),
                    if (weather.shouldRecommendIndoor)
                      const Text(
                        'On te recommande des activités intérieures !',
                        style: TextStyle(
                          fontSize: 12,
                          color: MtlColors.presqueComplet,
                        ),
                      )
                    else
                      const Text(
                        'Parfait pour sortir !',
                        style: TextStyle(
                          fontSize: 12,
                          color: MtlColors.disponible,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
