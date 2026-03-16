import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/mtl_theme.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';
import 'auth_screen.dart';

/// Écran Favoris / Mes plans
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = ref.watch(isLoggedInProvider);

    if (!isLoggedIn) {
      return Scaffold(
        backgroundColor: MtlColors.darkBg,
        appBar: AppBar(
          backgroundColor: MtlColors.darkBg,
          title: const Text('Mes plans'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite_border,
                  size: 64, color: MtlColors.darkTextSecondary),
              const SizedBox(height: 16),
              const Text(
                'Connecte-toi pour sauvegarder\ntes événements préférés',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: MtlColors.darkTextSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                ),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    final favoriteIdsAsync = ref.watch(userFavoriteIdsProvider);
    final allEventsAsync = ref.watch(upcomingEventsProvider);

    return Scaffold(
      backgroundColor: MtlColors.darkBg,
      appBar: AppBar(
        backgroundColor: MtlColors.darkBg,
        title: const Text('Mes plans'),
      ),
      body: favoriteIdsAsync.when(
        data: (favoriteIds) {
          if (favoriteIds.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border,
                      size: 64, color: MtlColors.darkTextSecondary),
                  SizedBox(height: 16),
                  Text(
                    'Aucun événement sauvegardé',
                    style: TextStyle(
                      fontSize: 16,
                      color: MtlColors.darkTextSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Appuie sur « J\'y vais » pour ajouter',
                    style: TextStyle(
                      fontSize: 13,
                      color: MtlColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return allEventsAsync.when(
            data: (allEvents) {
              final favEvents = allEvents
                  .where((e) => favoriteIds.contains(e.id))
                  .toList()
                ..sort((a, b) => a.startDate.compareTo(b.startDate));

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favEvents.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EventCard(
                    event: favEvents[index],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EventDetailScreen(eventId: favEvents[index].id),
                      ),
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: MtlColors.orangeMtl),
            ),
            error: (e, _) => Center(child: Text('Erreur: $e')),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: MtlColors.orangeMtl),
        ),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}
