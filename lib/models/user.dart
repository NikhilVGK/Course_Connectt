class User {
  final String id;
  final String name;
  final String email;
  final List<String> enrolledCourseIds;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.enrolledCourseIds,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      enrolledCourseIds: List<String>.from(json['enrolled_course_ids']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'enrolled_course_ids': enrolledCourseIds,
    };
  }

  // Create a sample user for demonstration
  factory User.sample() {
    return User(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      enrolledCourseIds: [],
    );
  }
}
