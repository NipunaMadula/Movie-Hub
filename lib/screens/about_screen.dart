import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About & Privacy')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Movie Hub\n\nVersion 1.0.0\n\nPrivacy policy and terms (placeholder).'),
      ),
    );
  }
}
