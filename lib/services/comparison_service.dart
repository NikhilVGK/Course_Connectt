import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:course_connect/models/course.dart';

class ComparisonService {
  static const String _baseUrl = 'https://select-vast-squirrel.ngrok-free.app';

  Future<Map<String, dynamic>> compareCourses(Course course1, Course course2) async {
    try {
      // Validate course objects
      if (course1 == null || course2 == null) {
        throw Exception('Both courses must be selected for comparison');
      }

      print('Sending comparison request for:');
      print('Course 1 link: ${course1.productLink}');
      print('Course 2 link: ${course2.productLink}');
      print('Request URL: $_baseUrl/compare');

      // Ensure the links are not null or empty
      if (course1.productLink == null || course2.productLink == null ||
          course1.productLink.isEmpty || course2.productLink.isEmpty) {
        throw Exception('Course links cannot be null or empty');
      }

      // Validate URLs
      if (!Uri.parse(course1.productLink).isAbsolute || !Uri.parse(course2.productLink).isAbsolute) {
        throw Exception('Invalid course URLs');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/compare'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Accept': 'application/json',
        },
        body: jsonEncode( [
            {'product_link': course1.productLink},
            {'product_link': course2.productLink}
          ]
        ),
      );

      print('Response headers: ${response.headers}');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          return jsonResponse;
        } catch (e) {
          print('JSON parsing error: $e');
          throw Exception('Invalid response format from server');
        }
      } else {
        throw Exception('Failed to compare courses: ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      print('Comparison error: $e');
      throw Exception('Error comparing courses: $e');
    }
  }
}