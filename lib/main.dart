import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:course_connect/screens/home_screen.dart';
import 'package:course_connect/screens/dashboard_screen.dart';
import 'package:course_connect/screens/recommendations_screen.dart';
import 'package:course_connect/screens/search_screen.dart';
import 'package:course_connect/providers/recommendation_provider.dart';
import 'package:course_connect/screens/welcome_screen.dart';
import '../providers/course_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),  // Add this line
      ],
      child: CourseConnectApp(),  // Changed from MyApp to CourseConnectApp
    ),
  );
}

class CourseConnectApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course Connect',
      theme: ThemeData(
        primaryColor: Color(0xFF0047AB),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
          displaySmall: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
          bodySmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
        ),
      ),
      home: const WelcomeScreen(),  // Set WelcomeScreen as initial screen
      routes: {
        // Remove the '/' route since we're using 'home'
        '/search': (context) => SearchScreen(),
        '/recommendations': (context) => RecommendationsScreen(),
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    HomeScreen(),
    DashboardScreen(),
    RecommendationsScreen(),
  ];

  final List<String> _titles = [
    'Home',
    'Dashboard',
    'Wishlist',
    'Recommendations',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recommend),
            label: 'Recommendations',
          ),
        ],
      ),
    );
  }
}
