class ComparisonData {
  final CourseDetails course1;
  final CourseDetails course2;
  final String summary;
  final List<String> advantages;
  final List<String> disadvantages;

  ComparisonData({
    required this.course1,
    required this.course2,
    required this.summary,
    required this.advantages,
    required this.disadvantages,
  });

  factory ComparisonData.fromJson(Map<String, dynamic> json) {
    return ComparisonData(
      course1: CourseDetails.fromJson(json['course1']),
      course2: CourseDetails.fromJson(json['course2']),
      summary: json['summary'] ?? '',
      advantages: List<String>.from(json['advantages'] ?? []),
      disadvantages: List<String>.from(json['disadvantages'] ?? []),
    );
  }
}

class CourseDetails {
  final String name;
  final String rating;
  final String offered_by;
  final String level;
  final String duration;
  final String skills;

  CourseDetails({
    required this.name,
    required this.rating,
    required this.offered_by,
    required this.level,
    required this.duration,
    required this.skills,
  });

  factory CourseDetails.fromJson(Map<String, dynamic> json) {
    return CourseDetails(
      name: json['name']?? '',
      rating: json['rating']?.toString()?? '0.0',
      offered_by: json['offered_by']?? '',
      level: json['level']?? '',
      duration: json['duration']?? '',
      skills: json['skills']?? '',
    );
  }
}