import 'package:flutter/material.dart';
import 'flutter_hashtags.dart';

class ScatterWord extends StatefulWidget {
  ScatterWord({
    required this.hashtag,
    required this.index,
    required this.plus,
    required this.minus,
  });

  final FlutterHashtag hashtag;
  final int index;
  final void Function(int) plus;
  final void Function(int) minus;

  @override
  _ScatterWordState createState() => _ScatterWordState();
}

class _ScatterWordState extends State<ScatterWord> {
  Offset position = Offset.zero;

  void onPanUpdate(DragUpdateDetails details) {
    setState(() {
      position += details.delta;

      final screenSize = MediaQuery.of(context).size;
      final itemSize = context.size!.width; // Assuming item is a square

      // Check if item is dragged off the edge of the screen
      if (position.dx < -itemSize ||
          position.dy < -itemSize ||
          position.dx > screenSize.width ||
          position.dy > screenSize.height) {
        widget.minus(widget.index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: widget.hashtag.size.toDouble() * 1,
      color: widget.hashtag.color,
    );

    return Transform.translate(
      offset: position,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  widget.plus(widget.index);
                },
                child: Icon(
                  Icons.add_circle, // Replace with your desired Flutter icon before the text
                  size: 24, // Adjust the size as needed
                  color: widget.hashtag.color, // Adjust the color as needed
                ),
              ),
              SizedBox(width: 4), // Adjust the width as needed for spacing
              RotatedBox(
                quarterTurns: widget.hashtag.rotated ? 0 : 0,
                child: Text(
                  widget.hashtag.hashtag,
                  style: style,
                ),
              ),
              SizedBox(width: 4), // Adjust the width as needed for spacing
              GestureDetector(
                onTap: () {
                  widget.minus(widget.index);
                },
                child: Icon(
                  Icons.remove_circle, // Replace with your desired Flutter icon after the text
                  size: 24, // Adjust the size as needed
                  color: widget.hashtag.color, // Adjust the color as needed
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}