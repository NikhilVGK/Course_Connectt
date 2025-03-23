import 'package:flutter/material.dart';
import 'package:course_connect/models/course.dart';
import 'package:course_connect/models/comparison_data.dart';
import 'package:course_connect/services/comparison_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CompareScreen extends StatefulWidget {
  final List<Course> courses;

  CompareScreen({required this.courses});

  @override
  _CompareScreenState createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final ComparisonService _comparisonService = ComparisonService();
  bool _isLoading = true;
  ComparisonData? _comparisonData;

  @override
  void initState() {
    super.initState();
    _loadComparison();
  }

  Future<void> _loadComparison() async {
    try {
      final response = await _comparisonService.compareCourses(
        widget.courses[0],
        widget.courses[1],
      );
      setState(() {
        _comparisonData = ComparisonData.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading comparison: $e')),
      );
    }
  }

  Future<void> _launchCourseUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open course link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Comparison'),
        backgroundColor: Color(0xFF0047AB),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _comparisonData == null
              ? Center(child: Text('Failed to load comparison'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildComparisonHeader(),
                      SizedBox(height: 24),
                      _buildComparisonTable(),
                      SizedBox(height: 24),
                      _buildAnalysisSection(),
                      SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildComparisonHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Comparison',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0047AB),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Compare features and make an informed decision',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Table(
          columnWidths: {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
          },
          border: TableBorder.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          children: [
            _buildTableRow('Feature', 'Course 1', 'Course 2', isHeader: true),
            _buildTableRow('Title', widget.courses[0].title, widget.courses[1].title),
            _buildTableRow('Platform', widget.courses[0].platform, widget.courses[1].platform),
            _buildTableRow('Rating', widget.courses[0].rating.toString(), widget.courses[1].rating.toString()),
            _buildTableRow('Instructor', widget.courses[0].instructor, widget.courses[1].instructor),
            _buildTableRow('Organization', widget.courses[0].organization, widget.courses[1].organization),
            _buildTableRow('Reviews', widget.courses[0].reviews.toString(), widget.courses[1].reviews.toString()),
            _buildTableRow('Price', '\$${widget.courses[0].price}', '\$${widget.courses[1].price}'),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value1, String value2, {bool isHeader = false}) {
    final style = isHeader
        ? TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0047AB))
        : TextStyle();
    final bgColor = isHeader ? Colors.grey.shade100 : Colors.white;

    return TableRow(
      decoration: BoxDecoration(color: bgColor),
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Text(label, style: style),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: Text(value1, style: style),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: Text(value2, style: style),
        ),
      ],
    );
  }

  Widget _buildAnalysisSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0047AB),
              ),
            ),
            SizedBox(height: 16),
            Text(_comparisonData!.summary),
            SizedBox(height: 16),
            _buildAdvantagesDisadvantages(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvantagesDisadvantages() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildAdvantagesList(),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildDisadvantagesList(),
        ),
      ],
    );
  }

  Widget _buildAdvantagesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advantages',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        SizedBox(height: 8),
        ...(_comparisonData!.advantages.map((advantage) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text(advantage)),
                ],
              ),
            ))),
      ],
    );
  }

  Widget _buildDisadvantagesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Disadvantages',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        SizedBox(height: 8),
        ...(_comparisonData!.disadvantages.map((disadvantage) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text(disadvantage)),
                ],
              ),
            ))),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => _launchCourseUrl(widget.courses[0].productLink),
          icon: Icon(Icons.launch),
          label: Text('View Course 1'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0047AB),  // Changed from primary to backgroundColor
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _launchCourseUrl(widget.courses[1].productLink),
          icon: Icon(Icons.launch),
          label: Text('View Course 2'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0047AB),  // Changed from primary to backgroundColor
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }
}