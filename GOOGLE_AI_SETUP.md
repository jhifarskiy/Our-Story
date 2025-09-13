# Настройка Google AI API

## Шаг 1: Получение API ключа

1. Откройте https://aistudio.google.com/
2. Войдите в свой Google аккаунт
3. Нажмите кнопку "Get API key" в верхней части страницы
4. Создайте новый проект или выберите существующий
5. Скопируйте API ключ

## Шаг 2: Настройка в приложении

1. Откройте файл `lib/services/google_ai_service.dart`
2. Найдите строку: `static const String _apiKey = 'YOUR_API_KEY_HERE';`
3. Замените `'YOUR_API_KEY_HERE'` на ваш реальный API ключ

Пример:
```dart
static const String _apiKey = 'AIzaSyBvOTaThisIsJustAnExample_RealKeyIsLonger';
```

## Шаг 3: Тестирование

1. Запустите приложение: `flutter run`
2. Перейдите в раздел "Тест Google AI"
3. Введите тестовый промпт и нажмите "Тест генерации"

## Безопасность

⚠️ **ВАЖНО**: Не публикуйте API ключ в открытом репозитории!
В продакшене используйте переменные окружения или безопасное хранилище ключей.

## Альтернативы

Можно также использовать:
- `gemini-1.5-pro` - более мощная модель
- `gemini-1.0-pro` - базовая модель

Просто измените модель в `GoogleAiService`:
```dart
_model = GenerativeModel(
  model: 'gemini-1.5-pro', // Замените на нужную модель
  apiKey: _apiKey,
);
```
