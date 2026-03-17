# TaxyCity 🚕

Мобильное приложение для заказа такси с поддержкой водителей и пассажиров.

## Функции

### Для пассажиров
- 🚗 Заказ такси поездок
- 📍 Выбор точки на карте
- ⭐ Рейтинг водителей
- 📜 История поездок
- 🌙 Тёмная тема
- 📱 Push-уведомления

### Для водителей
- 📍 Принятие заказов
- 🗺️ Навигация по карте
- 💰 Отслеживание доходов
- ⭐ Рейтинг и отзывы
- 📱 Push-уведомления о новых заказах

## Технологии

- **Flutter** - кроссплатформенный фреймворк
- **Firebase** - бэкенд (Auth, Firestore, Messaging)
- **Google Maps** - карты и геолокация

## Установка

```bash
# Клонирование репозитория
git clone https://github.com/invokerwow33/taxycity.git
cd taxycity

# Установка зависимостей
flutter pub get

# Запуск
flutter run
```

## Настройка Firebase

1. Создайте проект на [Firebase Console](https://console.firebase.google.com)
2. Включите аутентификацию (Email/Phone)
3. Создайте Firestore базу данных
4. Скачайте `google-services.json` и поместите в `android/app/`

## Настройка Google Maps

1. Получите API ключ в [Google Cloud Console](https://console.cloud.google.com)
2. Включите Maps SDK for Android
3. Добавьте ключ в `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY"/>
```

## Структура проекта

```
lib/
├── main.dart                    # Точка входа
├── services/
│   ├── firebase_service.dart    # Firebase интеграция
│   ├── map_service.dart        # Google Maps
│   ├── location_service.dart   # Геолокация
│   ├── notification_service.dart
│   ├── storage_service.dart    # Локальное хранилище
│   └── theme_service.dart      # Темы
└── screens/
    ├── welcome_screen.dart
    ├── login_screen.dart
    ├── driver_registration_screen.dart
    ├── client_registration_screen.dart
    ├── phone_verification_screen.dart
    ├── driver_home_screen.dart
    ├── client_home_screen.dart
    ├── client_order_screen.dart
    ├── chat_screen.dart
    ├── trip_history_screen.dart
    ├── client_settings_screen.dart
    └── driver_settings_screen.dart
```

## Версия

- **1.0.0+4** - Добавлена интеграция Firebase и Google Maps

## Лицензия

MIT License
