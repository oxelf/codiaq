import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int a = 10;
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
