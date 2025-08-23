import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});
  static const String routeName = 'error';

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Error', style: TextStyle(fontSize: 42))));
  }
}
