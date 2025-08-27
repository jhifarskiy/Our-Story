import 'package:flutter/material.dart';
import '../models/character.dart';
import '../utils/image_utils.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback? onTap;
  final String? emotion;

  const CharacterCard({
    super.key,
    required this.character,
    this.onTap,
    this.emotion,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Аватар персонажа
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child:
                        emotion != null &&
                            character.emotions.containsKey(emotion)
                        ? ImageUtils.buildSafeImage(
                            imagePath: character.emotions[emotion]!,
                            fit: BoxFit.cover,
                            placeholder: _buildDefaultAvatar(context),
                          )
                        : ImageUtils.buildSafeImage(
                            imagePath: character.avatarPath,
                            fit: BoxFit.cover,
                            placeholder: _buildDefaultAvatar(context),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Имя персонажа
              Text(
                character.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cinzel',
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Описание персонажа
              Text(
                character.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Индикатор эмоции
              if (emotion != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Text(
                      _getEmotionName(emotion!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return Icon(
      Icons.person,
      size: 40,
      color: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }

  String _getEmotionName(String emotion) {
    switch (emotion) {
      case 'happy':
        return 'Счастлив';
      case 'sad':
        return 'Грустит';
      case 'surprised':
        return 'Удивлен';
      case 'love':
        return 'Влюблен';
      case 'angry':
        return 'Злится';
      default:
        return emotion;
    }
  }
}
