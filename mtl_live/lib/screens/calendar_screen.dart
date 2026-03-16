import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event_model.dart';
import '../providers/providers.dart';
import '../theme/mtl_theme.dart';
import '../utils/date_helpers.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

/// Écran Calendrier — Vue mois / semaine / jour
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return Scaffold(
      backgroundColor: MtlColors.darkBg,
      appBar: AppBar(
        backgroundColor: MtlColors.darkBg,
        title: const Text('Calendrier'),
        actions: [
          // Toggle format
          IconButton(
            icon: Icon(
              _calendarFormat == CalendarFormat.month
                  ? Icons.view_week
                  : Icons.calendar_month,
            ),
            onPressed: () {
              setState(() {
                _calendarFormat = _calendarFormat == CalendarFormat.month
                    ? CalendarFormat.week
                    : CalendarFormat.month;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendrier
          eventsAsync.when(
            data: (events) => _buildCalendar(events),
            loading: () => _buildCalendar([]),
            error: (_, __) => _buildCalendar([]),
          ),

          const Divider(color: MtlColors.darkCardAlt, height: 1),

          // Header jour sélectionné
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(
                  DateHelpers.fullDate(_selectedDay),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: MtlColors.blanc,
                  ),
                ),
              ],
            ),
          ),

          // Liste des événements du jour sélectionné
          Expanded(
            child: eventsAsync.when(
              data: (events) {
                final dayEvents = events.where((e) {
                  return e.startDate.year == _selectedDay.year &&
                      e.startDate.month == _selectedDay.month &&
                      e.startDate.day == _selectedDay.day;
                }).toList()
                  ..sort((a, b) => a.startDate.compareTo(b.startDate));

                if (dayEvents.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun événement ce jour',
                      style: TextStyle(color: MtlColors.darkTextSecondary),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dayEvents.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: EventCard(
                      event: dayEvents[index],
                      compact: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailScreen(
                              eventId: dayEvents[index].id),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(List<MtlEvent> events) {
    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 30)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      locale: 'fr_FR',
      startingDayOfWeek: StartingDayOfWeek.monday,
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        setState(() => _calendarFormat = format);
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      eventLoader: (day) {
        return events.where((e) =>
            e.startDate.year == day.year &&
            e.startDate.month == day.month &&
            e.startDate.day == day.day).toList();
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        defaultTextStyle: const TextStyle(color: MtlColors.darkText),
        weekendTextStyle: const TextStyle(color: MtlColors.darkText),
        todayDecoration: BoxDecoration(
          color: MtlColors.bleuMtl.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: MtlColors.orangeMtl,
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: MtlColors.orangeMtl,
          shape: BoxShape.circle,
        ),
        markerSize: 6,
        markersMaxCount: 3,
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          color: MtlColors.blanc,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        leftChevronIcon:
            Icon(Icons.chevron_left, color: MtlColors.orangeMtl),
        rightChevronIcon:
            Icon(Icons.chevron_right, color: MtlColors.orangeMtl),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
            color: MtlColors.darkTextSecondary, fontSize: 12),
        weekendStyle: TextStyle(
            color: MtlColors.darkTextSecondary, fontSize: 12),
      ),
    );
  }
}
