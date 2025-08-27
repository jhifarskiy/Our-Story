import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FontUtils {
  // Проверка доступности шрифта Cinzel
  static Future<bool> isCinzelFontLoaded() async {
    try {
      // Попытка загрузить шрифт
      await rootBundle.load('assets/fonts/Cinzel-Regular.ttf');
      return true;
    } catch (e) {
      print('❌ Ошибка загрузки шрифта Cinzel: $e');
      return false;
    }
  }

  // Получение информации о доступных весах шрифта
  static List<FontWeight> getAvailableFontWeights() {
    return [
      FontWeight.w400, // Regular
      FontWeight.w500, // Medium
      FontWeight.w600, // SemiBold
      FontWeight.w700, // Bold
      FontWeight.w800, // ExtraBold
      FontWeight.w900, // Black
    ];
  }

  // Создание TextStyle с шрифтом Cinzel
  static TextStyle createCinzelStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    Color color = Colors.black,
    double height = 1.0,
  }) {
    return TextStyle(
      fontFamily: 'Cinzel',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  // Тестирование рендеринга текста с шрифтом Cinzel
  static Widget createFontTestWidget(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Тест шрифта Cinzel:',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: createCinzelStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Если текст выше отображается красивым декоративным шрифтом,',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        Text(
          'то шрифт Cinzel загружен успешно!',
          style: TextStyle(
            fontSize: 12,
            color: Colors.green[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Логирование информации о шрифтах в консоль
  static Future<void> logFontStatus() async {
    print('🔤 === ПРОВЕРКА ШРИФТОВ ===');
    print('🔤 Приложение: Our Story');
    print('🔤 Шрифт: Cinzel');

    final isLoaded = await isCinzelFontLoaded();
    if (isLoaded) {
      print('✅ Шрифт Cinzel загружен успешно');
      print(
        '✅ Доступные веса: ${getAvailableFontWeights().map((w) => w.value).join(', ')}',
      );
    } else {
      print('❌ Ошибка загрузки шрифта Cinzel');
      print('❌ Проверьте наличие файлов в assets/fonts/');
    }
    print('🔤 ========================');
  }

  // Получение списка всех файлов шрифтов Cinzel
  static List<String> getCinzelFontFiles() {
    return [
      'assets/fonts/Cinzel-Regular.ttf',
      'assets/fonts/Cinzel-Medium.ttf',
      'assets/fonts/Cinzel-SemiBold.ttf',
      'assets/fonts/Cinzel-Bold.ttf',
      'assets/fonts/Cinzel-ExtraBold.ttf',
      'assets/fonts/Cinzel-Black.ttf',
    ];
  }

  // Проверка всех файлов шрифтов
  static Future<Map<String, bool>> checkAllFontFiles() async {
    final results = <String, bool>{};

    for (final fontFile in getCinzelFontFiles()) {
      try {
        await rootBundle.load(fontFile);
        results[fontFile] = true;
        print('✅ $fontFile - OK');
      } catch (e) {
        results[fontFile] = false;
        print('❌ $fontFile - НЕ НАЙДЕН');
      }
    }

    return results;
  }
}
