# Инструкция по настройке проекта

## Шаги установки

1. **Установите зависимости Flutter:**
   ```bash
   flutter pub get
   ```

2. **Сгенерируйте код (freezed, json_serializable и т.д.):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Настройте Firebase (опционально, для уведомлений):**
   
   Для Android:
   - Скачайте `google-services.json` из Firebase Console
   - Поместите в `android/app/google-services.json`
   - Убедитесь, что в `android/build.gradle` добавлен классpath для Google Services
   
   Для iOS:
   - Скачайте `GoogleService-Info.plist` из Firebase Console
   - Добавьте в Xcode проект в папку `Runner`

4. **Запустите приложение:**
   ```bash
   flutter run
   ```

## Структура проекта

Проект следует Clean Architecture с Feature-first организацией:

- **core/** - Общий код (error handling, network, utils, widgets)
- **features/** - Фичи приложения, каждая с тремя слоями:
  - **data/** - Источники данных, модели, реализации репозиториев
  - **domain/** - Entities, интерфейсы репозиториев, use cases
  - **presentation/** - UI, BLoC, страницы, виджеты

## Используемые библиотеки

- **flutter_bloc** - Управление состоянием
- **go_router** - Навигация
- **easy_localization** - Локализация (файлы в `assets/translations/`)
- **pull_to_refresh** - Pull-to-refresh функциональность
- **flutter_local_notifications** / **firebase_messaging** - Уведомления
- **get_it** - Dependency Injection
- **dartz** - Функциональная обработка ошибок (Either<Failure, Success>)
- **dio** - HTTP клиент
- **freezed** - Неизменяемые классы и union types

## Примеры использования

### Навигация

Используйте `go_router` для навигации:
```dart
context.go('/example');
context.push('/example');
```

### Локализация

Используйте `easy_localization`:
```dart
Text('home.title'.tr())
```

### Pull-to-refresh

См. пример в `features/example_feature/presentation/pages/example_page.dart`

### BLoC

См. пример в `features/example_feature/presentation/bloc/example_bloc.dart`

### Уведомления

См. `core/notifications/notification_service.dart`


