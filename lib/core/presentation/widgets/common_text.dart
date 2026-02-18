import 'package:flutter/material.dart';

class CommonText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;

  const CommonText(this.data, {super.key, this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Text(data, style: style, textAlign: textAlign);
  }
}
