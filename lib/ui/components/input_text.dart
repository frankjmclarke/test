import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../edit_text_ui.dart';

class InputText extends StatelessWidget {
  final String text;
  final TextEditingController controller;

  const InputText({
    required this.text,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(text: text),
        TextFormField(
          controller: controller,
        ),
        SizedBox(height: 2.h),
      ],
    );
  }
}