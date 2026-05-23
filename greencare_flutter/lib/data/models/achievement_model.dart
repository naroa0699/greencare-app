class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final bool unlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.unlocked = false,
  });

  Achievement copyWith({bool? unlocked}) => Achievement(
        id: id,
        title: title,
        description: description,
        emoji: emoji,
        unlocked: unlocked ?? this.unlocked,
      );
}

const List<Achievement> allAchievements = [
  Achievement(
    id: 'first_plant',
    title: 'Primera planta',
    description: 'Añade tu primera planta a la colección',
    emoji: '🌱',
  ),
  Achievement(
    id: 'five_plants',
    title: 'Pequeño jardín',
    description: 'Añade 5 plantas a tu colección',
    emoji: '🪴',
  ),
  Achievement(
    id: 'first_water',
    title: 'Primer riego',
    description: 'Marca una planta como regada por primera vez',
    emoji: '💧',
  ),
  Achievement(
    id: 'streak_3',
    title: 'Racha de 3 días',
    description: 'Riega plantas 3 días consecutivos',
    emoji: '🔥',
  ),
  Achievement(
    id: 'streak_7',
    title: 'Una semana perfecta',
    description: 'Riega plantas 7 días consecutivos',
    emoji: '⭐',
  ),
  Achievement(
    id: 'streak_30',
    title: 'Jardinero experto',
    description: 'Riega plantas 30 días consecutivos',
    emoji: '🏆',
  ),
  Achievement(
    id: 'forum_post',
    title: 'Miembro de la comunidad',
    description: 'Publica tu primer hilo en el foro',
    emoji: '💬',
  ),
];