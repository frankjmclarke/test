import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
class CenteredText extends StatelessWidget {
  final String text;

  const CenteredText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/ic_overwrite.png',
            width: 35.h,
            height: 35.h,
          ),
          SizedBox(height: 2.h), // Add some spacing between the image and text
          Text(
            text,
            style: TextStyle(
              color: Colors.green,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
