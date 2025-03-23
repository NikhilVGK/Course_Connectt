import 'package:flutter/material.dart';
import 'package:course_connect/models/course.dart';
import 'package:course_connect/screens/filter_screen.dart';
import 'package:course_connect/services/course_service.dart';
import 'package:course_connect/services/comparison_service.dart';
import 'package:course_connect/widgets/course_card.dart';
import 'package:course_connect/widgets/searchbar.dart';
import 'package:course_connect/widgets/platform_selector.dart';
import '../models/comparison_data.dart';
import '../screens/recommendations_screen.dart';
import '../widgets/comparison_overlay.dart';
// Remove this import
// import 'package:provider/provider.dart';
// import '../providers/wishlist_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CourseService _courseService = CourseService();
  final ComparisonService _comparisonService = ComparisonService();

  List<Course> _trendingCourses = [];
  List<Course> _recommendedCourses = [];
  List<Course> _popularCourses = [];
  List<Course> _searchResults = [];
  List<Course> _allCourses = []; // Combined list for comparison

  bool _isSearching = false;
  bool _isLoading = true;
  bool _isComparing = false;
  bool _isProcessingComparison = false;
  bool _showComparisonOverlay = false;

  String _searchQuery = '';
  // Replace Map<String, dynamic>? with ComparisonData?
  ComparisonData? _comparisonData;
  List<Course> _selectedCoursesForComparison = [];

  @override
  void initState() {
    super.initState();
    _loadInitialCourses();
  }

  Future<void> _loadInitialCourses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final trending = await _courseService.getTrendingCourses();
      final recommended = await _courseService.getRecommendedCourses();
      final popular = await _courseService.getPopularCourses();

      setState(() {
        _trendingCourses = trending;
        _recommendedCourses = recommended;
        _popularCourses = popular;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load courses: ${e.toString()}')),
      );
    }
  }

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      await _loadInitialCourses(); // Reload initial courses when search is cleared
      return;
    }

    setState(() {
      _searchQuery = query;
      _isSearching = true;
      _isLoading = true;
      // Clear other sections while searching
      _trendingCourses = [];
      _recommendedCourses = [];
      _popularCourses = [];
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

  void _openFilterScreen() async {
    final appliedFilters = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(
          initialQuery: _searchQuery,
          initialResults: _isSearching ? _searchResults : [],
        ),
      ),
    );

    if (appliedFilters != null && appliedFilters is List<Course>) {
      setState(() {
        _searchResults = appliedFilters;
      });
    }
  }

  void _toggleComparisonMode() {
    setState(() {
      _isComparing = !_isComparing;
      _selectedCoursesForComparison.clear();
      
      // If we're canceling comparison, also reset other states
      if (!_isComparing) {
        _showComparisonOverlay = false;
        _comparisonData = null;
      }
    });

    if (_isComparing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Select exactly 2 courses to compare'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _toggleCourseSelection(Course course) {
    setState(() {
      if (_selectedCoursesForComparison.contains(course)) {
        _selectedCoursesForComparison.remove(course);
      } else if (_selectedCoursesForComparison.length < 2) {
        _selectedCoursesForComparison.add(course);
        
        // If we've selected 2 courses, trigger the comparison
        if (_selectedCoursesForComparison.length == 2) {
          _compareCourses();
        }
      }
    });
  }

  // Add this method to handle comparison
  // Update the comparison method to use ComparisonData
  Future<void> _compareCourses() async {
    if (_selectedCoursesForComparison.length != 2) return;

    setState(() => _isProcessingComparison = true);

    try {
      final response = await _comparisonService.compareCourses(
        _selectedCoursesForComparison[0],
        _selectedCoursesForComparison[1],
      );

      setState(() {
        _comparisonData = ComparisonData.fromJson(response);
        _showComparisonOverlay = true;
        _isProcessingComparison = false;
        _isComparing = false;
        _selectedCoursesForComparison.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error comparing courses: $e')),
      );
      setState(() => _isProcessingComparison = false);
    }
  }

  void _closeComparisonOverlay() {
    setState(() {
      _showComparisonOverlay = false;
      _comparisonData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF0047AB),
            toolbarHeight: 80, // Increased AppBar height
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 40, // Increased icon size
                ),
                SizedBox(width: 16), // Increased spacing
                Expanded(
                  child: Text(
                    'Course Connect',
                    style: TextStyle(
                      fontSize: 35, // Increased font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              if (_isSearching && !_isComparing)
                IconButton(
                  icon: Icon(Icons.tune, size: 28), // Increased action icon size
                  onPressed: _openFilterScreen,
                ),
              IconButton(
                icon: Icon(
                  Icons.smart_toy_outlined, // Changed from chat_bubble_outline to smart_toy_outlined
                  size: 28,
                  color: Colors.white,
                ),
                onPressed: () {
                  // Event handler will be added later
                },
                tooltip: 'AI Assistant', // Updated tooltip text
              ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.0,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: 0,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFF0047AB),
              unselectedItemColor: Colors.grey,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                // Remove Wishlist item
                BottomNavigationBarItem(
                  icon: Icon(Icons.recommend),
                  label: 'Recommendations',
                ),
              ],
              onTap: (index) {
                switch (index) {
                  case 0:
                    Navigator.pushReplacementNamed(context, '/');
                    break;
                  case 1:
                    Navigator.pushReplacementNamed(context, '/dashboard');
                    break;
                  case 2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecommendationsScreen(),
                      ),
                    );
                    break;
                }
              },
            ),
          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    // Main content
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 80), // Add padding for the compare button
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 30),
                            // Search bar and platform selector
                            Center(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: CustomSearchBar(onSearch: _handleSearch),
                                    ),
                                    if (_isSearching)
                                      IconButton(
                                        icon: Icon(Icons.close),
                                        onPressed: () async {
                                          setState(() {
                                            _isSearching = false;
                                            _searchQuery = '';
                                            _searchResults = [];
                                          });
                                          await _loadInitialCourses();
                                        },
                                        tooltip: 'Clear search',
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            // Only show platform selector when not searching
                            if (!_isSearching) ...[
                              SizedBox(height: 20),
                              Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.6,
                                  child: PlatformSelector(
                                    onPlatformSelected: (platform) {
                                      _handleSearch('platform:$platform');
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 60),
                              if (_trendingCourses.isNotEmpty) ...[
                                Text('Trending Courses', style: Theme.of(context).textTheme.displaySmall),
                                SizedBox(height: 10),
                                _buildCourseList(_trendingCourses),
                              ],
                              if (_recommendedCourses.isNotEmpty) ...[
                                SizedBox(height: 20),
                                Text('Recommended For You', style: Theme.of(context).textTheme.displaySmall),
                                SizedBox(height: 10),
                                _buildCourseList(_recommendedCourses),
                              ],
                              if (_popularCourses.isNotEmpty) ...[
                                SizedBox(height: 20),
                                Text('Popular Courses', style: Theme.of(context).textTheme.displaySmall),
                                SizedBox(height: 10),
                                _buildCourseList(_popularCourses),
                              ],
                            ],

                            // Show search results when searching
                            if (_isSearching) ...[
                              SizedBox(height: 20),
                              Text('Search Results for "$_searchQuery"',
                                style: Theme.of(context).textTheme.displaySmall),
                              const SizedBox(height: 10),
                              if (_searchResults.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: // In the GridView.builder where courses are displayed
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 5,
                                      childAspectRatio: 0.75,
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
                                        onSelect: (course) => _toggleCourseSelection(course),
                                        // onWishlistChanged: (_) {
                                        //   if (!_isComparing) {
                                        //     final wishlistProvider = context.read<WishlistProvider>();
                                        //     if (wishlistProvider.isInWishlist(course)) {
                                        //       wishlistProvider.removeFromWishlist(course);
                                        //     } else {
                                        //       wishlistProvider.addToWishlist(course);
                                        //     }
                                        //   }
                                        // },
                                      );
                                    },
                                  ),
                                ),
                            ]
                              else
                                Center(child: Text('No courses found.')),
                            ],
                        ),
                      ),
                    ),

                    // Show Compare Button only during search
                    if (_isSearching)
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: FloatingActionButton.extended(
                            onPressed: _toggleComparisonMode,
                            icon: AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              child: _isComparing
                                  ? Icon(Icons.close, key: ValueKey('close'))
                                  : Icon(Icons.compare_arrows, key: ValueKey('compare')),
                            ),
                            label: AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              child: Text(
                                _isComparing ? 'Cancel Comparison' : 'Compare Courses',
                                key: ValueKey(_isComparing ? 'cancel' : 'compare'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            foregroundColor: Colors.white,
                            extendedTextStyle: TextStyle(color: Colors.white),
                            extendedIconLabelSpacing: 8,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Selection Counter (Updated)
                    if (_isComparing)
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Selected: ${_selectedCoursesForComparison.length}/2',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Processing indicator
                    // Inside the Stack widget in build method, after the main content
                    if (_isProcessingComparison)
                      Container(
                        color: Colors.black54,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Comparing courses...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
              ),
        ),
     
                  
            
        // Comparison overlay
        if (_showComparisonOverlay && _comparisonData != null)
          ComparisonOverlay(
            comparisonData: _comparisonData!,
            onClose: _closeComparisonOverlay,
          ),
      ],
    );
  }

  Widget _buildCourseList(List<Course> courses) {
    return Container(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Container(
            width: 240,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: CourseCard(
              course: course,
              isSelectable: false,
              isSelected: false,
              onSelect: (_) {},
              // onWishlistChanged: (_) {
              //   final wishlistProvider = context.read<WishlistProvider>();
              //   if (wishlistProvider.isInWishlist(course)) {
              //     wishlistProvider.removeFromWishlist(course);
              //   } else {
              //     wishlistProvider.addToWishlist(course);
              //   }
              // },
            ),
          );
        },
      ),
    );
  }
}