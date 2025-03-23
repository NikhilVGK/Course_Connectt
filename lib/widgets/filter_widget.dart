import 'package:flutter/material.dart';
import 'package:course_connect/utils/constants.dart';

class FilterWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  FilterWidget({required this.onApplyFilters});

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  RangeValues _priceRange = RangeValues(0, 200);
  double _minRating = 0.0;
  String _selectedLevel = '';
  String _selectedPlatform = '';
  String _selectedDuration = '';

  void _applyFilters() {
    final filters = {
      'min_price': _priceRange.start,
      'max_price': _priceRange.end,
      'min_rating': _minRating,
      'level': _selectedLevel,
      'platform': _selectedPlatform,
      'duration': _selectedDuration,
    };
    
    widget.onApplyFilters(filters);
  }

  void _resetFilters() {
    setState(() {
      _priceRange = RangeValues(0, 200);
      _minRating = 0.0;
      _selectedLevel = '';
      _selectedPlatform = '';
      _selectedDuration = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Courses',
                  style: Theme.of(context).textTheme.titleLarge, // Updated from headline6
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text('Reset'),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 16),
            
            Text(
              'Price Range',
              style: Theme.of(context).textTheme.titleMedium, // Updated from subtitle1
            ),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 200,
              divisions: 20,
              labels: RangeLabels(
                '\$${_priceRange.start.round()}',
                '\$${_priceRange.end.round()}',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),
            SizedBox(height: 16),
            
            Text(
              'Minimum Rating',
              style: Theme.of(context).textTheme.titleMedium, // Updated from subtitle1
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _minRating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: _minRating.toString(),
                    onChanged: (double value) {
                      setState(() {
                        _minRating = value;
                      });
                    },
                  ),
                ),
                Container(
                  width: 60,
                  child: Text(
                    '${_minRating.toStringAsFixed(1)}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            Text(
              'Course Level',
              style: Theme.of(context).textTheme.titleMedium, // Updated from subtitle1
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: CourseLevels.values.map((level) {
                return ChoiceChip(
                  label: Text(level),
                  selected: _selectedLevel == level,
                  onSelected: (selected) {
                    setState(() {
                      _selectedLevel = selected ? level : '';
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            
            Text(
              'Platform',
              style: Theme.of(context).textTheme.titleMedium, // Updated from subtitle1
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: Platforms.values.map((platform) {
                return ChoiceChip(
                  label: Text(platform),
                  selected: _selectedPlatform == platform,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPlatform = selected ? platform : '';
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            
            Text(
              'Duration',
              style: Theme.of(context).textTheme.titleMedium, // Updated from subtitle1
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: CourseDurations.values.map((duration) {
                return ChoiceChip(
                  label: Text(duration),
                  selected: _selectedDuration == duration,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDuration = selected ? duration : '';
                    });
                  },
                );
              }).toList(),
            ),
            
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
