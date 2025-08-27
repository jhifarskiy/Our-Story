import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageUtils {
  /// Проверяет, существует ли изображение в ассетах
  static Future<bool> assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Возвращает виджет с безопасной загрузкой изображения
  static Widget buildSafeImage({
    required String imagePath,
    Widget? placeholder,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
  }) {
    return Image.asset(
      imagePath,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return placeholder ?? _buildDefaultPlaceholder(context);
      },
    );
  }

  /// Возвращает виджет круглого аватара с безопасной загрузкой
  static Widget buildSafeCircleAvatar({
    required String imagePath,
    double radius = 20,
    Widget? placeholder,
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      child: ClipOval(
        child: Image.asset(
          imagePath,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return placeholder ?? _buildDefaultAvatarIcon(radius);
          },
        ),
      ),
    );
  }

  /// Создает placeholder по умолчанию для изображений
  static Widget _buildDefaultPlaceholder(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
      ),
    );
  }

  /// Создает иконку по умолчанию для аватаров
  static Widget _buildDefaultAvatarIcon(double radius) {
    return Icon(Icons.person, size: radius, color: Colors.grey[600]);
  }
}
