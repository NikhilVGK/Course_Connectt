import 'package:flutter/material.dart';
import 'package:course_connect/utils/constants.dart';

class PlatformSelector extends StatelessWidget {
  final Function(String) onPlatformSelected;

  PlatformSelector({required this.onPlatformSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPlatformChip('Coursera'),
          SizedBox(width: 8),
          _buildPlatformChip('edX'),
          SizedBox(width: 8),
          _buildPlatformChip('LinkedIn Learning'),
        ],
      ),
    );
  }

  Widget _buildPlatformChip(String platform) {
    return ActionChip(
      label: Text(platform),
      onPressed: () => onPlatformSelected(platform),
    );
  }
}
