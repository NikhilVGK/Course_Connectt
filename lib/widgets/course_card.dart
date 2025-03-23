import 'package:flutter/material.dart';
import '../models/course.dart';
// Remove these imports
// import 'package:provider/provider.dart';
// import '../providers/wishlist_provider.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final bool isSelectable;
  final bool isSelected;
  final Function(Course) onSelect;

  const CourseCard({
    required this.course,
    required this.isSelectable,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isSelectable ? () => onSelect(course) : null,
      child: Card(
        elevation: isSelected ? 8 : 2,
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                  child: Image.network(
                    course.image_link,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        course.platform,
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(course.rating.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isSelectable && isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}