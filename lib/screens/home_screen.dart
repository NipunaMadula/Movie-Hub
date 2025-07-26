import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {

  final List<Map<String, String>> movies = [
    {
      'title': 'Inception',
      'poster': 'https://image.tmdb.org/t/p/w500//qmDpIHrmpJINaRKAfWQfftjCdyi.jpg'
    },
    {
      'title': 'Interstellar',
      'poster': 'https://image.tmdb.org/t/p/w500//gEU2QniE6E77NI6lCU6MxlNBvIx.jpg'
    },
    {
      'title': 'Joker',
      'poster': 'https://image.tmdb.org/t/p/w500//udDclJoHjfjb8Ekgsd4FDteOkCU.jpg'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Hub'),
      ),
      body: ListView.builder( 
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index]; 
          return Card( 
            child: ListTile(
              leading: Image.network(movie['poster']!, width: 50),
              title: Text(movie['title']!),
            ),
          );
        },
      ),
    );
  }
}
