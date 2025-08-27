import 'package:flutter/material.dart';
import '../utils/image_utils.dart';
import '../utils/asset_validator.dart';

class AvatarTestScreen extends StatefulWidget {
  const AvatarTestScreen({super.key});

  @override
  State<AvatarTestScreen> createState() => _AvatarTestScreenState();
}

class _AvatarTestScreenState extends State<AvatarTestScreen> {
  final List<String> _avatarPaths = [
    'assets/images/alex_avatar.jpg',
    'assets/images/maria_avatar.jpg',
  ];

  Map<String, bool> _assetStatus = {};

  @override
  void initState() {
    super.initState();
    _checkAssets();
  }

  Future<void> _checkAssets() async {
    final Map<String, bool> status = {};

    for (final path in _avatarPaths) {
      status[path] = await AssetValidator.checkAsset(path);
    }

    if (mounted) {
      setState(() {
        _assetStatus = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тест аватаров'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Проверка загрузки аватаров:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Показываем статус ассетов
            if (_assetStatus.isNotEmpty) ...[
              const Text(
                'Статус файлов:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              for (final entry in _assetStatus.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(
                        entry.value ? Icons.check_circle : Icons.error,
                        color: entry.value ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            color: entry.value
                                ? Colors.green[700]
                                : Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 30),
            ],

            const Text(
              'Тестирование отображения:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // Отображаем аватары с разными размерами
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: _avatarPaths.length,
                itemBuilder: (context, index) {
                  final path = _avatarPaths[index];
                  final fileName = path.split('/').last.split('.').first;
                  final characterName = fileName
                      .replaceAll('_avatar', '')
                      .toUpperCase();

                  return Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Большой аватар
                          ImageUtils.buildSafeCircleAvatar(
                            imagePath: path,
                            radius: 40,
                          ),
                          const SizedBox(height: 12),

                          Text(
                            characterName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Маленький аватар
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Мини: '),
                              ImageUtils.buildSafeCircleAvatar(
                                imagePath: path,
                                radius: 16,
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Статус
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (_assetStatus[path] ?? false)
                                  ? Colors.green[100]
                                  : Colors.red[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              (_assetStatus[path] ?? false)
                                  ? 'Загружен'
                                  : 'Ошибка',
                              style: TextStyle(
                                fontSize: 12,
                                color: (_assetStatus[path] ?? false)
                                    ? Colors.green[700]
                                    : Colors.red[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Кнопка перепроверки
            Center(
              child: ElevatedButton.icon(
                onPressed: _checkAssets,
                icon: const Icon(Icons.refresh),
                label: const Text('Перепроверить ассеты'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
