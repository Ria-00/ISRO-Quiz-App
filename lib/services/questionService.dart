import 'dart:convert';
import 'package:flutter/services.dart';

class QuestionService {
  Map<String, dynamic>? _allQuestions;

  // Load JSON file
  Future<void> loadQuestions() async {
    final String response = await rootBundle.loadString('assets/files/question.json');
    _allQuestions = json.decode(response);
  }

  // Get questions by category and level
  List<Map<String, dynamic>> getQuestions(String category, String level) {
    if (_allQuestions == null) {
      throw Exception("Questions not loaded. Call loadQuestions() first.");
    }

    final categoryData = _allQuestions![category];
    if (categoryData == null) {
      throw Exception("Category '$category' not found.");
    }

    final levelData = categoryData[level];
    if (levelData == null) {
      throw Exception("Level '$level' not found in category '$category'.");
    }

    return List<Map<String, dynamic>>.from(levelData);
  }
}
