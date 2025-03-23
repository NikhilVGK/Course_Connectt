import 'package:flutter/material.dart';
import 'package:course_connect/models/user.dart';
import 'package:course_connect/models/course.dart';
import 'package:course_connect/services/course_service.dart';
import 'package:course_connect/widgets/course_card.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CourseService _courseService = CourseService();
  late User _user;
  List<Course> _enrolledCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // In a real app, you would fetch the user from a service
      _user = User.sample();
      
      // For demo purposes, show some recommended courses instead of enrolled courses
      _enrolledCourses = await _courseService.getRecommendedCourses();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserProfileSection(),
                    SizedBox(height: 30),
                    Text(
                      'Recommended Courses',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    SizedBox(height: 10),
                    _enrolledCourses.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'No courses to display at the moment.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _enrolledCourses.length,
                            itemBuilder: (context, index) {
                              final course = _enrolledCourses[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 12.0),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      course.image_link,  // Fix: image_link -> imageLink
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(course.title),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(course.organization),
                                      Row(
                                        children: [
                                          Icon(Icons.star, size: 16, color: Colors.amber),
                                          Text(' ${course.rating} (${course.reviews} reviews)'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    // Launch course URL
                                    // In a real app, you would use url_launcher package
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Opening course: ${course.title}')),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUserProfileSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    _user.name.substring(0, 1),
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user.name,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      SizedBox(height: 5),
                      Text(
                        _user.email,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 10),
            Text(
              'Login Credentials',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: _user.email,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: '••••••••',
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.visibility_off),
              ),
              obscureText: true,
              readOnly: true,
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                // In a real app, this would navigate to a password change screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('This functionality is not implemented in this demo')),
                );
              },
              child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
