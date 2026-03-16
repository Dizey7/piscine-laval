import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/mtl_theme.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

/// Écran Gratuit & Pas cher
class FreeScreen extends ConsumerWidget {
  const FreeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final freeEvents = ref.watch(freeEventsProvider);

    return Scaffold(
      backgroundColor: MtlColors.darkBg,
      appBar: AppBar(
        backgroundColor: MtlColors.darkBg,
        title: const Text('Gratuit & Pas cher'),
      ),
      body: freeEvents.when(
        data: (events) {
          if (events.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.money_off, size: 60, color: MtlColors.darkTextSecondary),
                  SizedBox(height: 12),
                  Text(
                    'Aucun événement gratuit pour le moment',
                    style: TextStyle(
                      fontSize: 15,
                      color: MtlColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Séparer gratuit et pas cher (< 20$)
          final free = events.where((e) => e.isFree).toList();
          final cheap = events
              .where((e) => !e.isFree && e.priceMin != null && e.priceMin! <= 20)
              .toList();

          return CustomScrollView(
            slivers: [
              // Section Gratuit
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Icon(Icons.celebration, color: MtlColors.gratuit, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Gratuit',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: MtlColors.blanc,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (free.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Aucun événement gratuit actuellement',
                        style: TextStyle(color: MtlColors.darkTextSecondary)),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: EventCard(
                          event: free[index],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EventDetailScreen(eventId: free[index].id),
                            ),
                          ),
                        ),
                      ),
                      childCount: free.length,
                    ),
                  ),
                ),

              // Section Pas cher
              if (cheap.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      'Moins de 20 \$',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MtlColors.blanc,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: EventCard(
                          event: cheap[index],
                          compact: true,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailScreen(
                                  eventId: cheap[index].id),
                            ),
                          ),
                        ),
                      ),
                      childCount: cheap.length,
                    ),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
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
    );
  }
}
