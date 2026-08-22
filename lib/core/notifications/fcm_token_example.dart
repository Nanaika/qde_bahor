import 'package:qde_eco_bahor/core/di/injection_container.dart';
import 'package:qde_eco_bahor/core/notifications/notification_service.dart';

class FCMTokenExample {
  static Future<String?> getFCMToken() async {
    try {
      if (getIt.isRegistered<NotificationService>()) {
        final notificationService = getIt<NotificationService>();
        final token = await notificationService.getFCMToken();

        if (token != null) {
          print('FCM Token: $token');
          print('Используйте этот токен для отправки тестовых уведомлений из Firebase Console');
          return token;
        } else {
          print('FCM Token не получен');
          return null;
        }
      } else {
        print('NotificationService не зарегистрирован. Firebase не настроен.');
        return null;
      }
    } catch (e) {
      print('Ошибка при получении FCM токена: $e');
      return null;
    }
  }

  /// Отправить токен на сервер (пример)
  ///
  /// В реальном приложении вы должны отправить токен на ваш backend сервер
  /// для сохранения и последующей отправки уведомлений
  static Future<void> sendTokenToServer(String token) async {
    // Пример отправки токена на сервер
    // final response = await http.post(
    //   Uri.parse('https://your-api.com/fcm-token'),
    //   body: jsonEncode({'token': token}),
    // );
    print('Токен должен быть отправлен на сервер: $token');
  }
}
