import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// TO MAKE ONLY ONE VERSION OF THIS SERVICE ACROSS THE APP
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  static const String channelId = 'order_status_channel_v4';
  static const String channelName = 'Order Status Updates';
  static const String channelDescription =
      'Notifications about your prescription and order delivery status';

  // Initialize notifications, time zones, and Android notification channel
  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones(); // initialize timezone, so phone can count seconds accurately when make a notification

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(initSettings);

    // Create high-priority Android notification channel (Heads-up banner)
    const androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(androidChannel);
      await androidImplementation
          .requestNotificationsPermission(); // android 13+ needs user permission to resieve notifications
    }

    _isInitialized = true;
  }

  // Request notification permissions for Android 13+ (API 33+)
  Future<bool> requestPermission() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      final granted = await androidImplementation
          .requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  // Send immediate order status notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  // Schedule notification to fire at a specific delay (works even if app is closed)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required Duration delay,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    final scheduledDate = tz.TZDateTime.now(
      tz.local,
    ).add(delay); //takes current time and add delay

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
    );
    // send notification even if the app is closed
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cancel a scheduled or displayed notification
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
