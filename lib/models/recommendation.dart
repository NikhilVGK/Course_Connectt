import 'package:course_connect/models/course.dart';

class Recommendation {
  final String summary;
  final String recommendation;
  final List<String> skills;
  final String learningPath;
  final List<Course> courses;

  Recommendation({
    required this.summary,
    required this.recommendation,
    required this.skills,
    required this.learningPath,
    required this.courses,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      summary: json['summary'] ?? '',
      recommendation: json['recommendation'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      learningPath: json['learn_path'] ?? json['learning_path'] ?? '',
      courses: (json['courses'] as List?)
          ?.map((c) => Course.fromJson(c))
          ?.toList() ?? [],
    );
  }
}