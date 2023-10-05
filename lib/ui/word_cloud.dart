import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_scatter/flutter_scatter.dart';
import 'package:get/get.dart';
import 'flutter_hashtags.dart';
import 'scatter_item.dart';

class WordCloud extends StatefulWidget {
  @override
  _WordCloudState createState() => _WordCloudState();
}

class _WordCloudState extends State<WordCloud> {
  List<Widget> widgets = <Widget>[];
  bool isDeleteMode = false;
  Timer? timer;
   List<FlutterHashtag> kFlutterHashtags = <FlutterHashtag>[];

  @override
  void initState() {
    super.initState();
    var keywords = Get.arguments[0]['keywords'] ?? [];
    kFlutterHashtags = generateFlutterHashtags(keywords, kFlutterHashtags);
    populateWidgets();
    startAnimation();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void populateWidgets() {
    widgets = kFlutterHashtags
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key;
      final hashtag = entry.value;
      return ScatterWord(
        hashtag: hashtag,
        index: index,
        plus: plus,
        minus: minus,
      );
    })
        .toList();
  }

  void minus(int index) {
    setState(() {
      kFlutterHashtags[index].size -= 6;
      if (kFlutterHashtags[index].size < 15) kFlutterHashtags.removeAt(index);
      populateWidgets(); // Update the widgets list
    });
  }

  void plus(int index) {
    setState(() {
      kFlutterHashtags[index].size += 6;
      populateWidgets(); // Update the widgets list
    });
  }

  void onTap(int index) {
    setState(() {
      if (isDeleteMode) {
        kFlutterHashtags[index].size -= 6;
        if (kFlutterHashtags[index].size < 15) kFlutterHashtags.removeAt(index);
      } else
        kFlutterHashtags[index].size += 6;
      populateWidgets(); // Update the widgets list
    });
  }

  void onDragOffScreen(int index) {
    if (index >= 0 && index < kFlutterHashtags.length) {
      setState(() {
        kFlutterHashtags.removeAt(index);
        populateWidgets(); // Update the widgets list
      });
    } else {
      print('🟥Index out of range');
    }
  }

  void greenButton() {
    setState(() {
      isDeleteMode = false;
    });
  }

  void redButton() {
    setState(() {
      isDeleteMode = true;
    });
  }

  void startAnimation() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final random = Random();
      if (kFlutterHashtags.isNotEmpty) {
        final randomIndex = random.nextInt(kFlutterHashtags.length);
        final removedWord = kFlutterHashtags.removeAt(randomIndex);
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            kFlutterHashtags.add(removedWord);
            populateWidgets();
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    var ratio = screenSize.width / (screenSize.height);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Scatter(
              alignment: Alignment.centerLeft,
              fillGaps: true,
              delegate: ArchimedeanSpiralScatterDelegate(ratio: ratio),
              children: widgets,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              onPressed: redButton,
              heroTag: 'red',
              backgroundColor: isDeleteMode ? Colors.red : Colors.grey,
              child: Icon(
                Icons.thumb_down,
              ),
            ),
            FloatingActionButton(
              onPressed: greenButton,
              heroTag: 'green',
              backgroundColor: isDeleteMode ? Colors.grey : Colors.green,
              child: Icon(
                Icons.thumb_up,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
