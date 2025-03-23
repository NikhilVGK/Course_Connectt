import 'package:flutter/material.dart';
import 'package:course_connect/models/course.dart';
import 'package:course_connect/services/course_service.dart';
import 'package:course_connect/widgets/course_card.dart';
import 'package:course_connect/widgets/searchbar.dart';
import 'package:provider/provider.dart';

import 'package:course_connect/screens/compare_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  SearchScreen({this.initialQuery});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final CourseService _courseService = CourseService();
  List<Course> _searchResults = [];
  List<Course> _selectedCoursesForComparison = [];  // Add this line
  bool _isLoading = false;
  bool _isComparing = false;  // Add this line
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _handleSearch(widget.initialQuery!);
    }
  }

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    try {
      final results = await _courseService.searchCourses(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: ${e.toString()}')),
      );
    }
  }

  void _toggleComparisonMode() {
    setState(() {
      _isComparing = !_isComparing;
      if (!_isComparing) {
        _selectedCoursesForComparison.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Courses'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_isComparing ? Icons.compare_arrows : Icons.compare),
            onPressed: _toggleComparisonMode,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              onSearch: _handleSearch,
              initialQuery: widget.initialQuery,
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                            SizedBox(height: 16),
                            Text(
                              'No courses found matching your search.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final course = _searchResults[index];
                          return CourseCard(
                            course: course,
                            isSelectable: _isComparing,
                            isSelected: _selectedCoursesForComparison.contains(course),
                            onSelect: (course) {
                              if (_isComparing) {
                                setState(() {
                                  if (_selectedCoursesForComparison.contains(course)) {
                                    _selectedCoursesForComparison.remove(course);
                                  } else if (_selectedCoursesForComparison.length < 2) {
                                    _selectedCoursesForComparison.add(course);
                                  }
                                });
                              }
                            },
                    
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _selectedCoursesForComparison.length == 2
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompareScreen(
                      courses: _selectedCoursesForComparison.toList(),
                    ),
                  ),
                );
              },
              label: Text('Compare Courses'),
              icon: Icon(Icons.compare_arrows),
              backgroundColor: Color(0xFF0047AB),
            )
          : null,
    );
  }
}