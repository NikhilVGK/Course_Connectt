import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:course_connect/models/course.dart';

class CourseService {
  final String baseUrl = 'https://select-vast-squirrel.ngrok-free.app/scrape';
  List<Course> _mockCourses = [];
  List<Course> _lastSearchResults = [];
    bool _initialized = false;
    bool _hasSearched = false;

  // Add getAllCourses and applyFilters methods to the existing class
  Future<List<Course>> getAllCourses() async {
    await _initializeMockData();
    return _mockCourses;
  }

  Future<List<Course>> applyFilters({
    required List<Course> courses,
    double? minRating,
    int? minReviews,
    String? platform,
    String? titleQuery,
  }) async {
    return courses.where((course) {
      if (minRating != null && course.rating < minRating) return false;
      if (minReviews != null && course.reviews < minReviews) return false;
      if (platform != null && course.organization != platform) return false;
      if (titleQuery != null && titleQuery.isNotEmpty) {
        return course.title.toLowerCase().contains(titleQuery.toLowerCase());
      }
      return true;
    }).toList();
  }

  Future<void> _initializeMockData() async {
    if (_initialized) return;
    try {
      _mockCourses = await fetchCourses();
      _initialized = true;
    } catch (e) {
      print("Failed to fetch initial courses: $e");
      // Use fetchCourses directly instead of _getHardcodedCourses
      _mockCourses = await fetchCourses();
      _initialized = true;
    }
  }

