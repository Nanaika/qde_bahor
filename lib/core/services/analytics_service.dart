/// Пример сервиса для аналитики
/// В реальном проекте здесь будет интеграция с Firebase Analytics, Mixpanel и т.д.
abstract class AnalyticsService {
  void logEvent(String eventName, {Map<String, dynamic>? parameters});
  void setUserProperty(String name, String value);
  void setUserId(String userId);
}

class AnalyticsServiceImpl implements AnalyticsService {
  @override
  void logEvent(String eventName, {Map<String, dynamic>? parameters}) {
    // Моковая реализация - в реальном проекте здесь будет вызов API аналитики
    print('📊 Analytics Event: $eventName');
    if (parameters != null) {
      print('   Parameters: $parameters');
    }
  }

  @override
  void setUserProperty(String name, String value) {
    // Моковая реализация
    print('📊 User Property: $name = $value');
  }

  @override
  void setUserId(String userId) {
    // Моковая реализация
    print('📊 User ID: $userId');
  }
}

