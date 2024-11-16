import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class ApiService {
  final String apiUrl = 'https://opentdb.com/api.php?amount=8&type=multiple';

  Future<List<Question>> fetchQuestions() async {
    final response = await http.get(Uri.parse(apiUrl));

    // Log the response body for debugging
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      // Decode the response body
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> questionsJson = jsonResponse['results'];

      // Map the JSON data to Question objects
      return questionsJson.map((data) {
        return Question(
          question: data['question'],
          options: List<String>.from(
              data['incorrect_answers']..add(data['correct_answer'])),
          answer: data['correct_answer'],
        );
      }).toList();
    } else {
      throw Exception('Failed to load questions');
    }
  }
}
