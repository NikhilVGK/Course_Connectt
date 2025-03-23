import 'package:flutter/material.dart';
class CourseLevels {
  static const String beginner = 'Beginner';
  static const String intermediate = 'Intermediate';
  static const String advanced = 'Advanced';
  static const String allLevels = 'All Levels';
  
  static const List<String> values = [
    beginner,
    intermediate,
    advanced,
    allLevels,
  ];
}

class Platforms {
  static const String coursera = 'Coursera';
  static const String udemy = 'Udemy';
  static const String edX = 'edX';
  static const String linkedinLearning = 'LinkedIn Learning';
  
  static const List<String> values = [
    coursera,
    udemy,
    edX,
    linkedinLearning,
  ];
}

class CourseDurations {
  static const String lessThanMonth = 'Less than 1 month';
  static const String oneToThreeMonths = '1-3 months';
  static const String threeToSixMonths = '3-6 months';
  static const String sixToTwelveMonths = '6-12 months';
  static const String moreThanYear = 'More than 1 year';
  
  static const List<String> values = [
    lessThanMonth,
    oneToThreeMonths,
    threeToSixMonths,
    sixToTwelveMonths,
    moreThanYear,
  ];
}



class AppColors {
  static const primary = Color(0xFF0047AB);  // Matching your header blue color
  static const primaryLight = Color(0xFF4169E1);  // Royal blue for lighter shade
  
  // Prevent instantiation
  AppColors._();
}
