import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class AssetValidator {
  static const List<String> _requiredAssets = [
    'assets/images/alex_avatar.jpg',
    'assets/images/maria_avatar.jpg',
    'assets/fonts/Cinzel-Regular.ttf',
    'assets/fonts/Cinzel-Bold.ttf',
    'assets/fonts/Cinzel-Medium.ttf',
    'assets/fonts/Cinzel-SemiBold.ttf',
    'assets/fonts/Cinzel-ExtraBold.ttf',
    'assets/fonts/Cinzel-Black.ttf',
  ];

  /// Проверяет все необходимые ассеты при запуске приложения
  static Future<List<String>> validateAssets() async {
    final List<String> missingAssets = [];

    for (final asset in _requiredAssets) {
      try {
        await rootBundle.load(asset);
        if (kDebugMode) {
          print('✅ Asset found: $asset');
        }
      } catch (e) {
        missingAssets.add(asset);
        if (kDebugMode) {
          print('❌ Asset missing: $asset');
        }
      }
    }

    if (missingAssets.isNotEmpty) {
      if (kDebugMode) {
        print('⚠️  Missing assets detected:');
        for (final asset in missingAssets) {
          print('   - $asset');
        }
      }
    } else {
      if (kDebugMode) {
        print('✅ All required assets are available');
      }
    }

    return missingAssets;
  }

  /// Проверяет конкретный ассет
  static Future<bool> checkAsset(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Asset not found: $assetPath - Error: $e');
      }
      return false;
    }
  }
}
