# Настройка Firebase для проекта

## Шаг 1: Создание проекта в Firebase Console

1. Перейдите на https://console.firebase.google.com/
2. Нажмите "Добавить проект" (Add project)
3. Введите название проекта
4. Следуйте инструкциям мастера создания проекта

## Шаг 2: Добавление Android приложения

1. В Firebase Console выберите ваш проект
2. Нажмите на иконку Android
3. Введите:
   - **Package name**: `com.example.template_flutter` (или ваш package name из `android/app/build.gradle.kts`)
   - **App nickname** (опционально): Flutter Template
   - **Debug signing certificate SHA-1** (опционально, для тестирования)
4. Нажмите "Register app"
5. Скачайте файл `google-services.json`
6. Поместите его в `android/app/google-services.json`

## Шаг 3: Добавление iOS приложения (если нужно)

1. В Firebase Console выберите ваш проект
2. Нажмите на иконку iOS
3. Введите:
   - **Bundle ID**: `com.example.templateFlutter` (или ваш bundle ID)
   - **App nickname** (опционально): Flutter Template
4. Нажмите "Register app"
5. Скачайте файл `GoogleService-Info.plist`
6. Откройте `ios/Runner.xcworkspace` в Xcode
7. Перетащите `GoogleService-Info.plist` в папку `Runner` в Xcode

## Шаг 4: Настройка Gradle для Android

✅ **Уже настроено!** Плагин Google Services уже добавлен в проект:
- В `android/build.gradle.kts` добавлен classpath для google-services
- В `android/app/build.gradle.kts` добавлен плагин `com.google.gms.google-services`

Вам нужно только добавить файл `google-services.json` в `android/app/`

## Шаг 5: Включение Firebase Cloud Messaging

1. В Firebase Console перейдите в раздел "Cloud Messaging"
2. Включите Cloud Messaging для вашего проекта
3. (Опционально) Настройте уведомления

## Шаг 6: Проверка

После настройки перезапустите приложение:

```bash
flutter clean
flutter pub get
flutter run
```

Firebase должен инициализироваться без ошибок, и уведомления будут работать.

## Шаг 7: Получение FCM токена

После запуска приложения FCM токен будет автоматически выведен в консоль. Вы увидите что-то вроде:

```
FCM Token: dK3jH8f9... (длинная строка)
Используйте этот токен для отправки тестовых уведомлений из Firebase Console
```

### Отправка тестового уведомления:

1. Перейдите в Firebase Console → Cloud Messaging
2. Нажмите "Send test message"
3. Вставьте FCM токен из консоли
4. Введите заголовок и текст уведомления
5. Нажмите "Test"

Уведомление должно прийти на устройство!

### Использование в коде:

```dart
import 'package:qde_eco_bahor/core/notifications/fcm_token_example.dart';

// Получить токен
final token = await FCMTokenExample.getFCMToken();

// Отправить токен на ваш сервер
if (token != null) {
  await FCMTokenExample.sendTokenToServer(token);
}
```

