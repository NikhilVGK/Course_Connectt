import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              // Logo and title
              const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.school,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Course Connect',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Find the Perfect Course for Your Learning Journey',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 1),
              // Features
              _buildFeatureItem(
                icon: Icons.compare_arrows,
                title: 'Compare Courses',
                description: 'Side-by-side comparison of courses across platforms',
              ),
              const SizedBox(height: 24),
              _buildFeatureItem(
                icon: Icons.filter_list,
                title: 'Smart Filtering',
                description: 'Filter by price, duration, level, and learning style',
              ),
              const SizedBox(height: 24),
              _buildFeatureItem(
                icon: Icons.thumb_up,
                title: 'Personalized Recommendations',
                description: 'Get course suggestions based on your preferences',
              ),
              const Spacer(flex: 2),
              // Get Started button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>  HomeScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Sign in link
              Center(
                child: TextButton(
                  onPressed: () {
                    // Sign in functionality would go here in a real app
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sign in functionality will be implemented in a future update.'),
                      ),
                    );
                  },
                  child: const Text('Already have an account? Sign in'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}// Code exactly as provided in your prompt