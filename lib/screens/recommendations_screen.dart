import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recommendation_provider.dart';
import '../models/recommendation_response.dart';
import '../widgets/course_card.dart';
// Remove this import
// import '../providers/wishlist_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendationsScreen extends StatefulWidget {
  @override
  _RecommendationsScreenState createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final TextEditingController _queryController = TextEditingController();
  late RecommendationProvider _recommendationProvider;

  @override
  void initState() {
    super.initState();
    _recommendationProvider = Provider.of<RecommendationProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _getRecommendations() async {
    if (_queryController.text.trim().isEmpty) return;
    await _recommendationProvider.getRecommendations(_queryController.text);
  }

  Widget _buildSkillsSection(List<String> skills) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skills to Learn',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: skills.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () async {
                      final url = Uri.parse(
                          'https://www.google.com/search?q=${Uri.encodeComponent(skills[index])} course');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Card(
                      elevation: 3,
                      color: Color(0xFF0047AB).withOpacity(0.1),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          skills[index],
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0047AB),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

  Widget _buildRecommendationContent(RecommendationResponse recommendation) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recommendation.summary,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 16),
          Text(recommendation.recommendation),
          SizedBox(height: 24),
          _buildSkillsSection(recommendation.skills),  // Use the new method
          SizedBox(height: 24),
          Text(
            'Learning Path',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(recommendation.learn_path),
          SizedBox(height: 24),
          Text(
            'Recommended Courses',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: recommendation.courses.length,
            itemBuilder: (context, index) {
              final course = recommendation.courses[index];
              return CourseCard(
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
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recommendations'),
        backgroundColor: Color(0xFF0047AB),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _queryController,
              decoration: InputDecoration(
                hintText: 'What would you like to learn?',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _getRecommendations,
                ),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _getRecommendations(),
            ),
          ),
          Expanded(
            child: Consumer<RecommendationProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }
                if (provider.error != null) {
                  return Center(child: Text(provider.error!));
                }
                if (provider.recommendation != null) {
                  return _buildRecommendationContent(provider.recommendation!);
                }
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Search for a topic to get started',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}