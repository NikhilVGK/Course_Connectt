import 'package:flutter/material.dart';
import '../models/course.dart';

class FilterScreen extends StatefulWidget {
  final String initialQuery;
  final List<Course> initialResults;

  FilterScreen({
    required this.initialQuery,
    required this.initialResults,
  });

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String? _selectedRating;
  String? _selectedPlatform;
  List<Course> _results = [];

  final List<String> _ratingOptions = ['4.5+', '4.0+', '3.5+', '3.0+', 'All'];
  final List<Map<String, String>> _platforms = [
    {'name': 'Coursera', 'domain': 'coursera.org'},
    {'name': 'edX', 'domain': 'edx.org'},
    {'name': 'LinkedIn Learning', 'domain': 'linkedin.com/learning'},
  ];

  @override
  void initState() {
    super.initState();
    _results = widget.initialResults;
    _selectedRating = 'All';
  }

  void _applyFilters() {
    setState(() {
      _results = widget.initialResults.where((course) {
        bool matchesPlatform = _selectedPlatform == null || 
            course.productLink.contains(_platforms.firstWhere(
                (p) => p['name'] == _selectedPlatform)['domain']!);
        
        bool matchesRating = _selectedRating == 'All' || 
            course.rating >= double.parse(_selectedRating!.replaceAll('+', ''));
        
        return matchesPlatform && matchesRating;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter Courses', 
                    style: Theme.of(context).textTheme.titleLarge),
                Row(
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.refresh),
                      label: Text('Reset'),
                      onPressed: () {
                        setState(() {
                          _selectedPlatform = null;
                          _selectedRating = 'All';
                          _results = widget.initialResults;
                        });
                      },
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, _results),
                      child: Text('Apply'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0047AB),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Divider(),
            Text('Select Rating',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedRating,
              isExpanded: true,
              items: _ratingOptions.map((rating) => 
                DropdownMenuItem(value: rating, child: Text(rating))
              ).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedRating = newValue;
                  _applyFilters();
                });
              },
            ),
            SizedBox(height: 16),
            Text('Select Platform',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _platforms.map((platform) {
                bool isSelected = _selectedPlatform == platform['name'];
                return FilterChip(
                  selected: isSelected,
                  label: Text(platform['name']!),
                  onSelected: (_) {
                    setState(() {
                      _selectedPlatform = isSelected ? null : platform['name'];
                      _applyFilters();
                    });
                  },
                  selectedColor: Color(0xFF0047AB).withOpacity(0.2),
                  checkmarkColor: Color(0xFF0047AB),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
