import 'package:flutter/foundation.dart';
import '../models/course.dart';

class CourseProvider with ChangeNotifier {
  static const int TRENDING_LIMIT = 10;
  static const int RECOMMENDED_LIMIT = 15;
  static const int POPULAR_LIMIT = 6;

  List<Course> _trendingCourses = [];
  List<Course> _recommendedCourses = [];
  List<Course> _popularCourses = [];

  List<Course> get trendingCourses => _trendingCourses;
  List<Course> get recommendedCourses => _recommendedCourses;
  List<Course> get popularCourses => _popularCourses;


  void categorizeCourses(List<Course> allCourses) {
    _trendingCourses.clear();
    _recommendedCourses.clear();
    _popularCourses.clear();

    Set<String> usedCourseTitles = {};

    // Populate trending courses
    for (var course in allCourses) {
      if (_trendingCourses.length >= TRENDING_LIMIT) break;
      if (course.isTrending && !usedCourseTitles.contains(course.title)) {
        _trendingCourses.add(course);
        usedCourseTitles.add(course.title);
      }
    }

    // Populate recommended courses
    for (var course in allCourses) {
      if (_recommendedCourses.length >= RECOMMENDED_LIMIT) break;
      if (!usedCourseTitles.contains(course.title)) {
        _recommendedCourses.add(course);
        usedCourseTitles.add(course.title);
      }
    }

    // Populate popular courses
    for (var course in allCourses) {
      if (_popularCourses.length >= POPULAR_LIMIT) break;
      if (course.isPopular && !usedCourseTitles.contains(course.title)) {
        _popularCourses.add(course);
        usedCourseTitles.add(course.title);
      }
    }

    notifyListeners();
  }
}