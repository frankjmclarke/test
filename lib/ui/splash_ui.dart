import 'package:flutter/material.dart';
import 'components/centered_text.dart';

class SplashUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: CenteredText(text: 'Getting ready...'),
      ),
    );
  }
}
