import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Movie>> _movies;

  @override
  void initState() {
    super.initState();
    _movies = ApiService.fetchPopularMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Movie Hub')),
      body: FutureBuilder<List<Movie>>(
        future: _movies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No movies found.'));
          }

          final movies = snapshot.data!;
          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Card(
                child: ListTile(
                  leading: Image.network(movie.posterUrl, width: 50),
                  title: Text(movie.title),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailScreen(movie: movie),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
