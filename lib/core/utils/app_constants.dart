class AppConstants {
  // API
  static const String baseUrl = 'https://api.example.com';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String keyLocale = 'locale';
  static const String keyTheme = 'theme';

  // Notification Channels
  static const String defaultNotificationChannel = 'default_channel';
  static const String defaultNotificationChannelName = 'Default Channel';

  //db collections names
  static const String users = 'users';
  static const String moderateUsers = 'moderateUsers';
  static const String products = 'products';
  static const String productsTypes = 'productsTypes';
  static const String orders = 'orders';

  //storage names
  static const String productsImages = 'products_images';

  // Private constructor
  AppConstants._();
}
