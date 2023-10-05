import 'package:flutter/material.dart';
import 'word_cloud.dart';

void main() => runApp(WordCloudApp());

class WordCloudApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Cloud Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WordCloud(),
    );
  }
}