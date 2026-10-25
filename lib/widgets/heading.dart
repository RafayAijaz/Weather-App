import 'package:flutter/material.dart';

class Heading extends StatelessWidget {
  final String content;
  const Heading({required this.content, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      textAlign: TextAlign.start,
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, ),
    );
  }
}
