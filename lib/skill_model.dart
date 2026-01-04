class Skill {
  final int? id;
  final String title;       // Что ищу
  final String offer;       // НОВОЕ: Что даю взамен
  final String description; // Описание
  final String location;    // Город
  final String ownerName;   // Имя

  Skill({
    this.id,
    required this.title,
    required this.offer,    // 🔥
    required this.description,
    required this.location,
    required this.ownerName,
  });

  // Превращаем JSON с сервера в объект Dart
  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      id: map['id'],
      title: map['title'] ?? '',
      offer: map['offer'] ?? '', // 🔥 Читаем новое поле
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      ownerName: map['owner_name'] ?? '',
    );
  }

  // Превращаем объект обратно в JSON для отправки
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'offer': offer, // 🔥 Отправляем новое поле
      'description': description,
      'location': location,
      'owner_name': ownerName,
    };
  }
}