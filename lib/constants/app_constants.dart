import 'package:flutter/material.dart';

// Константы приложения
class AppConstants {
  // Название приложения
  static const String appName = 'Our Story';
  static const String appSubtitle = 'Интерактивная визуальная новелла';

  // Версия
  static const String version = '1.0.0';

  // Размеры
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Анимация
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  // Автопроигрывание
  static const Duration autoPlayDelay = Duration(seconds: 3);

  // Имена файлов
  static const String gameProgressBox = 'game_progress';
  static const String settingsBox = 'settings';
}

// Цветовая схема
class AppColors {
  // Основные цвета (коричневая палитра для визуальной новеллы)
  static const Color primaryDark = Color(0xFF2C1810);
  static const Color primaryMedium = Color(0xFF6B4E3D);
  static const Color primaryLight = Color(0xFF8B6F47);

  // Акцентные цвета
  static const Color accent = Color(0xFFD4AF37); // Золотой
  static const Color secondary = Color(0xFF8B4513); // Седло-коричневый

  // Семантические цвета
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Прозрачности
  static const double overlayOpacity = 0.1;
  static const double disabledOpacity = 0.6;
  static const double subtitleOpacity = 0.7;
}

// Текстовые стили
class AppTextStyles {
  static const String fontFamily = 'Cinzel';

  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(fontSize: 16, height: 1.5);

  static const TextStyle bodySmall = TextStyle(fontSize: 14, height: 1.4);

  static const TextStyle caption = TextStyle(fontSize: 12, height: 1.3);
}

// Анимационные кривые
class AppCurves {
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve elasticCurve = Curves.elasticOut;
  static const Curve bounceCurve = Curves.bounceOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
}

// Размеры экранов
class ScreenSizes {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
}

// Пути к ресурсам
class AssetPaths {
  static const String images = 'assets/images/';
  static const String fonts = 'assets/fonts/';
  static const String audio = 'assets/audio/';
  static const String data = 'assets/data/';

  // Изображения по умолчанию
  static const String defaultAvatar = '${images}default_avatar.png';
  static const String defaultBackground = '${images}default_background.jpg';
  static const String appLogo = '${images}app_logo.png';
}

// Ключи для сохранения данных
class StorageKeys {
  static const String currentProgress = 'current_progress';
  static const String appSettings = 'app_settings';
  static const String playerChoices = 'player_choices';
  static const String characterRelationships = 'character_relationships';
  static const String unlockedChapters = 'unlocked_chapters';
}
