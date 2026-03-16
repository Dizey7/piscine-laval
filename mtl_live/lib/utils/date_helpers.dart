import 'package:intl/intl.dart';

/// Helpers de formatage de dates en français québécois
class DateHelpers {
  DateHelpers._();

  static final DateFormat _fullDate = DateFormat('EEEE d MMMM yyyy', 'fr_CA');
  static final DateFormat _shortDate = DateFormat('d MMM', 'fr_CA');
  static final DateFormat _time = DateFormat('HH:mm', 'fr_CA');
  static final DateFormat _dayMonth = DateFormat('d MMMM', 'fr_CA');
  static final DateFormat _dayOfWeek = DateFormat('EEEE', 'fr_CA');

  static String fullDate(DateTime date) => _fullDate.format(date);
  static String shortDate(DateTime date) => _shortDate.format(date);
  static String time(DateTime date) => _time.format(date);
  static String dayMonth(DateTime date) => _dayMonth.format(date);
  static String dayOfWeek(DateTime date) => _dayOfWeek.format(date);

  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return 'Demain';
    if (diff == -1) return 'Hier';
    if (diff > 1 && diff <= 6) return dayOfWeek(date);
    return shortDate(date);
  }

  static String dateTimeDisplay(DateTime date) {
    return '${relativeDate(date)} à ${time(date)}';
  }

  static String countdown(Duration duration) {
    if (duration.isNegative) return 'En cours';
    if (duration.inDays > 0) return 'Dans ${duration.inDays} j';
    if (duration.inHours > 0) return 'Dans ${duration.inHours} h ${duration.inMinutes.remainder(60)} min';
    if (duration.inMinutes > 0) return 'Dans ${duration.inMinutes} min';
    return 'Imminent';
  }

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    return shortDate(date);
  }
}