  // Remove _getHardcodedCourses method as it's no longer needed
  Future<List<Course>> fetchCourses() async {
    try {
      await Future.delayed(Duration(seconds: 1));
      final List<Map<String, dynamic>> sampleCourses = [
        {
          "title": "Core Java",
          "image_link": "...", // These snake_case keys are correct as they match Course.fromJson
          "product_link": "...",
          "organization": "LearnQuest",
          "rating": 4.6,
          "reviews": 26
        },
        {
          "title": "Python for Everybody",
          "image_link": "https://d3njjcbhbojbot.cloudfront.net/api/utilities/v1/imageproxy/https://s3.amazonaws.com/coursera-course-photos/08/33f720502a11e59e72391aa537f5c9/pythonlearn_thumbnail_1x1.png?auto=format%2Ccompress%2C%20enhance&dpr=1&w=265&h=216&fit=crop&q=50",
          "product_link": "https://www.coursera.org/specializations/python",
          "organization": "University of Michigan",
          "rating": 4.8,
          "reviews": 208
        },
        {
          "title": "Machine Learning",
          "image_link": "https://d3njjcbhbojbot.cloudfront.net/api/utilities/v1/imageproxy/https://s3.amazonaws.com/coursera-course-photos/b5/a3d0901ca511e5afbb81ba119d84db/ml-logo1.png?auto=format%2Ccompress%2C%20enhance&dpr=1&w=265&h=216&fit=crop&q=50",
          "product_link": "https://www.coursera.org/learn/machine-learning",
          "organization": "Stanford University",
          "rating": 4.9,
          "reviews": 156
        },
        {
          "title": "Web Development with JavaScript",
          "image_link": "https://d3njjcbhbojbot.cloudfront.net/api/utilities/v1/imageproxy/https://s3.amazonaws.com/coursera-course-photos/12/de8718c09c4a508eaafbfgen06dc73/CDMJS-logos-06-React.png?auto=format%2Ccompress%2C%20enhance&dpr=1&w=265&h=216&fit=crop&q=50",
          "product_link": "https://www.coursera.org/learn/javascript-and-react-for-web-development",
          "organization": "Meta",
          "rating": 4.5,
          "reviews": 87
        },
        {
          "title": "Data Science",
          "image_link": "https://d3njjcbhbojbot.cloudfront.net/api/utilities/v1/imageproxy/https://s3.amazonaws.com/coursera-course-photos/fa/01ec4062dd11e497a59db31b34f699/JHU-headers9.png?auto=format%2Ccompress%2C%20enhance&dpr=1&w=265&h=216&fit=crop&q=50",
          "product_link": "https://www.coursera.org/specializations/jhu-data-science",
          "organization": "Johns Hopkins University",
          "rating": 4.6,
          "reviews": 132
        }
      ];
      return sampleCourses.map((json) => Course.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load courses: $e');
    }
  }

  void resetSearch() {
      _hasSearched = false;
      _lastSearchResults = [];
    }
  
    Future<List<Course>> searchCourses(String query) async {
      if (query.trim().isEmpty) {
        resetSearch();
        return [];
      }
      
      // Check if it's a platform-specific search
      if (query.toLowerCase().startsWith('platform:')) {
        String platform = query.substring(9).trim();
        List<Course> results = await _fallbackToMockData('');
        return results.where((course) => 
          _getPlatformFromUrl(course.productLink).toLowerCase() == platform.toLowerCase()
        ).toList();
      }
  
      try {
        final Uri url = Uri.parse("$baseUrl?query=$query");
        print("Fetching from: $url");
  
        final response = await http.get(
          url,
          headers: {
            "Accept": "application/json",
            "ngrok-skip-browser-warning": "true",
            "User-Agent": "FlutterApp/1.0",
          },
        );
  
        if (response.statusCode == 200) {
          final String decodedBody = utf8.decode(response.bodyBytes);
          final List<dynamic> data = json.decode(decodedBody);
          final results = data.map((json) => Course.fromJson(json)).toList();
          
          if (results.isNotEmpty) {
            _lastSearchResults = results;
            _hasSearched = true;
          }
          return results;
        } else {
          throw Exception("Failed to fetch courses. Status code: ${response.statusCode}");
        }
      } catch (e) {
        print("Search failed: $e");
        return _fallbackToMockData(query);
      }
    }

    Future<List<Course>> _fallbackToMockData(String query) async {
      await _initializeMockData();
      return _mockCourses.where((course) =>
        course.title.toLowerCase().contains(query.toLowerCase()) ||
        _getPlatformFromUrl(course.productLink).toLowerCase().contains(query.toLowerCase())
      ).toList();
    }

  Future<List<Course>> getTrendingCourses() async {
    if (!_hasSearched) {
      await _initializeMockData();
      List<Course> courses = List.from(_mockCourses);
      courses.shuffle();
      return courses.take(5).toList();
    }
    
    List<Course> courses = List.from(_lastSearchResults);
    courses.shuffle();
    return courses.take(10).toList();
  }

  Future<List<Course>> getRecommendedCourses() async {
    if (!_hasSearched) {
      await _initializeMockData();
      List<Course> courses = List.from(_mockCourses);
      courses.shuffle();
      return courses.take(5).toList();
    }
    
    List<Course> courses = List.from(_lastSearchResults);
    courses.shuffle();
    return courses.take(15).toList();
  }

  Future<List<Course>> getPopularCourses() async {
    if (!_hasSearched) {
      await _initializeMockData();
      List<Course> courses = List.from(_mockCourses);
      courses.sort((a, b) => (b.rating * log(b.reviews)).compareTo(a.rating * log(a.reviews)));
      return courses.take(5).toList();
    }
    
    List<Course> courses = List.from(_lastSearchResults);
    courses.sort((a, b) => (b.rating * log(b.reviews)).compareTo(a.rating * log(a.reviews)));
    return courses.take(5).toList();
  }

  String _getPlatformFromUrl(String productLink) {
    Uri uri = Uri.parse(productLink);
    String host = uri.host;
    
    if (host.contains('coursera.org')) return 'Coursera';
    if (host.contains('edx.org')) return 'edX';
    if (host.contains('udemy.com')) return 'Udemy';
    if (host.contains('linkedin.com')) return 'LinkedIn Learning';
    
    return 'Other';
  }
}