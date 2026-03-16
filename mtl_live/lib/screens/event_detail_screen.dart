import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/event_model.dart';
import '../providers/providers.dart';
import '../theme/mtl_theme.dart';
import '../utils/date_helpers.dart';
import '../utils/extensions.dart';
import '../widgets/source_badge.dart';
import '../widgets/status_badge.dart';

/// Écran détail complet d'un événement
class EventDetailScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(eventId));

    return Scaffold(
      backgroundColor: MtlColors.darkBg,
      body: eventAsync.when(
        data: (event) {
          if (event == null) {
            return const Center(
              child: Text('Événement introuvable',
                  style: TextStyle(color: MtlColors.darkTextSecondary)),
            );
          }
          return _buildContent(context, ref, event);
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

  Widget _buildContent(BuildContext context, WidgetRef ref, MtlEvent event) {
    return CustomScrollView(
      slivers: [
        // Header image avec hero
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: MtlColors.darkBg,
          leading: IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.black54,
              child: Icon(Icons.arrow_back, color: MtlColors.blanc),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.share, color: MtlColors.blanc, size: 20),
              ),
              onPressed: () => _share(event),
            ),
            IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.black54,
                child:
                    Icon(Icons.favorite_border, color: MtlColors.blanc, size: 20),
              ),
              onPressed: () => _toggleFavorite(ref, event),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (event.imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: event.imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: MtlColors.darkCardAlt,
                    ),
                  )
                else
                  Container(color: MtlColors.darkCardAlt),

                // Gradient overlay
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),

                // Countdown
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: event.isLiveNow
                          ? Colors.red
                          : MtlColors.orangeMtl,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.isLiveNow
                          ? 'EN DIRECT MAINTENANT'
                          : DateHelpers.countdown(event.timeUntilStart),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: MtlColors.blanc,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Contenu
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Catégorie + Statut
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: MtlColors.bleuMtl.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event.category,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: MtlColors.blanc,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(status: event.status),
                    const Spacer(),
                    if (event.impactScore != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: MtlColors.predictHQ.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Impact ${event.impactScore!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: MtlColors.predictHQ,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Titre
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: MtlColors.blanc,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Prix Live + Source ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MtlColors.darkCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: MtlColors.orangeMtl.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            event.priceDisplay,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: event.isFree
                                  ? MtlColors.gratuit
                                  : MtlColors.orangeMtl,
                            ),
                          ),
                          const Spacer(),
                          SourceBadge(source: event.source),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Mis à jour ${DateHelpers.timeAgo(event.lastUpdated)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: MtlColors.darkTextSecondary,
                        ),
                      ),
                      if (event.isDataStale)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  size: 14, color: Colors.amber.shade300),
                              const SizedBox(width: 4),
                              Text(
                                'Données potentiellement obsolètes (> 30 min)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.amber.shade300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (event.availableTickets != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${event.availableTickets} places restantes',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: event.availableTickets! < 50
                                ? MtlColors.presqueComplet
                                : MtlColors.disponible,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Date et heure ──
                _infoRow(Icons.calendar_today, 'Date',
                    DateHelpers.fullDate(event.startDate)),
                _infoRow(Icons.access_time, 'Heure',
                    DateHelpers.time(event.startDate)),
                if (event.endDate != null)
                  _infoRow(Icons.timelapse, 'Fin',
                      DateHelpers.dateTimeDisplay(event.endDate!)),

                const SizedBox(height: 16),

                // ── Lieu ──
                _infoRow(Icons.location_on, 'Lieu', event.venue),
                if (event.venueAddress != null)
                  _infoRow(Icons.map_outlined, 'Adresse', event.venueAddress!),
                if (event.neighborhood != null)
                  _infoRow(Icons.location_city, 'Quartier', event.neighborhood!),
                if (event.nearestMetro != null)
                  _infoRow(Icons.train, 'Métro', event.nearestMetro!),

                const SizedBox(height: 16),

                // ── Infos supplémentaires ──
                Row(
                  children: [
                    if (event.isIndoor)
                      _tagChip('Intérieur')
                    else
                      _tagChip('Extérieur'),
                    if (event.isFamilyFriendly) _tagChip('Famille'),
                    if (event.isAdultOnly) _tagChip('18+'),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Description ──
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: MtlColors.blanc,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: MtlColors.darkText,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Tags ──
                if (event.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: event.tags.map((t) => Chip(
                          label: Text(t),
                          backgroundColor: MtlColors.darkCardAlt,
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            color: MtlColors.darkText,
                          ),
                          side: BorderSide.none,
                        )).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Source ──
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MtlColors.darkCard,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified,
                          size: 16, color: MtlColors.disponible),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Source : ${event.source} (données officielles)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: MtlColors.darkText,
                          ),
                        ),
                      ),
                      if (event.sourceUrl != null)
                        TextButton(
                          onPressed: () => _launchUrl(event.sourceUrl!),
                          child: const Text(
                            'Voir',
                            style: TextStyle(color: MtlColors.orangeMtl),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: MtlColors.orangeMtl),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: MtlColors.darkTextSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: MtlColors.blanc,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: MtlColors.darkCardAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: MtlColors.darkText),
      ),
    );
  }

  Future<void> _toggleFavorite(WidgetRef ref, MtlEvent event) async {
    final authService = ref.read(authServiceProvider);
    if (authService.currentUser == null) return;
    await authService.toggleFavorite(event.id);

    // Schedule reminder
    final notifService = ref.read(notificationServiceProvider);
    await notifService.scheduleEventReminder(
      eventId: event.id,
      title: event.title,
      venue: event.venue,
      startTime: event.startDate,
    );
  }

  Future<void> _share(MtlEvent event) async {
    await SharePlus.instance.share(
      ShareParams(
        text: '${event.title}\n${DateHelpers.fullDate(event.startDate)} à ${event.venue}\n${event.priceDisplay}\n\nVia MTL Live',
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
