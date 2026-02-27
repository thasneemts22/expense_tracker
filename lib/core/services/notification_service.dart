import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
    
      },
    );

    
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> showLimitExceededNotification({
    required double currentTotal,
    required double limit,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'budget_alerts_channel',
          'Budget Alerts',
          channelDescription:
              'Notifications for when monthly budget is exceeded',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id: 0, 
      title: 'Budget Alert!',
      body:
          'You have exceeded your monthly limit of ₹${limit.toStringAsFixed(0)}. Current total: ₹${currentTotal.toStringAsFixed(0)}',
      notificationDetails: platformChannelSpecifics,
      payload: 'limit_exceeded',
    );
  }
}
