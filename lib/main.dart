import 'package:flutter/material.dart';

void main() {
  runApp(MovieHubApp());
}

class MovieHubApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      title: 'Movie Hub',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, 
      ),
      home: HomeScreen(), 
    );
  }
}
