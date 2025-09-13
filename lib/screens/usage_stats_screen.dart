import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';
import '../services/google_ai_service.dart';

class UsageStatsScreen extends StatefulWidget {
  const UsageStatsScreen({super.key});

  @override
  State<UsageStatsScreen> createState() => _UsageStatsScreenState();
}

class _UsageStatsScreenState extends State<UsageStatsScreen> {
  final GoogleAiService _aiService = GoogleAiService();
  int _currentRequests = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final count = await _aiService.getCurrentRequestCount();
      setState(() {
        _currentRequests = count;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const int dailyLimit = 15; // Gemini 1.5 Flash бесплатный лимит в день
    final double percentage = _currentRequests / dailyLimit;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Заголовок с кнопкой назад
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Статистика использования ИИ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cinzel',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                else ...[
                  // Основная статистика
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.analytics,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Запросы сегодня',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                            fontFamily: 'Cinzel',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_currentRequests / $dailyLimit',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cinzel',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Прогресс бар
                        LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percentage < 0.8
                                ? Colors.green
                                : percentage < 0.9
                                ? Colors.orange
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(percentage * 100).toInt()}% использовано',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            fontFamily: 'Cinzel',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Информация о лимитах
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ℹ️ Информация о лимитах',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cinzel',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Модель:', 'Gemini 1.5 Flash'),
                        _buildInfoRow(
                          'Бесплатно в день:',
                          '$dailyLimit запросов',
                        ),
                        _buildInfoRow('Сброс лимита:', 'Каждый день в 00:00'),
                        _buildInfoRow('Статус:', _getStatusText()),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Кнопка обновления
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loadStats,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Обновить'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Подсказка
                  Text(
                    'Для просмотра полной статистики и повышения лимитов посетите Google AI Studio',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontFamily: 'Cinzel',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontFamily: 'Cinzel',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Cinzel',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    const int dailyLimit = 15;
    final double percentage = _currentRequests / dailyLimit;

    if (percentage < 0.5) {
      return '✅ Отличный запас';
    } else if (percentage < 0.8) {
      return '⚡ Умеренное использование';
    } else if (percentage < 0.95) {
      return '⚠️ Близко к лимиту';
    } else {
      return '🚫 Лимит почти исчерпан';
    }
  }
}
