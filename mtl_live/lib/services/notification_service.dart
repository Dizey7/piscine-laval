import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service de notifications push (FCM + notifications locales)
class NotificationService {
  final FirebaseMessaging _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications;

  NotificationService({
    FirebaseMessaging? fcm,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _fcm = fcm ?? FirebaseMessaging.instance,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Notifications locales
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);

    // Abonnement au topic général Montréal
    await _fcm.subscribeToTopic('mtl_events');

    // Écoute des messages en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  /// Planifie un rappel 1h avant un événement
  Future<void> scheduleEventReminder({
    required String eventId,
    required String title,
    required String venue,
    required DateTime startTime,
  }) async {
    final scheduledTime = startTime.subtract(const Duration(hours: 1));
    if (scheduledTime.isBefore(DateTime.now())) return;

    await _localNotifications.zonedSchedule(
      eventId.hashCode,
      '🎉 $title dans 1 heure !',
      'À $venue — prépare-toi !',
      _toTZDateTime(scheduledTime),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_reminders',
          'Rappels d\'événements',
          channelDescription: 'Notifications de rappel avant les événements',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  /// Annule un rappel
  Future<void> cancelReminder(String eventId) async {
    await _localNotifications.cancel(eventId.hashCode);
  }

  /// Récupère le token FCM pour notifications push ciblées
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  /// Abonnement à une catégorie d'événements
  Future<void> subscribeToCategory(String category) async {
    await _fcm.subscribeToTopic('category_$category');
  }

  Future<void> unsubscribeFromCategory(String category) async {
    await _fcm.unsubscribeFromTopic('category_$category');
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mtl_live_general',
          'MTL Live',
          channelDescription: 'Notifications générales MTL Live',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // Helper pour timezone-aware scheduling
  // En production, utiliser le package timezone
  static DateTime _toTZDateTime(DateTime dateTime) => dateTime;
}
