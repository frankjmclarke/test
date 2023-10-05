import 'package:flutter/material.dart';

class PlaceholderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300], // Placeholder background color
      child: Icon(
        Icons.no_photography, // Placeholder icon
        color: Colors.grey[600], // Placeholder icon color
        size: 96, // Placeholder icon size
      ),
    );
  }
}