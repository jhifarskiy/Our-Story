import 'package:flutter/material.dart';

class FontTestScreen extends StatelessWidget {
  const FontTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1810),
      appBar: AppBar(
        title: const Text(
          'Тест шрифтов Cinzel',
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6B4E3D),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // Тест различных весов шрифта
            _buildFontExample(
              'Cinzel Regular (400)',
              FontWeight.w400,
              fontSize: 24,
            ),

            const SizedBox(height: 16),

            _buildFontExample(
              'Cinzel Medium (500)',
              FontWeight.w500,
              fontSize: 24,
            ),

            const SizedBox(height: 16),

            _buildFontExample(
              'Cinzel SemiBold (600)',
              FontWeight.w600,
              fontSize: 24,
            ),

            const SizedBox(height: 16),

            _buildFontExample(
              'Cinzel Bold (700)',
              FontWeight.w700,
              fontSize: 24,
            ),

            const SizedBox(height: 16),

            _buildFontExample(
              'Cinzel ExtraBold (800)',
              FontWeight.w800,
              fontSize: 24,
            ),

            const SizedBox(height: 16),

            _buildFontExample(
              'Cinzel Black (900)',
              FontWeight.w900,
              fontSize: 24,
            ),

            const SizedBox(height: 32),

            // Примеры текста в разных размерах
            _buildFontExample(
              'Our Story - Заголовок',
              FontWeight.bold,
              fontSize: 32,
            ),

            const SizedBox(height: 16),

            _buildFontExample(
              'Интерактивная визуальная новелла',
              FontWeight.w600,
              fontSize: 18,
            ),

            const SizedBox(height: 16),

            _buildFontExample(
              'Добро пожаловать в мир историй, где каждый выбор имеет значение.',
              FontWeight.w400,
              fontSize: 16,
            ),

            const Spacer(),

            // Кнопка для проверки
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B4E3D), Color(0xFF8B6F47)],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Шрифт Cinzel успешно загружен!',
                          style: TextStyle(fontFamily: 'Cinzel'),
                        ),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Проверить загрузку шрифта',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontExample(
    String text,
    FontWeight weight, {
    double fontSize = 16,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Cinzel',
          fontSize: fontSize,
          fontWeight: weight,
          color: Colors.white,
          height: 1.3,
        ),
      ),
    );
  }
}
