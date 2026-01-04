import 'dart:convert';
import 'package:http/http.dart' as http;
import 'skill_model.dart';

class ApiService {
  static const String baseUrl = "https://6d166207c200.ngrok-free.app/api/skills/";
  // 1. Получить все навыки (GET)
  Future<List<Skill>> getSkills() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "ngrok-skip-browser-warning": "true", // Пропуск экрана Ngrok
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((dynamic item) => Skill.fromMap(item)).toList();
      } else {
        throw Exception('Ошибка загрузки: ${response.statusCode}');
      }
    } catch (e) {
      print("Ошибка сети: $e");
      return [];
    }
  }

  // Создать новый навык (POST)
  Future<bool> createSkill(Skill skill) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode(skill.toMap()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Ошибка отправки: $e");
      return false;
    }
  }

  // Удалить навык (DELETE) - ЭТО НУЖНО ДЛЯ КНОПКИ УДАЛЕНИЯ
  Future<bool> deleteSkill(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl$id/"), // Добавляем ID в конец ссылки
        headers: {
          "ngrok-skip-browser-warning": "true",
        },
      );
      // 204 означает "Удалено успешно, контента нет"
      return response.statusCode == 204;
    } catch (e) {
      print("Ошибка удаления: $e");
      return false;
    }
  }
}