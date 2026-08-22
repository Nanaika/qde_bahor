# Flutter Template Project

Шаблон Flutter проекта с Clean Architecture, Feature-first организацией и flutter_bloc для управления состоянием.

## Архитектура

Проект следует принципам Clean Architecture с организацией по фичам (Feature-first):

```
lib/
├── core/                          # Общий код
│   ├── error/                     # Обработка ошибок, failures
│   ├── network/                   # Утилиты сети, interceptors
│   ├── utils/                     # Утилиты и расширения
│   └── widgets/                   # Переиспользуемые виджеты
├── features/                      # Все фичи приложения
│   ├── example_feature/           # Пример фичи
│   │   ├── data/                  # Слой данных
│   │   │   ├── datasources/       # Удаленные и локальные источники данных
│   │   │   ├── models/            # DTOs и модели данных
│   │   │   └── repositories/      # Реализации репозиториев
│   │   ├── domain/                # Слой домена
│   │   │   ├── entities/          # Бизнес-объекты
│   │   │   ├── repositories/      # Интерфейсы репозиториев
│   │   │   └── usecases/          # Use cases бизнес-логики
│   │   └── presentation/          # Слой представления
│   │       ├── bloc/              # Bloc/Cubit для управления состоянием
│   │       ├── pages/             # Экраны
│   │       └── widgets/           # Виджеты фичи
└── main.dart                      # Точка входа
```

## Используемые библиотеки

- **flutter_bloc** - Управление состоянием
- **go_router** - Навигация
- **easy_localization** - Локализация
- **pull_to_refresh** - Pull-to-refresh
- **flutter_local_notifications** / **firebase_messaging** - Уведомления
- **get_it** - Dependency Injection
- **dartz** - Функциональная обработка ошибок
- **dio** - HTTP клиент
- **freezed** - Неизменяемые классы и union types

## Начало работы

1. Установите зависимости:
```bash
flutter pub get
```

2. Сгенерируйте код (для freezed и других code generators):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Настройте Firebase (опционально, если используете уведомления):
   - Добавьте `google-services.json` для Android в `android/app/`
   - Добавьте `GoogleService-Info.plist` для iOS в `ios/Runner/`

4. Запустите приложение:
```bash
flutter run
```

## Важные замечания

- После установки зависимостей (`flutter pub get`) необходимо запустить `build_runner` для генерации freezed файлов
- Для работы уведомлений требуется настройка Firebase (опционально)
- Локализация настроена для английского и русского языков, файлы находятся в `assets/translations/`

## Структура

### Core

Общий код, используемый во всем приложении:
- **error/** - Классы ошибок и failures
- **network/** - Настройка сети, interceptors
- **utils/** - Утилиты и расширения
- **widgets/** - Переиспользуемые виджеты

### Features

Каждая фича содержит три слоя:
- **data/** - Реализация источников данных и репозиториев
- **domain/** - Бизнес-логика, entities, use cases
- **presentation/** - UI, bloc, страницы

## Примеры использования

### Навигация (go_router)

См. `lib/core/router/app_router.dart`

### Локализация (easy_localization)

Файлы переводов находятся в `assets/translations/`

### Pull-to-refresh (pull_to_refresh)

См. пример в `features/example_feature/presentation/pages/example_page.dart`

### Уведомления

См. `core/notifications/notification_service.dart`

### BLoC

См. пример в `features/example_feature/presentation/bloc/example_bloc.dart`

