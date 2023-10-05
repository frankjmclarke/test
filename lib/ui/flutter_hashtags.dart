import 'dart:math';
import 'package:flutter/material.dart';

class FlutterHashtag {
  FlutterHashtag(
      this.hashtag,
      this.color,
      this.size,
      this.rotated,
      );

  String hashtag = '';
  Color color = Color.fromARGB(33, 33, 33, 33);
  int size = 1;
  bool rotated = false;
}

class FlutterColors {
  const FlutterColors._();

  static const Color yellowShade = Color(0xFFFFC108);
  static const Color yellow = Color(0xFFEB3B);

  // static const Color white = Color(0xFFFFFFFF);

  static const Color blue400 = Color(0xFF13B9FD);
  static const Color blue600 = Color(0xFF0175C2);
  static const Color blue = Color(0xFF02569B);
  static const Color red =  Color(0xFFfF0000);

  static const Color gray100 = Color(0xFFD5D7DA);
  static const Color gray600 = Color(0xFF60646B);
  static const Color gray = Color(0xFF202124);

  static const Color green = Color(0xF44caF50);

  static const Color deepOrange = Color(0xFFFF5722);
  static const Color orange = Color(0xFFFF9800);
}
Color generateRandomColor() {
  final random = Random();
  final List<Color> colors = [
    FlutterColors.yellowShade,
    FlutterColors.yellow,
    FlutterColors.blue400,
    FlutterColors.blue600,
    FlutterColors.blue,
    FlutterColors.red,
    FlutterColors.gray100,
    FlutterColors.gray600,
    FlutterColors.gray,
    FlutterColors.green,
    FlutterColors.deepOrange,
    FlutterColors.orange,
  ];

  return colors[random.nextInt(colors.length)];
}

List<FlutterHashtag> generateFlutterHashtags(
    List<String> hashtags, List<FlutterHashtag> kFlutterHashtags) {
  final List<FlutterHashtag> flutterHashtags = [];
  if (hashtags.isEmpty)
    return flutterHashtags;
  final random = Random();

  for (final hashtag in hashtags) {
    final size = random.nextInt(50) + 20;
    final rotated = random.nextBool();

    final flutterHashtag = FlutterHashtag(
      hashtag,
      generateRandomColor(),
      size,
      rotated,
    );

    flutterHashtags.add(flutterHashtag);
  }

  return flutterHashtags;
}

void main() {
  final List<String> hashtags = [
    'Example1',
    'Example2',
    'Example3',
    // Add more hashtags here
  ];

  final List<FlutterHashtag> kFlutterHashtags = <FlutterHashtag>[
    FlutterHashtag('FlutterTastic', FlutterColors.yellow, 50, false),
    FlutterHashtag('FlutterSpiration', FlutterColors.red, 34, false),
    FlutterHashtag('FlutterSpirit', FlutterColors.blue600, 29, true),
    // Add more FlutterHashtag objects here
  ];

  final List<FlutterHashtag> flutterHashtags =
  generateFlutterHashtags(hashtags, kFlutterHashtags);

  // Do something with the generated flutterHashtags
  for (final flutterHashtag in flutterHashtags) {
    print(flutterHashtag.hashtag);
    print(flutterHashtag.color);
    print(flutterHashtag.size);
    print(flutterHashtag.rotated);
  }
}
