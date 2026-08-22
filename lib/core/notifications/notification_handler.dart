import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHandler {
  final FlutterLocalNotificationsPlugin _localNotifications;

  NotificationHandler(this._localNotifications);

  void onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      // Навигация или другая логика на основе payload
    }
  }

  Future<void> onForegroundMessage(RemoteMessage message) async {
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default Channel',
          channelDescription: 'Default notification channel',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  void onNotificationOpened(RemoteMessage message) {
    // Навигация или другая логика на основе данных уведомления
    if (message.data.isNotEmpty) {
      // Обработка данных
    }
  }
}

