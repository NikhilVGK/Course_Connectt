import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/recommendation_response.dart';

class RecommendationService {
  static const String baseUrl = "https://select-vast-squirrel.ngrok-free.app/airec";
  final Duration timeout = Duration(seconds: 30);

  Future<RecommendationResponse> getRecommendations(String query) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          "ngrok-skip-browser-warning": "true",
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'query': query,
          'include_path': true
        }),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(decodedResponse) as Map<String, dynamic>;
        return RecommendationResponse.fromJson(jsonData);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get recommendations: $e');
    }
  }
}