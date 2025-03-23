import 'package:course_connect/models/course.dart';

class RecommendationResponse {
  final String summary;
  final String recommendation;
  final List<String> skills;
  final String learn_path;
  final List<Course> courses;

  RecommendationResponse({
    required this.summary,
    required this.recommendation,
    required this.skills,
    required this.learn_path,
    required this.courses,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    // Parse skills from string if it comes as a string
    List<String> parseSkills(dynamic skillsData) {
      if (skillsData is String) {
        // Remove brackets and split by comma
        return skillsData
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split(',')
            .map((s) => s.trim().replaceAll('"', ''))
            .where((s) => s.isNotEmpty)
            .toList();
      } else if (skillsData is List) {
        return skillsData.map((skill) => skill.toString()).toList();
      }
      return [];
    }

    return RecommendationResponse(
      summary: json['summary'] ?? '',
      recommendation: json['recommendation'] ?? '',
      skills: parseSkills(json['skills']),
      learn_path: json['learn_path'] ?? '',
      courses: (json['courses'] as List?)
          ?.map((course) => Course.fromJson(course))
          ?.toList() ?? [],
    );
  }
}