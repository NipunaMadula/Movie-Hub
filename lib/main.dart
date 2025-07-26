import 'package:flutter/material.dart';
import 'package:movie_hub/screens/home_screen.dart';

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
