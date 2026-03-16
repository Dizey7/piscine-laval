import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/mtl_theme.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

/// Écran Live / En cours maintenant
class LiveScreen extends ConsumerWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveEvents = ref.watch(liveNowEventsProvider);
    final todayEvents = ref.watch(todayEventsProvider);

    return Scaffold(
      backgroundColor: MtlColors.darkBg,
      appBar: AppBar(
        backgroundColor: MtlColors.darkBg,
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text('En direct'),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // En cours maintenant
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'En cours maintenant',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: MtlColors.blanc,
                ),
              ),
            ),
          ),

          liveEvents.when(
            data: (events) {
              if (events.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.nightlight_round,
                              size: 48, color: MtlColors.darkTextSecondary),
                          SizedBox(height: 12),
                          Text(
                            'Rien en cours en ce moment',
                            style: TextStyle(
                              fontSize: 15,
                              color: MtlColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
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
                    childCount: events.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(color: MtlColors.orangeMtl),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('Erreur: $e')),
            ),
          ),

          // Plus tard aujourd'hui
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                "Plus tard aujourd'hui",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: MtlColors.blanc,
                ),
              ),
            ),
          ),

          todayEvents.when(
            data: (events) {
              final upcoming = events
                  .where((e) => e.startDate.isAfter(DateTime.now()))
                  .toList();
              if (upcoming.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Rien de prévu plus tard aujourd'hui",
                      style: TextStyle(color: MtlColors.darkTextSecondary),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: EventCard(
                        event: upcoming[index],
                        compact: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventDetailScreen(
                                eventId: upcoming[index].id),
                          ),
                        ),
                      ),
                    ),
                    childCount: upcoming.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox()),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
