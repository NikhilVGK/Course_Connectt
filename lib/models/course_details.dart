import 'package:course_connect/models/course.dart';

class CourseDetails {
  final Course courseInfo;
  final Map<String, dynamic> comparisonData;

  CourseDetails({
    required this.courseInfo,
    required this.comparisonData,
  });
}